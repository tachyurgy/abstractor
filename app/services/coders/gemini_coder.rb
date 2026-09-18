require "net/http"
require "json"

module Coders
  # Model-backed coder constrained by a response schema: the caller gets typed proposals
  # or an exception, never prose. It may ONLY choose codes from the code dictionary the
  # prompt hands it, and every proposal must carry a verbatim quote from the note. The
  # quote is checked downstream (CodingAgent) -- a proposal whose quote is not in the note
  # is kept but flagged unverified, so the reviewer sees exactly which suggestions the
  # model could not point to.
  class GeminiCoder
    MODEL = ENV.fetch("GEMINI_MODEL", "gemini-3.7-flash")
    ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent".freeze

    SCHEMA = {
      type: "OBJECT",
      properties: {
        proposals: {
          type: "ARRAY",
          items: {
            type: "OBJECT",
            properties: {
              kind:       { type: "STRING", enum: %w[dx px] },
              code:       { type: "STRING", description: "A code copied exactly from the dictionary" },
              rationale:  { type: "STRING", description: "One sentence: why this code, in coding terms" },
              evidence:   { type: "STRING", description: "Verbatim substring of the note that supports the code" },
              confidence: { type: "INTEGER", description: "0-100" }
            },
            required: %w[kind code rationale evidence confidence]
          }
        }
      },
      required: %w[proposals]
    }.freeze

    PROMPT = <<~TXT.freeze
      You are an outpatient medical coder. Read the clinical note and propose the ICD-10-CM
      diagnosis codes (kind "dx") and CPT procedure/E-M codes (kind "px") that should be
      reported for this encounter.

      Hard rules:
      - Choose ONLY from the dictionary below. Copy the code exactly. If the right code is not
        in the dictionary, do not propose anything for that finding.
      - Code to the highest specificity the note supports. Never propose a category header.
      - Do not code signs or symptoms that are integral to a definitive diagnosis in the note.
      - Do not propose two codes the dictionary marks as mutually exclusive.
      - "evidence" must be copied verbatim from the note: the exact words, same spelling and
        punctuation. Do not paraphrase. If you cannot quote it, do not propose it.
      - One E/M code at most. Add a procedure code only when the note documents that the
        procedure was performed today.

      Dictionary (kind | code | description):
      %<dictionary>s

      Mutually exclusive pairs (never together): %<excludes>s

      Clinical note:
      ---
      %<note>s
    TXT

    def self.configured? = ENV["GEMINI_API_KEY"].to_s.strip != ""
    def name = MODEL

    def propose(note)
      uri = URI(format(ENDPOINT, MODEL))
      dictionary = CodeSet.where(billable: true).order(:kind, :code).map { |c| "#{c.kind} | #{c.code} | #{c.description}" }.join("\n")
      excludes = Excludes1Rule.all.map { |r| "#{r.code_a}* with #{r.code_b}*" }.join("; ")
      payload = {
        contents: [{ parts: [{ text: format(PROMPT, dictionary: dictionary, excludes: excludes, note: note) }] }],
        generationConfig: { temperature: 0, responseMimeType: "application/json", responseSchema: SCHEMA }
      }
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true; http.open_timeout = 8; http.read_timeout = 60
      res = http.post(uri.request_uri, payload.to_json, "Content-Type" => "application/json",
                      "x-goog-api-key" => ENV["GEMINI_API_KEY"])
      raise "gemini http #{res.code}: #{res.body[0, 200]}" unless res.code.to_i == 200
      text = JSON.parse(res.body).dig("candidates", 0, "content", "parts", 0, "text")
      raise "gemini returned no content" if text.to_s.strip.empty?
      JSON.parse(text).fetch("proposals").map do |p|
        cs = CodeSet.lookup(p["kind"], p["code"])
        next unless cs   # off-dictionary code: dropped, the model was told not to do this
        { kind: cs.kind, code: cs.code, description: cs.description,
          rationale: p["rationale"].to_s, evidence: p["evidence"].to_s,
          confidence: p["confidence"].to_i.clamp(0, 100) }
      end.compact
    end
  end
end

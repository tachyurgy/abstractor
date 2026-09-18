# Synthetic data only. Patient references are fabricated; notes are invented for the demo.
DX = [
  ["E11",     "Type 2 diabetes mellitus (category)",                                  false, ""],
  ["E11.9",   "Type 2 diabetes mellitus without complications",                      true,  "type 2 diabetes|t2dm|type ii diabetes|diabetes type 2"],
  ["E11.65",  "Type 2 diabetes mellitus with hyperglycemia",                         true,  "diabetes with hyperglycemia|uncontrolled type 2 diabetes|type 2 diabetes, uncontrolled"],
  ["E11.40",  "Type 2 diabetes mellitus with diabetic neuropathy, unspecified",      true,  "diabetic neuropathy"],
  ["E10.9",   "Type 1 diabetes mellitus without complications",                      true,  "type 1 diabetes|t1dm"],
  ["I10",     "Essential (primary) hypertension",                                     true,  "hypertension|htn"],
  ["E78.5",   "Hyperlipidemia, unspecified",                                          true,  "hyperlipidemia|high cholesterol"],
  ["J45",     "Asthma (category)",                                                    false, ""],
  ["J45.20",  "Mild intermittent asthma, uncomplicated",                              true,  "mild intermittent asthma"],
  ["J45.40",  "Moderate persistent asthma, uncomplicated",                            true,  "moderate persistent asthma"],
  ["J45.909", "Unspecified asthma, uncomplicated",                                    true,  "asthma"],
  ["J44.9",   "Chronic obstructive pulmonary disease, unspecified",                   true,  "copd|chronic obstructive pulmonary disease"],
  ["J44.1",   "Chronic obstructive pulmonary disease with (acute) exacerbation",      true,  "copd exacerbation|exacerbation of copd|acute exacerbation of her copd|acute exacerbation of his copd"],
  ["J06.9",   "Acute upper respiratory infection, unspecified",                       true,  "upper respiratory infection|viral uri"],
  ["J02.0",   "Streptococcal pharyngitis",                                            true,  "streptococcal pharyngitis|strep pharyngitis|strep throat"],
  ["J02.9",   "Acute pharyngitis, unspecified",                                       true,  "pharyngitis"],
  ["J18.9",   "Pneumonia, unspecified organism",                                      true,  "pneumonia"],
  ["J20.9",   "Acute bronchitis, unspecified",                                        true,  "acute bronchitis"],
  ["N39.0",   "Urinary tract infection, site not specified",                          true,  "urinary tract infection|uti"],
  ["R05.9",   "Cough, unspecified",                                                   true,  "cough"],
  ["R50.9",   "Fever, unspecified",                                                   true,  "fever"],
  ["R10.9",   "Unspecified abdominal pain",                                           true,  "abdominal pain"],
  ["R51.9",   "Headache, unspecified",                                                true,  "headache"],
  ["M54.50",  "Low back pain, unspecified",                                           true,  "low back pain"],
  ["M25.561", "Pain in right knee",                                                   true,  "right knee pain"],
  ["M25.562", "Pain in left knee",                                                    true,  "left knee pain"],
  ["M17.11",  "Unilateral primary osteoarthritis, right knee",                        true,  "osteoarthritis of the right knee|right knee osteoarthritis"],
  ["M17.12",  "Unilateral primary osteoarthritis, left knee",                         true,  "osteoarthritis of the left knee|left knee osteoarthritis"],
  ["F41.1",   "Generalized anxiety disorder",                                         true,  "generalized anxiety disorder"],
  ["F32.A",   "Depression, unspecified",                                              true,  "depression"],
  ["F33.1",   "Major depressive disorder, recurrent, moderate",                       true,  "major depressive disorder, recurrent, moderate|recurrent major depressive disorder, moderate"],
  ["G47.00",  "Insomnia, unspecified",                                                true,  "insomnia"],
  ["K21.9",   "Gastro-esophageal reflux disease without esophagitis",                 true,  "gerd|gastroesophageal reflux"],
  ["E66.9",   "Obesity, unspecified",                                                 true,  "obesity"],
  ["E03.9",   "Hypothyroidism, unspecified",                                          true,  "hypothyroidism"],
  ["I48.91",  "Unspecified atrial fibrillation",                                      true,  "atrial fibrillation"],
  ["N18.30",  "Chronic kidney disease, stage 3 unspecified",                          true,  "ckd stage 3|chronic kidney disease stage 3"],
  ["Z00.00",  "Encounter for general adult medical examination without abnormal findings", true, "annual physical|preventive visit|wellness exam|annual preventive"],
  ["Z23",     "Encounter for immunization",                                           true,  "immunization|flu shot|influenza vaccine"],
  ["Z79.4",   "Long term (current) use of insulin",                                   true,  "on insulin|insulin glargine|basal insulin"],
  ["L03.115", "Cellulitis of right lower limb",                                       true,  "cellulitis of the right lower leg|right lower leg cellulitis"],
  ["S61.411A","Laceration without foreign body of right hand, initial encounter",     true,  "laceration of the right hand|right hand laceration|laceration to the dorsum of the right hand"],
  ["S61.412A","Laceration without foreign body of left hand, initial encounter",      true,  "laceration of the left hand|left hand laceration"],
  ["L57.0",   "Actinic keratosis",                                                    true,  "actinic keratosis|actinic keratoses"],
  ["H66.91",  "Otitis media, unspecified, right ear",                                 true,  "right otitis media|otitis media, right"],
  ["H61.21",  "Impacted cerumen, right ear",                                          true,  "impacted cerumen, right|impacted cerumen in the right"],
  ["H61.22",  "Impacted cerumen, left ear",                                           true,  "impacted cerumen, left|impacted cerumen in the left"],
  ["H61.23",  "Impacted cerumen, bilateral",                                          true,  "bilateral impacted cerumen|impacted cerumen bilaterally|cerumen impaction bilaterally"],
]
PX = [
  ["99203", "Office visit, new patient, low medical decision making",           true, "new patient|mdm: low, new"],
  ["99204", "Office visit, new patient, moderate medical decision making",      true, "new patient, moderate"],
  ["99212", "Office visit, established patient, straightforward MDM",           true, "mdm: straightforward|straightforward medical decision making"],
  ["99213", "Office visit, established patient, low MDM",                       true, "mdm: low|low complexity medical decision making|low medical decision making"],
  ["99214", "Office visit, established patient, moderate MDM",                  true, "mdm: moderate|moderate complexity medical decision making|moderate medical decision making"],
  ["99215", "Office visit, established patient, high MDM",                      true, "mdm: high|high complexity medical decision making"],
  ["99396", "Periodic preventive visit, established patient, 40-64 years",      true, "preventive visit, established|annual preventive|annual physical"],
  ["90471", "Immunization administration, one vaccine",                         false,"vaccine administered|administered intramuscularly|immunization administered"],
  ["90686", "Influenza vaccine, quadrivalent, preservative free, IM",           false,"quadrivalent influenza vaccine|influenza vaccine|flu shot"],
  ["12001", "Simple repair of superficial wound, 2.5 cm or less",               false,"simple repair|closed with 4 simple interrupted|simple interrupted sutures"],
  ["69210", "Removal of impacted cerumen requiring instrumentation, unilateral", false,"removed the impacted cerumen|cerumen removal|curette"],
  ["17000", "Destruction of premalignant lesion, first lesion",                 false,"cryotherapy|liquid nitrogen"],
  ["17003", "Destruction of premalignant lesions, 2-14, each additional",       false,"additional lesions|three lesions|3 lesions"],
  ["20610", "Arthrocentesis / injection, major joint",                          false,"knee injection|intra-articular|arthrocentesis|injected into the right knee|injected into the left knee"],
  ["87880", "Rapid streptococcus group A antigen test",                          false,"rapid strep|rapid streptococcal antigen"],
  ["81002", "Urinalysis, dipstick, non-automated, without microscopy",           false,"urine dipstick|dipstick urinalysis"],
  ["94640", "Inhalation treatment for airway obstruction (nebulizer)",           false,"nebulizer treatment|albuterol nebulizer"],
  ["93000", "Electrocardiogram, routine, with interpretation and report",        false,"12-lead ecg|ekg|electrocardiogram"],
  ["36415", "Collection of venous blood by venipuncture",                        false,"venipuncture|blood drawn"],
]
DX.each { |c, d, b, k| CodeSet.find_or_create_by!(kind: "dx", code: c) { |x| x.description = d; x.billable = b; x.keywords = k } }
PX.each { |c, d, em, k| CodeSet.find_or_create_by!(kind: "px", code: c) { |x| x.description = d; x.em = em; x.keywords = k } }

[["E11", "E10", "type 1 diabetes mellitus (E10.-) is not coded with type 2 (E11.-)"],
 ["J06", "J02.0", "J06 Excludes1: streptococcal pharyngitis (J02.0)"],
 ["F32", "F33", "F32 Excludes1: recurrent depressive disorder (F33.-)"]].each do |a, b, n|
  Excludes1Rule.find_or_create_by!(code_a: a, code_b: b) { |r| r.note = n }
end

NOTES = {
  "Diabetes and hypertension follow-up" => <<~N,
    CC: 3-month follow-up, established patient.
    HPI: 58 y/o with type 2 diabetes, hypertension and hyperlipidemia. Home glucose 120-150 fasting. No hypoglycemia. BP at home 130s/80s. Taking metformin, lisinopril, atorvastatin without side effects. Denies chest pain, polyuria, foot ulcers.
    Exam: BP 134/82, BMI 31. Feet: monofilament intact bilaterally, no lesions.
    A/P: 1. Type 2 diabetes without complications, at goal, continue metformin, A1c today. 2. Hypertension, controlled, continue lisinopril. 3. Hyperlipidemia, continue atorvastatin, lipid panel. Blood drawn in clinic by venipuncture. RTC 3 months.
    MDM: moderate (three chronic illnesses, prescription drug management).
  N
  "New patient, sore throat" => <<~N,
    CC: Sore throat x2 days. New patient to the practice.
    HPI: 24 y/o with sore throat, fever to 101.2 at home, odynophagia. No cough. Sick contact at work with strep.
    Exam: T 100.8. Tonsillar exudate, tender anterior cervical nodes. Lungs clear.
    Rapid strep antigen positive in clinic.
    A/P: Streptococcal pharyngitis. Amoxicillin 500 mg BID x10 days. Return if worse.
    MDM: low, new patient.
  N
  "Right knee osteoarthritis, injection" => <<~N,
    CC: Right knee pain, established patient.
    HPI: 67 y/o with known osteoarthritis of the right knee, worse over 6 weeks, pain with stairs, no locking, no trauma. Tried acetaminophen with partial relief. Also here for hypertension follow-up, BP log at home 128-138 systolic, tolerating amlodipine.
    Exam: Right knee mild effusion, crepitus, ROM 0-120, stable ligaments. BP 136/84.
    Procedure: After verbal consent, sterile prep, 40 mg triamcinolone with 4 mL lidocaine injected into the right knee via anterolateral approach. Tolerated well.
    A/P: 1. Osteoarthritis of the right knee, injected today, PT referral. 2. Hypertension, continue amlodipine, recheck 3 months.
    MDM: low. Separately identifiable E/M for the hypertension management.
  N
  "Hand laceration, simple repair" => <<~N,
    CC: Cut on right hand while washing a glass 2 hours ago.
    HPI: 34 y/o, 2.0 cm laceration to the dorsum of the right hand, bleeding controlled with pressure. No numbness or weakness. Tetanus up to date (2023). No foreign body sensation.
    Exam: 2.0 cm linear laceration, dorsum right hand, no tendon exposure, full finger ROM and sensation intact. Wound explored, no glass seen.
    Procedure: Irrigated with 250 mL saline, anesthetized with 1% lidocaine, closed with 4 simple interrupted 4-0 nylon sutures. Dressing applied.
    A/P: Laceration of the right hand, simple repair. Suture removal 10 days. Wound care reviewed.
  N
  "Bilateral cerumen impaction" => <<~N,
    CC: Decreased hearing both ears, established patient.
    HPI: 72 y/o with gradually muffled hearing bilaterally over a month, no pain, no drainage, no tinnitus. Uses cotton swabs.
    Exam: Bilateral impacted cerumen fully occluding both canals. TMs not visualized initially.
    Procedure: Removed the impacted cerumen from both ears with a curette and warm water irrigation under otoscopic visualization. TMs intact and normal after removal.
    A/P: Cerumen impaction bilaterally, removed. Hearing subjectively restored. Counseled to stop cotton swabs.
  N
  "Annual preventive visit with flu shot" => <<~N,
    CC: Annual physical, established patient, age 52.
    HPI: No complaints. Exercises 3x/week, nonsmoker, no alcohol concerns. Reviewed immunization history, colon cancer screening up to date.
    Exam: Comprehensive exam normal. BP 118/76, BMI 24.
    Preventive: Age-appropriate counseling on diet, exercise and screening. Quadrivalent influenza vaccine, preservative free, 0.5 mL administered intramuscularly in the left deltoid, no reaction.
    A/P: Preventive visit, no abnormal findings. Immunization for influenza given today. RTC 1 year.
  N
  "COPD exacerbation with nebulizer" => <<~N,
    CC: Shortness of breath x3 days, established patient.
    HPI: 66 y/o with COPD on tiotropium, worsening dyspnea, increased sputum volume and purulence, using rescue albuterol 6x/day. No fever, no chest pain. 40 pack-year former smoker.
    Exam: SpO2 91% RA, RR 22, diffuse expiratory wheeze, prolonged expiration. No accessory muscle use.
    Treatment: Albuterol nebulizer treatment 2.5 mg given in clinic, post-treatment SpO2 94%, wheeze improved.
    A/P: Acute exacerbation of her COPD. Prednisone 40 mg x5 days, doxycycline x5 days, continue tiotropium. Return precautions given, ER if worse.
    MDM: moderate. E/M separately identifiable from the nebulizer treatment.
  N
  "Depression and insomnia follow-up" => <<~N,
    CC: Mood follow-up, established patient.
    HPI: 41 y/o with major depressive disorder, recurrent, moderate, on sertraline 100 mg for 8 weeks. PHQ-9 today 12, down from 19. Reports insomnia with sleep onset delay 60+ minutes most nights, no early waking. Denies SI/HI.
    Exam: Alert, cooperative, affect brighter than last visit.
    A/P: 1. Major depressive disorder, recurrent, moderate, improving, increase sertraline to 150 mg. 2. Insomnia, sleep hygiene reviewed, CBT-I referral, no hypnotic for now.
    MDM: moderate (chronic illness with progression, prescription drug management).
  N
  "Type 2 diabetes, uncontrolled on insulin" => <<~N,
    CC: Diabetes follow-up, established patient.
    HPI: 61 y/o with type 2 diabetes, uncontrolled, A1c 9.4 last month, on insulin glargine 30 units nightly plus metformin. Fasting glucose 190-240. No hypoglycemia. Denies neuropathic symptoms.
    Exam: BMI 33, feet without lesions, sensation intact.
    A/P: Diabetes with hyperglycemia. Increase insulin glargine to 36 units, titration instructions given, RTC 4 weeks, CDE referral. Long-term insulin use documented.
    MDM: moderate.
  N
}
NOTES.each_with_index do |(title, note), i|
  Encounter.find_or_create_by!(patient_ref: format("PT-%04d", 1000 + i)) do |e|
    e.provider = ["Dr. Okafor", "Dr. Lindqvist", "Dr. Ramaswamy", "PA Brennan"][i % 4]
    e.date_of_service = Date.new(2026, 9, 8) + i
    e.note = "#{title}\n\n#{note}"
  end
end

GOLD = [
  ["Diabetes and hypertension follow-up", NOTES.values[0], %w[E11.9 I10 E78.5], %w[99214 36415]],
  ["New patient, sore throat",            NOTES.values[1], %w[J02.0],            %w[99203 87880]],
  ["Right knee OA, injection",            NOTES.values[2], %w[M17.11 I10],       %w[99213 20610]],
  ["Hand laceration",                     NOTES.values[3], %w[S61.411A],         %w[12001]],
  ["Bilateral cerumen",                   NOTES.values[4], %w[H61.23],           %w[69210]],
  ["Annual preventive with flu shot",     NOTES.values[5], %w[Z00.00 Z23],       %w[99396 90686 90471]],
  ["COPD exacerbation",                   NOTES.values[6], %w[J44.1],            %w[99214 94640]],
  ["Depression and insomnia",             NOTES.values[7], %w[F33.1 G47.00],     %w[99214]],
  ["Uncontrolled T2DM on insulin",        NOTES.values[8], %w[E11.65 Z79.4],     %w[99214]],
  ["UTI with dipstick", "CC: Dysuria x2 days, established patient. HPI: 29 y/o with dysuria, frequency, no fever, no flank pain. Exam: Suprapubic tenderness, no CVA tenderness. Urine dipstick in clinic positive for leukocyte esterase and nitrite. A/P: Urinary tract infection, nitrofurantoin x5 days. MDM: low.", %w[N39.0], %w[99213 81002]],
  ["Viral URI", "CC: Congestion and cough x4 days, established patient. HPI: 38 y/o with nasal congestion, cough, low-grade temp, no dyspnea. Exam: T 99.4, TMs normal, pharynx mildly erythematous without exudate, lungs clear. A/P: Viral URI, supportive care, return if worse. MDM: straightforward.", %w[J06.9], %w[99212]],
  ["Atrial fibrillation with ECG", "CC: Palpitations, established patient. HPI: 70 y/o with intermittent palpitations x1 week, no syncope, no chest pain. Exam: Irregularly irregular rhythm, rate 96. 12-lead ECG in clinic interpreted by me: atrial fibrillation, rate 94, no acute ST changes. A/P: Atrial fibrillation, new. Start apixaban after CHA2DS2-VASc discussion, cardiology referral, echo ordered. MDM: high.", %w[I48.91], %w[99215 93000]],
  ["Right lower leg cellulitis", "CC: Red painful right shin, established patient. HPI: 55 y/o with 3 days of spreading redness and warmth on the right lower leg after a scratch, no fever, no drainage. Exam: 8x6 cm erythema, warmth, tenderness, no fluctuance, no abscess. A/P: Cellulitis of the right lower leg, cephalexin x7 days, mark borders, return in 48 hours. MDM: moderate.", %w[L03.115], %w[99214]],
  ["Actinic keratoses cryotherapy", "CC: Rough spots on forehead, established patient. HPI: 63 y/o with three scaly lesions on the forehead x months. Exam: Three 4-6 mm rough erythematous papules consistent with actinic keratoses. Procedure: Cryotherapy with liquid nitrogen to all three lesions, 2 freeze-thaw cycles each, tolerated well. A/P: Actinic keratosis x3, treated. Sun protection counseled. Recheck 8 weeks.", %w[L57.0], %w[17000 17003]],
  ["Generalized anxiety follow-up", "CC: Anxiety follow-up, established patient. HPI: 33 y/o with generalized anxiety disorder on escitalopram 10 mg, GAD-7 today 9 from 16. No side effects. Denies depression, denies SI. A/P: Generalized anxiety disorder, improving, continue escitalopram, RTC 3 months. MDM: low.", %w[F41.1], %w[99213]],
  ["Pneumonia with fever and cough", "CC: Cough and fever, established patient. HPI: 45 y/o with productive cough and fever to 102 for 3 days, pleuritic right-sided pain, no dyspnea at rest. Exam: T 101.6, SpO2 95%, crackles right base. Chest x-ray from urgent care yesterday shows right lower lobe consolidation. A/P: Community-acquired pneumonia, right lower lobe, amoxicillin-clavulanate x7 days, return precautions. MDM: moderate.", %w[J18.9], %w[99214]],
]
GOLD.each { |t, n, dx, px| EvalCase.find_or_create_by!(title: t) { |c| c.note = n; c.gold_dx = dx; c.gold_px = px } }
puts "seeded: #{CodeSet.count} codes, #{Excludes1Rule.count} excludes1, #{Encounter.count} encounters, #{EvalCase.count} eval cases"

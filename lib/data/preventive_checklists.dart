class PreventiveVisit {
  final int visitNumber;
  final String ageLabel;
  final List<PreventiveSection> sections;
  const PreventiveVisit({required this.visitNumber, required this.ageLabel, required this.sections});
}

class PreventiveSection {
  final String title;
  final List<String> items;
  const PreventiveSection({required this.title, required this.items});
}

const List<PreventiveVisit> preventiveVisits = [
  PreventiveVisit(visitNumber: 1, ageLabel: 'NEWBORN (BIRTH, PRE-DISCHARGE)', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Birth wt',
      'length',
      'head circumference',
      'gestational age',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Full exam',
      'hips (Ortolani/Barlow)',
      'red reflex',
      'cardiac exam',
      'femoral pulses',
      'SpO2 (CCHD)',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'BCG',
      'OPV-0',
      'Hep B-1 (within 24 h)',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Newborn screening: TSH (minimum)',
      'expanded NBS (CAH/17-OHP, G6PD, GALT, PKU, biotinidase) where available',
      'CCHD pulse oximetry',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Newborn hearing (OAE/BERA) done',
      'red reflex checked',
      'Palate/gums inspected',
      'check for oral thrush',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Newborn behaviour, tone & feeding cues observed',
      'Maternal wellbeing & bonding noted',
      'postpartum depression risk asked',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Exclusive breastfeeding counselled',
      'warmth/thermal care',
      'danger signs explained',
      'safe sleep (back, firm surface, no soft bedding)',
      'birth registration',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 2, ageLabel: '3-5 DAYS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight (assess loss <10% of birth wt)',
      'jaundice level',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Weight trend',
      'hydration',
      'cord',
      'jaundice (Kramer/TcB)',
      'tone',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Complete any missed birth doses',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Bilirubin ONLY if clinically jaundiced (risk-based)',
      'repeat NBS if first sample missed',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Confirm newborn hearing screen completed',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Feeding adequacy & alertness assessed',
      'Maternal EPDS if any concern',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Latch & feeding support given',
      'jaundice warning signs',
      'when to return urgently explained',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 3, ageLabel: '1 MONTH', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'length',
      'head circumference',
      'plotted on WHO chart',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Fontanelle',
      'eyes/red reflex',
      'heart',
      'hips',
      'genitalia',
      'social smile emerging',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Confirm Hep B-2 given with 6-wk combo (if applicable)',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab due',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Eyes tracked',
      'startle to sound checked',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Surveillance: fixes & follows',
      'responds to sound',
      'Maternal postpartum depression screen (EPDS)',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Feeding on demand',
      'tummy time',
      'safe sleep',
      'no honey',
      'counsel for 6-week immunisation',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 4, ageLabel: '6 WEEKS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'length',
      'head circumference',
      'plotted',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'General exam',
      'hips',
      'eyes',
      'heart',
      'developmental surveillance',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'DTwP-1 (or DTaP)',
      'IPV-1',
      'Hib-1',
      'Hep B-2',
      'PCV-1',
      'Rotavirus-1',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab due',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Visual tracking & sound response checked',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Fix & follow',
      'cooing noted',
      'Maternal EPDS',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Post-vaccination fever advice',
      'feeding',
      'developmental play',
      'fall prevention',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 5, ageLabel: '10 WEEKS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'length',
      'head circumference',
      'plotted',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Surveillance exam',
      'muscle tone',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'DTwP-2',
      'IPV-2',
      'Hib-2',
      'PCV-2',
      'Rotavirus-2',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab due',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Eyes tracked',
      'sound response',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Vocalises',
      'head control improving',
      'Maternal EPDS if indicated',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Feeding',
      'tummy time',
      'car/2-wheeler safety',
      'smoke-free home',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 6, ageLabel: '14 WEEKS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'length',
      'head circumference',
      'plotted',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Surveillance exam',
      'hips recheck',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'DTwP-3',
      'IPV-3',
      'Hib-3',
      'PCV-3',
      'Rotavirus-3 (RV-3 not needed for monovalent RV1)',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab due',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Eyes tracked',
      'localises sound',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Reaches & grasps',
      'laughs',
      'Behaviour surveillance',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Weaning readiness (start 6 mo)',
      'safe play',
      'heat/burn safety',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 7, ageLabel: '6 MONTHS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'length',
      'head circumference',
      'plotted',
      'note growth velocity',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
      'teeth eruption',
      'sits with support',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Hep B-3 (if not in combo)',
      'Influenza dose 1 (2 doses 4 wk apart first season)',
      'TCV may begin',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab/screen due routine (haemoglobin due at 12 mo)',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Fix/follow both eyes',
      'turns to sound',
      'First teeth',
      'wipe gums',
      'plan dental visit by 12 mo',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'MEB screen',
      'sits',
      'transfers objects',
      'stranger awareness',
      'Child MEB screen begins (per AAP 2025)',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Start complementary feeding + continue breastfeeding',
      'iron-rich foods',
      'no screen time under 2 y',
      'drowning/bucket safety',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 8, ageLabel: '9 MONTHS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'length',
      'head circumference',
      'plotted',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
      'pincer grasp',
      'pulls to stand',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'MMR-1',
      'Influenza dose 2 (if first season)',
      'OPV (optional)',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab due',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Cover test',
      'responds to name/sound',
      'Gums/first teeth',
      'fluoride per local water',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'DEVELOPMENTAL SCREEN (ASQ / TDSC / DDST)',
      'crawls',
      'babbles',
      'waves',
      'Developmental screen',
      'parent-child interaction observed',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Object-permanence play',
      'home-proofing',
      'choking hazards',
      'responsive feeding',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 9, ageLabel: '12 MONTHS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'length',
      'head circumference',
      'plotted',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
      'stands',
      'first steps',
      'anterior fontanelle',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Hep A-1',
      'annual Influenza',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Haemoglobin (anaemia screen) - high Indian prevalence',
      'TSH/others only if risk',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Vision & hearing surveillance',
      'First dental visit due',
      'brush with fluoride toothpaste (rice-grain smear)',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'MEB surveillance',
      'jargon',
      '1-2 words',
      'points',
      'MEB screen (12-month)',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Cup weaning',
      'family foods',
      'walking safety',
      'iron & vitamin D from diet/sun',
      'screen-time limits',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 10, ageLabel: '15 MONTHS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'length',
      'head circumference',
      'plotted',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
      'gait',
      'play',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'MMR-2',
      'Varicella-1',
      'PCV booster',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab due',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Vision/hearing tracked',
      'Brushing twice daily (supervised)',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Surveillance',
      '3-5 words',
      'follows simple command',
      'Behaviour surveillance',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Language stimulation',
      'tantrum guidance',
      'medicine/poison lock-away',
      'helmet on 2-wheelers',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 11, ageLabel: '18 MONTHS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'length',
      'head circumference',
      'plotted',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
      'runs',
      'stacks blocks',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'DTwP B1 (or DTaP), IPV B1, Hib B1',
      'Hep A-2 (killed, 6 mo after dose 1)',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab due',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Vision/hearing surveillance',
      'Dental review',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'DEVELOPMENTAL SCREEN + AUTISM SCREEN (M-CHAT-R/F)',
      'M-CHAT-R/F (autism)',
      'MEB',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Toilet-training readiness',
      'screen time',
      'reading aloud',
      'discipline without harm',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 12, ageLabel: '24 MONTHS (2 YEARS)', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'standing height',
      'head circumference',
      'BMI (from 2 y)',
      'plotted',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
      'consider starting BP',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Annual Influenza',
      'catch-up as needed',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Repeat haemoglobin if prior anaemia or ongoing risk',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Vision (instrument if available)',
      'hearing',
      '6-monthly dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'AUTISM SCREEN (M-CHAT-R/F)',
      '2-word phrases',
      '50+ words',
      'MEB (24-month) + autism screen',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Balanced diet',
      'active play',
      'limit screens',
      'dental hygiene',
      'pedestrian road safety',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 13, ageLabel: '30 MONTHS (2.5 YEARS)', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI',
      'plotted',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Catch-up as needed',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab due',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Vision/hearing surveillance',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'DEVELOPMENTAL SCREEN',
      'sentences',
      'understands prepositions',
      'Developmental screen (30-month)',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Preschool readiness',
      'social play',
      'sleep routine',
      'screen-time quality',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 14, ageLabel: '3 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP (begins at 3 y)',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
      'BP measurement begins',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Catch-up as needed',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab due (BP is a vital, not a lab)',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'VISION screening (chart) + HEARING screening',
      '6-monthly dental',
      'fluoride',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Behaviour surveillance',
      'speech intelligibility',
      'SDQ if behaviour concern',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Preschool',
      'nutrition & obesity prevention',
      'outdoor play',
      'injury prevention',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 15, ageLabel: '4 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'DTwP B2 (or DTaP), IPV B2, MMR-3, Varicella-2',
      'annual Influenza',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab due',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'VISION + HEARING screening',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Behaviour surveillance',
      'school readiness',
      'SDQ / behaviour screen if indicated',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'School readiness',
      'healthy weight',
      'screen limits',
      'helmet & road safety',
      'good-touch/bad-touch',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 16, ageLabel: '5 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP',
      'switch to IAP 5-18 charts',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Catch-up',
      'Typhoid booster if due',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab due',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'VISION + HEARING screening',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'School-performance surveillance',
      'Behaviour/attention screen if concern',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'School adjustment',
      'nutrition',
      'physical activity 60 min/day',
      'sleep hygiene',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 17, ageLabel: '6 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
      'posture/scoliosis awareness',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Catch-up as needed',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab due',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'VISION + HEARING screening',
      '6-monthly dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Attention & learning surveillance',
      'SDQ / Vanderbilt (ADHD) if concern',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Reading',
      'screen time',
      'bullying',
      'road & water safety',
      'balanced diet',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 18, ageLabel: '7 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Catch-up as needed',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab due',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Vision/hearing surveillance',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Learning surveillance',
      'Behaviour screen if concern',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Physical activity',
      'limit sugary drinks',
      'sleep',
      'peer relationships',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 19, ageLabel: '8 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
      'puberty-staging awareness',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Catch-up as needed',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm no routine lab due',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'VISION + HEARING screening',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Learning surveillance',
      'SDQ if concern',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Screen & sleep',
      'media safety',
      'nutrition',
      'injury prevention',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 20, ageLabel: '9 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP',
      'Tanner staging',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
      'early-puberty check',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Consider HPV planning (9-14 y window)',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'LIPID / cholesterol screen (universal, once at 9-11 y)',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Vision/hearing surveillance',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Learning & mood surveillance',
      'Mood surveillance',
      'begin adolescent rapport',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Puberty education',
      'nutrition',
      'activity',
      'screen & sleep',
      'emotional literacy',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 21, ageLabel: '10 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP',
      'Tanner',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
      'scoliosis',
      'puberty',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Catch-up',
      'HPV may start (2-dose 9-14 y)',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Complete lipid screen if not done at 9 y',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'VISION + HEARING screening',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Mood & learning surveillance',
      'Mood surveillance',
      'psychosocial rapport',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Puberty',
      'peer pressure',
      'body image',
      'physical activity',
      'screen limits',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 22, ageLabel: '11 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP',
      'Tanner',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
      'puberty',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Tdap',
      'HPV (2-dose if 9-14 y)',
      'annual Influenza',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Consider haemoglobin in menstruating/at-risk girls',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Vision/hearing surveillance',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'HEEADSSS begins',
      'academic & social',
      'DEPRESSION screen (PHQ-2/PHQ-9A) begins',
      'SUBSTANCE-USE screen (CRAFFT/S2BI) begins',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Confidentiality framing',
      'puberty',
      'substance & tobacco',
      'mood',
      'sleep',
      'online safety',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 23, ageLabel: '12 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP',
      'Tanner',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
      'puberty',
      'scoliosis',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Complete HPV/Tdap',
      'annual Influenza',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Haemoglobin if menstruating/at-risk',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Vision/hearing surveillance',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'HEEADSSS',
      'identity & autonomy',
      'DEPRESSION (annual) + SUICIDE-RISK screen (ASQ) + ANXIETY (SCARED) begins',
      'substance use (CRAFFT)',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Mental-health rapport',
      'relationships',
      'consent',
      'body image',
      'social media',
      'RTA/helmet',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 24, ageLabel: '13 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP',
      'Tanner',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Catch-up (HPV/Tdap/MMR/varicella as needed)',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Haemoglobin if at risk',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Vision/hearing surveillance',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'HEEADSSS',
      'Depression + suicide-risk + anxiety + substance use (annual)',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Identity',
      'peer & risk behaviour',
      'nutrition',
      'screen & sleep',
      'safety',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 25, ageLabel: '14 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP',
      'Tanner',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Govt UIP HPV for 14-y girls (2026)',
      'catch-up',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Haemoglobin if at risk',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Vision/hearing surveillance',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'HEEADSSS',
      'academic stress',
      'Depression + suicide-risk + anxiety + substance use (annual)',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Exam stress & mental health',
      'substance',
      'sexuality & consent',
      'RTA',
      'digital wellbeing',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 26, ageLabel: '15 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP',
      'Tanner',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'HPV single-dose acceptable 9-15 y (immunocompetent)',
      'catch-up',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'HIV screen once (15-21 y)',
      'STI if sexually active',
      'haemoglobin if at risk',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'HEARING (once 15-17 y)',
      'vision as needed',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'HEEADSSS',
      'Depression + suicide-risk + anxiety + substance use (annual)',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Autonomy',
      'risk reduction',
      'mental health',
      'contraception counselling as appropriate',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 27, ageLabel: '16 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP',
      'Tanner',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Td (16-18 y)',
      'catch-up',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'STI if sexually active',
      'haemoglobin if at risk',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Vision/hearing as needed',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'HEEADSSS',
      'future planning',
      'Depression + suicide-risk + anxiety + substance use (annual)',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Career/exam stress',
      'driving safety',
      'substance',
      'relationships',
      'sleep',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 28, ageLabel: '17 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI percentile',
      'BP',
      'Tanner',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Catch-up as needed',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Repeat lipid (once 17-21 y)',
      'STI/HIV as indicated',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'HEARING (once 15-17 y)',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'HEEADSSS',
      'Depression + suicide-risk + anxiety + substance use (annual)',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Transition planning',
      'independence',
      'mental health',
      'substance',
      'safe driving',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 29, ageLabel: '18 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI',
      'BP',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
      'adult transition',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Td if not given',
      'adult catch-up (HPV up to 26 y)',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Lipid if not done',
      'STI/HIV as indicated',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'Vision/hearing as needed',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'HEEADSSS',
      'transition to adult care',
      'Depression + suicide-risk + anxiety + substance use (annual)',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Transition-to-adult-care plan',
      'self-management',
      'mental health',
      'lifestyle',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 30, ageLabel: '19-20 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI',
      'BP',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Exam',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Adult catch-up as needed',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'STI/HIV as indicated',
      'lipid if not done 17-21 y',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'As needed',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Mental-health & psychosocial review',
      'Depression + anxiety + substance use (annual)',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Independence',
      'occupational health',
      'mental health',
      'substance',
      'reproductive health',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
  PreventiveVisit(visitNumber: 31, ageLabel: '21 YEARS', sections: [
    PreventiveSection(title: 'Measurements & Growth', items: [
      'Weight',
      'height',
      'BMI',
      'BP',
    ]),
    PreventiveSection(title: 'Physical Examination', items: [
      'Final paediatric exam',
      'handover',
    ]),
    PreventiveSection(title: 'Immunisations Due', items: [
      'Confirm adult schedule complete',
    ]),
    PreventiveSection(title: 'Laboratory & Screening', items: [
      'Confirm lipid & HIV done once in 18-21 y window',
    ]),
    PreventiveSection(title: 'Vision / Hearing / Dental', items: [
      'As needed',
      'Dental',
    ]),
    PreventiveSection(title: 'Development & Mental-Behavioural Health', items: [
      'Confirm transition to adult provider',
      'Depression + anxiety + substance use',
      'transition summary',
    ]),
    PreventiveSection(title: 'Anticipatory Guidance', items: [
      'Complete transfer to adult care with summary',
      'self-advocacy',
      'preventive-care literacy',
    ]),
    PreventiveSection(title: 'Referrals Considered', items: [
      'Ophthalmology - if abnormal red reflex, squint, leukocoria, or failed vision screen',
      'ENT / Audiology - if failed hearing screen, speech delay, recurrent otitis, or OSA symptoms',
      'Dental - if caries, delayed eruption, trauma, or no visit by 12 months',
      'Child mental health - if any positive screen; SUICIDE-RISK positive = urgent, do not leave alone',
      'Development / early intervention - if screen-positive delay, regression, or M-CHAT positive',
      'No referral required at this visit',
    ]),
  ]),
];

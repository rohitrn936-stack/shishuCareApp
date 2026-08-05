const Map<String, List<Map<String, String>>> screeningChecklists = {
  "Birth - 6 Weeks": [
    {
      "title": "Growth",
      "description": "Weight, length, head circumference plotted on WHO growth chart.",
      "redFlag": "Weight loss >10% from birth wt not regained by 2 wks; HC <32cm or >37cm.",
      "unit": "kg / cm",
    },
    {
      "title": "Nutrition",
      "description": "Exclusive breastfeeding check, latch assessment.",
      "redFlag": "Poor feeding, no wet nappies in 6hrs, jaundice extending to palms/soles.",
      "unit": "",
    },
    {
      "title": "Blood Test",
      "description": "Newborn metabolic/TSH screening (where available), bilirubin if jaundiced.",
      "redFlag": "Persistent/worsening jaundice, pallor.",
      "unit": "mg/dL",
    },
    {
      "title": "Vision & Hearing",
      "description": "Red reflex, startle/blink to sound.",
      "redFlag": "Absent red reflex, no startle response.",
      "unit": "",
    },
    {
      "title": "Danger Signs",
      "description": "Temperature, activity, cry, breathing.",
      "redFlag": "Fever, lethargy, poor cry, fast/laboured breathing, convulsions.",
      "unit": "°C",
    },
  ],

  "6 Weeks - 6 Months": [
    {
      "title": "Growth & Nutrition",
      "description": "Weight/length/HC monthly; breastfeeding + complementary feeding readiness at 6m.",
      "redFlag": "Weight faltering (crossing 2 centile lines), no interest in feeding.",
      "unit": "kg / cm",
    },
    {
      "title": "Hemoglobin",
      "description": "Hb check at 6 months (iron stores depleting).",
      "redFlag": "Hb <11 g/dL -> anemia workup.",
      "unit": "g/dL",
    },
    {
      "title": "Development",
      "description": "Social smile (6-8wk), head control (3-4m), rolling, reaching (6m).",
      "redFlag": "No social smile by 3m, no head control by 4m.",
      "unit": "",
    },
    {
      "title": "Vaccination",
      "description": "OPV/DTP/Hep B/Hib/PCV/Rota per schedule at 6, 10, 14 weeks.",
      "redFlag": "Missed doses, delayed catch-up needed.",
      "unit": "",
    },
    {
      "title": "Danger Signs",
      "description": "Breathing, feeding, fever, seizures.",
      "redFlag": "Chest indrawing, refusal to feed, fever >38C in <3m old.",
      "unit": "°C",
    },
  ],

  "6 - 12 Months": [
    {
      "title": "Growth & Nutrition",
      "description": "Weight/length/HC; complementary feeding diversity check.",
      "redFlag": "Stunting (length-for-age <-2SD), no diet diversity by 8m.",
      "unit": "kg / cm",
    },
    {
      "title": "Hemoglobin / Anemia",
      "description": "Hb re-check if risk factors (low birth weight, poor diet).",
      "redFlag": "Hb <11 g/dL, pallor, lethargy.",
      "unit": "g/dL",
    },
    {
      "title": "Development",
      "description": "Sitting (8m), crawling, pincer grasp, babbling -> first words (12m).",
      "redFlag": "Not sitting by 9m, no babbling by 9m.",
      "unit": "",
    },
    {
      "title": "Vaccination",
      "description": "MMR/other 9-month doses.",
      "redFlag": "Missed measles dose -> outbreak risk.",
      "unit": "",
    },
    {
      "title": "Vision & Hearing",
      "description": "Object tracking, response to name.",
      "redFlag": "No response to name by 12m, no eye contact.",
      "unit": "",
    },
  ],

  "1 - 2 Years": [
    {
      "title": "Growth & Nutrition",
      "description": "Weight-for-height, MUAC tape at 1y+.",
      "redFlag": "MUAC <11.5cm (SAM), edema (kwashiorkor).",
      "unit": "cm",
    },
    {
      "title": "Blood Glucose",
      "description": "Only if lethargy, poor feeding, or family history of metabolic disorder.",
      "redFlag": "Random glucose <45 or >200 mg/dL.",
      "unit": "mg/dL",
    },
    {
      "title": "Hemoglobin",
      "description": "Hb at 12 months mandatory (India-specific high anemia burden).",
      "redFlag": "Hb <11 g/dL.",
      "unit": "g/dL",
    },
    {
      "title": "Development",
      "description": "Walking (12-15m), 2-word phrases (18m), pointing to show interest.",
      "redFlag": "Not walking by 18m, no words by 16m, no pointing by 18m.",
      "unit": "",
    },
    {
      "title": "Vaccination",
      "description": "16-18 month boosters (DTP, OPV, Hep A).",
      "redFlag": "Missed booster doses.",
      "unit": "",
    },
    {
      "title": "Danger Signs",
      "description": "Persistent diarrhea, chronic cough, recurrent illness.",
      "redFlag": "Diarrhea >14 days, weight loss during illness.",
      "unit": "",
    },
  ],

  "2 - 3 Years": [
    {
      "title": "Growth & Nutrition",
      "description": "Weight-for-height, MUAC, dietary diversity score.",
      "redFlag": "Wasting, stunting trend on 2 consecutive visits.",
      "unit": "cm",
    },
    {
      "title": "Development",
      "description": "M-CHAT-R/F autism screen (24m), 2-word sentences, run/climb.",
      "redFlag": "Failed M-CHAT-R/F, regression of skills, no 2-word phrases by 24m.",
      "unit": "",
    },
    {
      "title": "Vision & Hearing",
      "description": "Basic vision screen if tools available.",
      "redFlag": "Squint, white pupillary reflex (leukocoria).",
      "unit": "",
    },
    {
      "title": "Vaccination",
      "description": "Catch-up check for any missed schedule doses.",
      "redFlag": "Incomplete primary series by age 2.",
      "unit": "",
    },
    {
      "title": "Behavioral",
      "description": "Basic social/emotional check with caregiver.",
      "redFlag": "Extreme tantrums, no interactive play, self-injury.",
      "unit": "",
    },
  ],

  "3 - 5 Years": [
    {
      "title": "Growth & Nutrition",
      "description": "BMI trend, MUAC, annual dietary recall.",
      "redFlag": "Rapid weight gain or persistent underweight.",
      "unit": "kg/m²",
    },
    {
      "title": "Hemoglobin",
      "description": "Annual Hb check.",
      "redFlag": "Hb <11.5 g/dL.",
      "unit": "g/dL",
    },
    {
      "title": "Blood Glucose",
      "description": "If overweight + family history, or recurrent infections/excessive thirst.",
      "redFlag": "Fasting glucose >=126 mg/dL or random >=200 mg/dL with symptoms.",
      "unit": "mg/dL",
    },
    {
      "title": "Development",
      "description": "Speech clarity, counting, drawing, following 3-step instructions.",
      "redFlag": "Unintelligible speech at 4y, cannot follow simple instructions by 5y.",
      "unit": "",
    },
    {
      "title": "Vision & Hearing",
      "description": "Formal vision chart screening (age 3+), audiometry if available.",
      "redFlag": "Vision <6/12 in either eye, failed hearing screen.",
      "unit": "",
    },
    {
      "title": "Vaccination",
      "description": "DTP/OPV 5-year booster.",
      "redFlag": "Missed booster.",
      "unit": "",
    },
    {
      "title": "Behavioral & Emotional",
      "description": "Caregiver-reported behavior, social interaction with peers.",
      "redFlag": "Social withdrawal, aggression, developmental regression.",
      "unit": "",
    },
  ],
};

const List<String> universalRedFlags = [
  "Lethargy, reduced activity, or unresponsiveness",
  "Refusal to feed or drink for >2 feeds",
  "Convulsions/seizures of any kind",
  "Fast breathing or chest indrawing",
  "Severe palmar pallor or visible edema (both feet)",
  "Temperature >=38C in infant <3 months, or >=40C at any age",
  "Any loss of a previously acquired skill (developmental regression)",
  "MUAC <11.5cm or weight-for-height <-3SD (Severe Acute Malnutrition)",
];
import { GoogleGenAI } from "@google/genai";
import { PromptDetails, PromptData } from "../types";

export async function generateFunnyLine(details: PromptDetails): Promise<string> {
    if (!process.env.API_KEY) {
        throw new Error("API_KEY environment variable not set");
    }
    const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

    const metaPrompt = `
    أنت كاتب سيناريو متخصص في كتابة حوارات أطفال مضحكة وطبيعية.
    مهمتك هي ابتكار جملة واحدة عفوية ومضحكة مناسبة لطفل بالمواصفات التالية.
    يجب أن تكون الجملة باللهجة المصرية العامية، كما يتحدث بها الأطفال.
    الناتج النهائي يجب أن يكون الجملة المضحكة فقط، بدون أي مقدمات أو شرح أو علامات اقتباس.

    **مواصفات الشخصية:**
    - جنس الطفل: ${details.gender}
    - عمر الطفل: ${details.age || 'غير محدد'} شهر
    - التصنيف: ${details.category}
    - الموقف/السياق: ${details.situation || 'عام'}
    - نبرة الصوت: ${details.tone || 'عادية'}

    **مثال للناتج (لو الموقف عن الأكل):**
    أنا مش عايز آكل سبانخ، دي شكلها شبه الشجر الزعلان.

    الآن، قم بتأليف جملة طفولية مضحكة بناءً على المواصفات المعطاة.
    `;

    try {
        const response = await ai.models.generateContent({
            model: "gemini-2.5-flash",
            contents: metaPrompt,
        });
        return response.text.trim().replace(/^"|"$/g, ''); // Remove quotes if any
    } catch (error) {
        console.error("Error generating funny line:", error);
        if (error instanceof Error) {
            throw new Error(`مشكلة في ابتكار الجملة: ${error.message}`);
        }
        throw new Error("خطأ غير معروف واحنا بنكتب الجملة.");
    }
}


export async function generatePronunciationPrompt(data: PromptData): Promise<string> {
  if (!process.env.API_KEY) {
    throw new Error("API_KEY environment variable not set");
  }

  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

  // Translate gender for the English prompt
  const genderInEnglish = {
    'ولد': 'Boy',
    'بنت': 'Girl'
  }[data.gender];

  // Translate category
  const categoryInEnglish = {
      'كوميدي': 'Comedic',
      'إعلان': 'Advertisement',
      'مشهد سينمائي': 'Cinematic Scene',
      'غير محدد': 'General'
  }[data.category];

  const metaPrompt = `
You are a top-tier prompt engineer specializing in creating advanced prompts for generative Text-to-Speech (TTS) and animation AI models.
Your task is to generate a highly detailed, professional, and effective prompt in English based on the provided specifications.
The final output must ONLY be the generated English prompt, structured for clarity and immediate use. Do not include any other text, greetings, or explanations.

**User-Provided Specifications:**
- Character Type: Child
- Gender: ${genderInEnglish}
- Age: ${data.age || 'Not specified'} months old
- Category/Use-Case: ${categoryInEnglish}
- Situation/Context: ${data.situation || 'General context'}
- Vocal Tone/Emotion: ${data.tone || 'Neutral'}
- Line to be spoken (Egyptian Arabic): ${data.line}

**Prompt Generation Instructions:**
1.  **Structure:** Create a well-structured prompt. Start with a clear objective.
2.  **Vocal Characteristics:** Clearly define the child's voice profile based on age, gender, and tone.
3.  **Performance Direction:** Provide clear acting direction based on the situation and category. For a 'Cinematic Scene', be more dramatic. For 'Comedic', emphasize timing. For an 'Advertisement', sound more energetic and persuasive.
4.  **Lip-Sync Mandate:** **Crucially**, include a specific instruction for the animation model to generate precise, high-fidelity lip-sync movements that perfectly match the Egyptian Arabic phonetics.
5.  **Pronunciation Guide:** Include the original Egyptian Arabic line as a definitive pronunciation guide. This is non-negotiable.

**Example Output Structure:**
"""
**TTS & Animation Prompt**

**Objective:** Generate a high-quality audio clip and corresponding lip-sync animation for a child character.

**Character Profile:**
- **Type:** Child
- **Gender:** [Gender]
- **Age:** [Age] months old
- **Vocal Style:** [Describe vocal style, e.g., 'A clear, slightly high-pitched voice of a toddler, with natural speech patterns.']

**Performance Notes:**
- **Context:** The character is in the following situation: [Situation].
- **Emotion/Tone:** The delivery should be [Tone].
- **Pacing:** [Suggest pacing, e.g., 'Slightly fast-paced and excited.'].
- **Category Nuance:** As this is for a [Category] piece, ensure the performance aligns (e.g., '...has a playful, comedic timing.').

**Core Dialogue:**
- **Line:** "${data.line}"
- **Language:** Egyptian Arabic

**Technical Directives:**
- **Audio Output:** 24-bit, 48kHz, WAV format, mono.
- **Lip-Sync:** CRITICAL - Generate precise, frame-accurate lip-sync animation. The mouth movements must perfectly match the provided Egyptian Arabic audio. Pay close attention to vowels and consonant shapes specific to the dialect.
"""

Now, generate the professional prompt based on the user's specifications.
`;


  try {
    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: metaPrompt,
    });
    // Clean up the response to ensure it's just the prompt
    return response.text.trim().replace(/^"""|"""$/g, '').trim();
  } catch (error) {
    console.error("Error generating prompt with Gemini:", error);
    if (error instanceof Error) {
        return `حصل مشكلة واحنا بنصيغ البرومبت: ${error.message}`;
    }
    return "حصل خطأ غير معروف، حاول تاني.";
  }
}

export interface PromptDetails {
  age: string; // Will now represent months
  gender: 'ولد' | 'بنت';
  situation: string;
  tone: string;
  category: 'كوميدي' | 'إعلان' | 'مشهد سينمائي' | 'غير محدد';
}

export interface PromptData extends PromptDetails {
  line: string;
}

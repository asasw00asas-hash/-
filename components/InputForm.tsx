import React from 'react';
import { PromptDetails } from '../types';
import { GenerateIcon } from './icons/GenerateIcon';
import { LoadingIcon } from './icons/LoadingIcon';

interface InputFormProps {
  formData: PromptDetails;
  setFormData: React.Dispatch<React.SetStateAction<PromptDetails>>;
  onGenerate: () => void;
  isLoading: boolean;
}

const InputForm: React.FC<InputFormProps> = ({ formData, setFormData, onGenerate, isLoading }) => {
  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  return (
    <div className="bg-slate-800/50 backdrop-blur-sm rounded-xl p-6 border border-slate-700 shadow-2xl flex flex-col overflow-hidden">
      <h2 className="text-2xl font-semibold mb-6 text-cyan-400">ادخل مواصفات شخصية الطفل</h2>
      <div className="flex-grow overflow-y-auto pr-2 -mr-2 space-y-4">
        
        <div className="grid grid-cols-2 gap-4">
            <div>
                <label htmlFor="age" className="block text-sm font-medium text-slate-400 mb-1">العمر بالشهور</label>
                <input
                    type="number"
                    id="age"
                    name="age"
                    value={formData.age}
                    onChange={handleChange}
                    placeholder="مثلاً: 18"
                    className="w-full bg-slate-700/50 border border-slate-600 rounded-md py-2 px-3 text-slate-200 placeholder-slate-500 focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500 outline-none transition"
                />
            </div>
            <div>
                <label htmlFor="gender" className="block text-sm font-medium text-slate-400 mb-1">الجنس</label>
                <select
                    id="gender"
                    name="gender"
                    value={formData.gender}
                    onChange={handleChange}
                    className="w-full bg-slate-700/50 border border-slate-600 rounded-md py-2 px-3 text-slate-200 focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500 outline-none transition"
                >
                    <option>ولد</option>
                    <option>بنت</option>
                </select>
            </div>
        </div>

        <div>
            <label htmlFor="category" className="block text-sm font-medium text-slate-400 mb-1">التصنيف</label>
            <select
                id="category"
                name="category"
                value={formData.category}
                onChange={handleChange}
                className="w-full bg-slate-700/50 border border-slate-600 rounded-md py-2 px-3 text-slate-200 focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500 outline-none transition"
            >
                <option>كوميدي</option>
                <option>إعلان</option>
                <option>مشهد سينمائي</option>
                <option>غير محدد</option>
            </select>
        </div>

        <div>
            <label htmlFor="situation" className="block text-sm font-medium text-slate-400 mb-1">الموقف/السياق</label>
            <textarea
                id="situation"
                name="situation"
                value={formData.situation}
                onChange={handleChange}
                placeholder="مثلاً: بيكلم لعبته، بيطلب حاجة من مامته، بيحكي قصة خيالية..."
                rows={3}
                className="w-full bg-slate-700/50 border border-slate-600 rounded-md py-2 px-3 text-slate-200 placeholder-slate-500 focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500 outline-none transition"
            />
        </div>
        
        <div>
            <label htmlFor="tone" className="block text-sm font-medium text-slate-400 mb-1">نبرة الصوت</label>
            <input
                type="text"
                id="tone"
                name="tone"
                value={formData.tone}
                onChange={handleChange}
                placeholder="مثلاً: بريء، متحمس، غاضب، فضولي، ناعس..."
                className="w-full bg-slate-700/50 border border-slate-600 rounded-md py-2 px-3 text-slate-200 placeholder-slate-500 focus:ring-2 focus:ring-cyan-500 focus:border-cyan-500 outline-none transition"
            />
        </div>

      </div>
      <button
        onClick={onGenerate}
        disabled={isLoading}
        className="mt-6 w-full flex items-center justify-center bg-cyan-500 hover:bg-cyan-600 disabled:bg-slate-600 text-white font-bold py-3 px-4 rounded-lg transition-all duration-300 transform hover:scale-105 disabled:scale-100 shadow-lg shadow-cyan-500/20"
      >
        {isLoading ? (
          <>
            <LoadingIcon className="animate-spin w-5 h-5 ml-3" />
            جاري صياغة البرومبت...
          </>
        ) : (
          <>
            <GenerateIcon className="w-5 h-5 ml-3" />
            ولّد البرومبت الاحترافي
          </>
        )}
      </button>
    </div>
  );
};

export default InputForm;

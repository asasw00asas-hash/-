import React, { useState, useEffect } from 'react';
import { CopyIcon } from './icons/CopyIcon';
import { CheckIcon } from './icons/CheckIcon';
import { MagicIcon } from './icons/MagicIcon';

interface OutputDisplayProps {
  prompt: string;
  isLoading: boolean;
  error: string | null;
}

const OutputDisplay: React.FC<OutputDisplayProps> = ({ prompt, isLoading, error }) => {
  const [isCopied, setIsCopied] = useState(false);

  useEffect(() => {
    if (isCopied) {
      const timer = setTimeout(() => setIsCopied(false), 2000);
      return () => clearTimeout(timer);
    }
  }, [isCopied]);

  const handleCopy = () => {
    if (prompt) {
      navigator.clipboard.writeText(prompt);
      setIsCopied(true);
    }
  };

  const renderContent = () => {
    if (isLoading) {
      return (
        <div className="flex flex-col items-center justify-center h-full text-slate-400 text-center p-4">
          <MagicIcon className="w-16 h-16 text-cyan-500 animate-pulse mb-4" />
          <p className="text-lg">خبير البرومبتات شغال...</p>
          <p>لحظات والبرومبت بتاعك هيكون جاهز.</p>
        </div>
      );
    }

    if (error) {
        return (
            <div className="flex flex-col items-center justify-center h-full text-red-400 p-4">
                <p className="text-lg font-semibold">أوبس! حصلت مشكلة</p>
                <p className="text-center mt-2">{error}</p>
            </div>
        );
    }

    if (!prompt) {
      return (
        <div className="flex flex-col items-center justify-center h-full text-slate-500 text-center p-4">
            <MagicIcon className="w-16 h-16 mb-4" />
            <p className="text-lg">البرومبت الإنجليزي هيظهر هنا.</p>
            <p>املأ التفاصيل ودوس على "ولّد البرومبت".</p>
        </div>
      );
    }
    
    return (
        <div className="relative h-full flex items-center justify-center p-4">
            <button
                onClick={handleCopy}
                className="absolute top-4 right-4 z-10 p-2 bg-slate-700 hover:bg-slate-600 rounded-lg text-slate-300 transition-colors"
                title="Copy Prompt"
            >
                {isCopied ? <CheckIcon className="w-5 h-5 text-green-400" /> : <CopyIcon className="w-5 h-5" />}
            </button>
            <div dir="ltr" className="h-full w-full bg-slate-900/70 rounded-lg overflow-y-auto p-4 border border-slate-700">
              <pre className="text-sm md:text-base text-slate-100 whitespace-pre-wrap font-mono">
                <code>
                  {prompt}
                </code>
              </pre>
            </div>
        </div>
    );
  };

  return (
    <div className="bg-slate-800/50 backdrop-blur-sm rounded-xl border border-slate-700 shadow-2xl flex flex-col overflow-hidden min-h-[400px] lg:min-h-0">
      {renderContent()}
    </div>
  );
};

export default OutputDisplay;

import { Geist } from 'next/font/google'

const geist = Geist({
  subsets: ['latin'],
  weight: ['900'],
})

export default function Home() {
  return (
    <div className="flex flex-col min-h-screen p-12 text-white bg-gradient-to-b from-neutral-950 to-neutral-900 ">
      <h1 className={`${geist.className} items-center justify-center text-center text-5xl antialiased 
        md:subpixel-antialiased text-shadow-lg text-shadow-emerald-700`}>
        BlackFlow
      </h1>
    </div>
  );
}

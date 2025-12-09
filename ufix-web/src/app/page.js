import Link from 'next/link';

export default function Home() {
  return (
    <div className="hero min-h-screen bg-base-200">
      <div className="hero-content text-center">
        <div className="max-w-md">
          <h1 className="text-5xl font-bold">Hello there</h1>
          <p className="py-6">
            Welcome to your Next.js application with DaisyUI. This app connects to your existing backend and database.
          </p>
          <div className="flex gap-4 justify-center">
            <Link href="/users" className="btn btn-primary">
              View Users
            </Link>
            <button className="btn btn-secondary">Get Started</button>
          </div>
        </div>
      </div>
    </div>
  );
}
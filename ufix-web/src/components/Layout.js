import Navbar from './Navbar';

export default function Layout({ children }) {
  return (
    <div data-theme="light">
      <Navbar />
      <main className="container mx-auto px-4 py-8">
        {children}
      </main>
    </div>
  );
}
import { Button } from "@/components/ui/button"

export default function Home() {
  return (
    <main className="min-h-screen bg-white">
      {/* Header */}
      <header className="border-b bg-white">
        <div className="container mx-auto px-4 py-4">
          <h1 className="text-2xl font-bold text-gray-900">U-Fix Service Guide</h1>
        </div>
      </header>

      {/* Main Content */}
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto">
          {/* Hero Section */}
          <section className="text-center mb-12">
            <h2 className="text-4xl font-bold text-gray-900 mb-4">
              Video Service Tutorials
            </h2>
            <p className="text-lg text-gray-600 mb-8">
              Step-by-step guides for video editing and repair services
            </p>
          </section>

          {/* Features Grid */}
          <section className="grid md:grid-cols-2 gap-6 mb-12">
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
              <h3 className="text-xl font-semibold text-blue-900 mb-2">Easy Tutorials</h3>
              <p className="text-blue-700">Follow our step-by-step video guides</p>
            </div>
            
            <div className="bg-green-50 border border-green-200 rounded-lg p-6">
              <h3 className="text-xl font-semibold text-green-900 mb-2">Quick Solutions</h3>
              <p className="text-green-700">Fix common video issues quickly</p>
            </div>
          </section>

          {/* Button Examples */}
          <section className="mb-12">
            <h3 className="text-2xl font-semibold text-gray-900 mb-6">Available Actions</h3>
            <div className="flex flex-wrap gap-4 mb-6">
              <Button variant="default">Start Tutorial</Button>
              <Button variant="secondary">Browse Guides</Button>
              <Button variant="outline">View Examples</Button>
              <Button variant="destructive">Emergency Fix</Button>
            </div>
            
            <div className="flex flex-wrap gap-4">
              <Button size="sm">Small Button</Button>
              <Button size="default">Default Size</Button>
              <Button size="lg">Large Button</Button>
            </div>
          </section>

          {/* Content Cards */}
          <section className="grid gap-6">
            <div className="border border-gray-200 rounded-lg p-6 bg-white">
              <h4 className="text-lg font-semibold text-gray-900 mb-2">Video Compression</h4>
              <p className="text-gray-600 mb-4">Learn how to compress videos without losing quality</p>
              <Button variant="outline">Learn More</Button>
            </div>
            
            <div className="border border-gray-200 rounded-lg p-6 bg-white">
              <h4 className="text-lg font-semibold text-gray-900 mb-2">Format Conversion</h4>
              <p className="text-gray-600 mb-4">Convert between different video formats easily</p>
              <Button variant="outline">Learn More</Button>
            </div>
          </section>
        </div>
      </div>

      {/* Footer */}
      <footer className="border-t bg-gray-50 mt-12">
        <div className="container mx-auto px-4 py-6">
          <p className="text-center text-gray-600">
            U-Fix Video Services - College Project
          </p>
        </div>
      </footer>
    </main>
  )
}
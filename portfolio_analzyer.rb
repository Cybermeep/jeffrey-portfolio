#!/usr/bin/env ruby
# frozen_string_literal: true

require 'nokogiri'
require 'json'

class PortfolioAnalyzer
  def initialize(html_content)
    @doc = Nokogiri::HTML(html_content)
    @analysis = {}
  end

  def comprehensive_analysis
    {
      metadata: extract_metadata,
      structure: analyze_structure,
      content: analyze_content,
      technical_features: analyze_technical_features,
      projects: extract_projects,
      skills: extract_skills,
      performance_metrics: calculate_metrics,
      analysis_timestamp: Time.now.iso8601
    }
  end

  private

  def extract_metadata
    {
      title: @doc.at_css('title')&.text,
      viewport: @doc.at_css('meta[name="viewport"]')&.[]('content'),
      charset: @doc.at_css('meta[charset]')&.[]('charset')
    }
  end

  def analyze_structure
    {
      sections: @doc.css('section').map { |section| section['id'] }.compact,
      total_sections: @doc.css('section').count,
      navigation_items: @doc.css('.nav-links a').map { |a| { text: a.text, href: a['href'] } },
      total_links: @doc.css('a').count,
      images: @doc.css('img').map { |img| img['src'] }.compact,
      forms: @doc.css('form').count
    }
  end

  def analyze_content
    {
      headings: {
        h1: @doc.css('h1').map(&:text),
        h2: @doc.css('h2').map(&:text),
        h3: @doc.css('h3').map(&:text)
      },
      total_words: total_word_count,
      contact_info: extract_contact_info
    }
  end

  def analyze_technical_features
    {
      css_frameworks: detect_css_frameworks,
      javascript_libraries: detect_js_libraries,
      interactive_elements: detect_interactive_elements,
      responsive_design: has_responsive_design?,
      animations: detect_animations
    }
  end

  def extract_projects
    projects = []
    
    @doc.css('.project-card').each do |project|
      projects << {
        title: project.at_css('h3')&.text,
        description: project.at_css('p')&.text&.strip,
        technologies: project.css('.tech-tag').map(&:text),
        links: project.css('.project-links a').map { |a| { text: a.text.strip, href: a['href'] } }
      }
    end
    
    projects
  end

  def extract_skills
    @doc.css('.skill').map(&:text)
  end

  def calculate_metrics
    {
      total_elements: @doc.css('*').count,
      css_size: estimate_css_size,
      script_count: @doc.css('script').count,
      style_blocks: @doc.css('style').count
    }
  end

  def total_word_count
    @doc.css('body').text.scan(/\w+/).count
  end

  def extract_contact_info
    {
      email: @doc.css('.contact-item').find { |item| item.text.include?('Email') }&.text&.gsub(/\s+/, ' ')&.strip,
      phone: @doc.css('.contact-item').find { |item| item.text.include?('Phone') }&.text&.gsub(/\s+/, ' ')&.strip
    }
  end

  def detect_css_frameworks
    frameworks = []
    styles = @doc.css('style').text + @doc.css('link[rel="stylesheet"]').map { |l| l['href'] }.join(' ')
    
    frameworks << 'Font Awesome' if styles.include?('font-awesome') || styles.include?('fa-')
    frameworks << 'Highlight.js' if styles.include?('highlight.js')
    frameworks << 'Custom CSS' if @doc.css('style').any?
    
    frameworks
  end

  def detect_js_libraries
    libraries = []
    scripts = @doc.css('script').map { |s| s['src'] }.compact.join(' ')
    
    libraries << 'Highlight.js' if scripts.include?('highlight.js')
    libraries << 'Custom JavaScript' if @doc.css('script').any? { |s| s.text.strip.length > 0 }
    
    libraries
  end

  def detect_interactive_elements
    elements = []
    
    elements << 'Bubble System' if @doc.css('#bubble-container').any?
    elements << 'Tab System' if @doc.css('.docs-nav').any?
    elements << 'Contact Form' if @doc.css('#contactForm').any?
    elements << 'Smooth Scroll' if @doc.css('a[href^="#"]').any?
    
    elements
  end

  def has_responsive_design?
    @doc.css('meta[name="viewport"]').any? && 
    @doc.css('style').text.include?('@media')
  end

  def detect_animations
    animations = []
    css_content = @doc.css('style').text
    
    animations << 'CSS Animations' if css_content.include?('@keyframes')
    animations << 'Transitions' if css_content.include?('transition')
    animations << 'JavaScript Animations' if @doc.css('script').text.include?('requestAnimationFrame')
    
    animations
  end

  def estimate_css_size
    css_content = @doc.css('style').text
    (css_content.bytesize / 1024.0).round(2)
  end
end

# Report generator
class AnalysisReport
  def self.generate(analysis, output_file = 'portfolio_analysis_report.md')
    File.open(output_file, 'w') do |file|
      file.puts "# Portfolio Analysis Report"
      file.puts "Generated: #{analysis[:analysis_timestamp]}"
      file.puts ""
      
      file.puts "## Basic Metadata"
      file.puts "- **Title**: #{analysis[:metadata][:title]}"
      file.puts "- **Sections**: #{analysis[:structure][:sections].join(', ')}"
      file.puts "- **Total Sections**: #{analysis[:structure][:total_sections]}"
      file.puts ""
      
      file.puts "## Technical Features"
      file.puts "- **CSS Frameworks**: #{analysis[:technical_features][:css_frameworks].join(', ')}"
      file.puts "- **JavaScript Libraries**: #{analysis[:technical_features][:javascript_libraries].join(', ')}"
      file.puts "- **Interactive Elements**: #{analysis[:technical_features][:interactive_elements].join(', ')}"
      file.puts "- **Responsive Design**: #{analysis[:technical_features][:responsive_design] ? 'Yes' : 'No'}"
      file.puts "- **Animations**: #{analysis[:technical_features][:animations].join(', ')}"
      file.puts ""
      
      file.puts "## Projects (#{analysis[:projects].count})"
      analysis[:projects].each_with_index do |project, index|
        file.puts "### #{index + 1}. #{project[:title]}"
        file.puts "- **Technologies**: #{project[:technologies].join(', ')}"
        file.puts "- **Description**: #{project[:description]}" if project[:description]
        file.puts ""
      end
      
      file.puts "## Performance Metrics"
      file.puts "- **Total Elements**: #{analysis[:performance_metrics][:total_elements]}"
      file.puts "- **CSS Size**: #{analysis[:performance_metrics][:css_size]} KB"
      file.puts "- **Script Count**: #{analysis[:performance_metrics][:script_count]}"
      file.puts "- **Total Words**: #{analysis[:content][:total_words]}"
    end
    
    puts "Report generated: #{output_file}"
  end
end

# Main execution
if __FILE__ == $0
  html_file = 'index.html'
  
  if File.exist?(html_file)
    puts "Analyzing #{html_file}..."
    html_content = File.read(html_file)
    
    analyzer = PortfolioAnalyzer.new(html_content)
    analysis = analyzer.comprehensive_analysis
    
    # Generate markdown report
    AnalysisReport.generate(analysis)
    
    # Also save JSON for programmatic use
    File.write('portfolio_analysis.json', JSON.pretty_generate(analysis))
    puts "JSON data saved: portfolio_analysis.json"
    
    puts "Analysis complete! Check portfolio_analysis_report.md"
    
  else
    puts "Error: index.html not found in current directory"
    puts "Current directory files:"
    Dir.foreach('.') { |file| puts "  #{file}" unless file.start_with?('.') }
  end
end
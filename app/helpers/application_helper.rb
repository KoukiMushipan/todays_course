module ApplicationHelper
  def page_title(page_title = '')
    base_title = "Today's Course"

    page_title.empty? ? base_title : page_title + ' / ' + base_title
  end

  def flash?
    flash[:success] || flash[:error]
  end

  def default_meta_tags
    {
      description: "Today's Courseは日々の生活に運動を取り入れるサポートをします。簡単に目的地を決めたり移動を記録できたりするので、高いモチベーションで継続できます。",
      keywords: 'todayscourse, ランニング, ウォーキング, 目的地, 継続, 運動不足, 記録',
      canonical: 'https://www.todays-course.com/top',
      icon: [
        { href: image_url('favicon-180.png') },
        { href: image_url('favicon-180.png'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/jpg' },
      ],
      og: {
        site_name: "Today's Course",
        title: "目的地を探してみよう！",
        description: "Today's Courseは日々の生活に運動を取り入れるサポートをします。簡単に目的地を決めたり移動を記録できたりするので、高いモチベーションで継続できます。",
        type: 'website',
        url: 'https://www.todays-course.com/top',
        image: image_url('ogp-img.png'),
        locale: 'ja_JP',
      },
      twitter: {
        card: 'summary_large_image',
      },
    }
  end
end

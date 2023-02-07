import Foundation

public struct Show: Sendable, Equatable, Identifiable {
    public var title: String
    public var description: String?
    public var author: String?
    public var feedURL: URL
    public var imageURL: URL
    public var linkURL: URL?
    public var episodes: [Episode]

    public var id: URL { feedURL }

    public init(
        title: String,
        description: String?,
        author: String?,
        feedURL: URL,
        imageURL: URL,
        linkURL: URL?,
        episodes: [Episode]
    ) {
        self.title = title
        self.description = description
        self.author = author
        self.feedURL = feedURL
        self.imageURL = imageURL
        self.linkURL = linkURL
        self.episodes = episodes
    }
}

// swiftlint:disable line_length

#if DEBUG
extension Show {
    public static let fixtureRebuild = Show(
        title: "Rebuild",
        description: "ウェブ開発、プログラミング、モバイル、ガジェットなどにフォーカスしたテクノロジー系ポッドキャストです。 #rebuildfm",
        author: "Tatsuhiko Miyagawa",
        feedURL: URL(string: "https://feeds.rebuild.fm/rebuildfm")!,
        imageURL: URL(string: "https://cdn.rebuild.fm/images/icon1400.jpg")!,
        linkURL: URL(string: "https://rebuild.fm")!,
        episodes: [
            .init(
                guid: "https://rebuild.fm/352/",
                title: "352: There's a Fifth Way (naoya)",
                subtitle: "Naoya Ito さんをゲストに迎えて、MacBook Pro, キーボード、競技プログラミング、レイオフ、ゲームなどについて話しました。",
                description: rebuild352Description,
                duration: 7907,
                soundURL: URL(string: "https://cache.rebuild.fm/podcast-ep352.mp3")!
            ),
            .init(
                guid: "https://rebuild.fm/351/",
                title: "351: Time For Change (hak)",
                subtitle: "Hakuro Matsuda さんをゲストに迎えて、CES, VR, Apple TV, Twitter などについて話しました。",
                description: rebuild351Description,
                duration: 9015,
                soundURL: URL(string: "https://cache.rebuild.fm/podcast-ep351.mp3")!
            ),
            .init(
                guid: "https://rebuild.fm/350/",
                title: "350: Mister O-1 (N, naan)",
                subtitle: "Naoki Hiroshima さん、Kazuho Okui さんをゲストに迎えて、近況、Twitter, USB-C, ChatGPT などについて話しました。",
                description: rebuild350Description,
                duration: 7500,
                soundURL: URL(string: "https://cache.rebuild.fm/podcast-ep350.mp3")!
            ),
        ]
    )

    public static let fixtureSwiftBySundell = Show(
        title: "Swift by Sundell",
        description: "In-depth conversations about Swift and software development in general, hosted by John Sundell.",
        author: "John Sundell",
        feedURL: URL(string: "https://www.swiftbysundell.com/podcast/feed.rss")!,
        imageURL: URL(string: "https://www.swiftbysundell.com/images/podcastArtwork.png")!,
        linkURL: URL(string: "https://www.swiftbysundell.com/podcast")!,
        episodes: []
    )

    public static let fixtureプログラム雑談 = Show(
        title: "プログラム雑談",
        description: """
        プログラム雑談はkarino2が、主にプログラムに関わる事について、雑談するpodcastです。たまにプログラムと関係ない近況とかも話します。
        お便りはこちらから。 https://odaibako.net/u/karino2012
        """,
        author: "Kazuma Arino",
        feedURL: URL(string: "https://anchor.fm/s/68ce140/podcast/rss")!,
        imageURL: URL(string: "https://d3t3ozftmdmh3i.cloudfront.net/production/podcast_uploaded/998960/998960-1535212397504-93ed2911e3e38.jpg")!,
        linkURL: URL(string: "https://anchor.fm/karino2")!,
        episodes: [
            .init(
                guid: "b8c3341d-bbf1-4184-8977-137e4ee45526",
                title: "228回 プログラマがweb上のろくでもないおっさんになってしまうメカニズムについての雑談",
                subtitle: "&lt;p&gt;自分のやってる事が大したこと無いと気づく結果ろくでもないおっさんになってしまう、という新発見。&lt;/p&gt;",
                description: "<p>自分のやってる事が大したこと無いと気づく結果ろくでもないおっさんになってしまう、という新発見。</p>",
                duration: 2307,
                soundURL: URL(string: "https://anchor.fm/s/68ce140/podcast/play/63943153/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fproduction%2F2023-0-24%2F309067843-44100-1-c25d646c3be96.m4a")!
            ),
        ]
    )
}

private let rebuild352Description = """
<p>Naoya Ito さんをゲストに迎えて、MacBook Pro, キーボード、競技プログラミング、レイオフ、ゲームなどについて話しました。</p>
<h3>Show Notes</h3><ul>
<li><a href="https://www.apple.com/macbook-pro-14-and-16/">MacBook Pro</a></li>
<li><a href="https://www.intel.com/content/www/us/en/products/details/nuc.html">Intel® NUC</a></li>
<li><a href="https://www.apple.com/homepod/">HomePod</a></li>
<li><a href="https://support.apple.com/en-us/HT207117">Use HDMI ARC or eARC with your Apple TV 4K</a></li>
<li><a href="https://rebuild.fm/portal/">Rebuild Supporter</a></li>
<li><a href="https://www.hhkeyboard.com/uk/products/hybrid">Hybrid - Happy Hacking Keyboard (HHKB)</a></li>
<li><a href="https://r7kamura.com/articles/2022-07-22-keychron-q1-knob-jis">Keychron Q1と私</a></li>
<li><a href="https://www.keychron.com/products/keychron-q1">Keychron Q1</a></li>
<li><a href="https://www.youtube.com/watch?v=daNHep8KOqg">Niz atom66、HHKBを倒す者の名や</a></li>
<li><a href="https://jun3010.me/blog-des-domes-carrots-35g-23226.html">DES-DOMES CARROTS 35gのレビュー</a></li>
<li><a href="https://shop.keyboard.io/products/keyboardio-atreus">Keyboardio Atreus</a></li>
<li><a href="https://shop.yushakobo.jp/en/products/6331?_pos=3&_sid=a99ef5d3a&_ss=r">Gazzew Boba Black U4 Switch / Silent Tactile</a></li>
<li><a href="https://shop.yushakobo.jp/en/products/6329?_pos=2&_sid=a99ef5d3a&_ss=r">Gazzew Boba Black U4T Switch / Tactile)</a></li>
<li><a href="https://shop.bird-electron.co.jp/?pid=129623919">HHKB Pro用吸振マット</a></li>
<li><a href="https://shop.bird-electron.co.jp/?mode=cate&cbid=2723866&csid=1&sort=n">パームレスト</a></li>
<li><a href="https://atcoder.jp/">AtCoder</a></li>
<li><a href="https://leetcode.com/">LeetCode</a></li>
<li><a href="https://adventofcode.com/">Advent of Code 2022</a></li>
<li><a href="https://shindannin.hatenadiary.com/entry/2021/04/09/130400">競技プログラミングを終わらせる人々への指摘、頑張っている人々へのアドバイス</a></li>
<li><a href="https://www.cnbc.com/2023/01/21/google-employees-scramble-for-answers-after-layoffs-hit-long-tenured.html">Google employees scramble for answers after layoffs hit long-tenured</a></li>
<li><a href="https://www.jp.square-enix.com/tor/">タクティクスオウガ リボーン</a></li>
<li><a href="https://en.bandainamcoent.eu/elden-ring/elden-ring">ELDEN RING</a></li>
<li><a href="https://diablo4.blizzard.com/en-us/">Diablo IV</a></li>
<li><a href="https://ja.wikipedia.org/wiki/%E3%83%8F%E3%83%83%E3%82%AF%E3%82%A2%E3%83%B3%E3%83%89%E3%82%B9%E3%83%A9%E3%83%83%E3%82%B7%E3%83%A5">ハックアンドスラッシュ</a></li>
<li><a href="https://www.amazon.co.jp/dp/B07S9Q1TY4?tag=bulknews-22">血と汗とピクセル:</a></li>
<li><a href="https://www.amazon.co.jp/dp/B01JYSXB2W?tag=bulknews-22">イワタニ スモークレス焼肉グリル やきまる</a></li>
<li><a href="https://www.amazon.co.jp/dp/B006M80ODC?tag=bulknews-22">Todai 18-0 クレーバートング</a></li>
</ul>
"""

private let rebuild351Description = """
<p>Hakuro Matsuda さんをゲストに迎えて、CES, VR, Apple TV, Twitter などについて話しました。</p>
<h3>Show Notes</h3><ul>
<li><a href="https://rebuild.fm/portal/">Rebuild Supporter</a></li>
<li><a href="https://gumroad.com/">Gumroad</a></li>
<li><a href="https://stripe.com/billing">Stripe Billing</a></li>
<li><a href="https://convertkit.com/">ConvertKit</a></li>
<li><a href="https://www.cnet.com/tech/mobile/see-samsungs-futuristic-screen-fold-slide-and-shapeshift/">See Samsung&#39;s Futuristic Screen Fold, Slide and Shape-Shift</a></li>
<li><a href="https://www.engadget.com/intels-13th-gen-laptop-cpu-24-cores-140050825.html">Intel&#39;s 13th-gen laptop CPUs offer up to 24 cores</a></li>
<li><a href="https://www.pcgamer.com/amds-new-ryzen-7040-series-laptop-apu-has-special-ai-sauce/">AMD&#39;s new Ryzen 7040 Series laptop APU has special AI sauce</a></li>
<li><a href="https://www.theverge.com/2023/1/13/23554200/google-stadia-controller-bluetooth-support-last-game">Google’s Stadia controller is getting Bluetooth support</a></li>
<li><a href="https://venturebeat.com/transportation/bmw-unveils-car-that-can-change-its-color-using-e-ink/">BMW unveils car that can change its color using E Ink</a></li>
<li><a href="https://arstechnica.com/gadgets/2023/01/google-announces-official-android-support-for-risc-v/">Google announces official Android support for RISC-V</a></li>
<li><a href="https://www.gearpatrol.com/food/a42409254/fellow-opus-grinder/">Fellow&#39;s New Opus Coffee Grinder</a></li>
<li><a href="https://www.vive.com/us/product/vive-xr-elite/overview/">VIVE XR Elite</a></li>
<li><a href="https://www.macrumors.com/2023/01/08/apple-headset-spring-event-ship-in-fall/">Apple&#39;s &#39;Reality Pro&#39; Headset Said to Launch Before WWDC, Ships in the Fall</a></li>
<li><a href="https://satechi.net/products/6-port-gan-charger?variant=40197715492952">Satechi 200W USB-C 6-Port GaN Charger</a></li>
<li><a href="https://www.amazon.co.jp/dp/B09W9M89WS?tag=bulknews-22">Anker 735 Chargerラ</a></li>
<li><a href="https://www.facebook.com/permalink.php?story_fbid=pfbid0iPixEvPJQGzNa6t2x6HUL5TYqfmKGqSgfkBg6QaTyHF5frXQi7eLGxC7uPQv5U5jl&id=100006735798590">John Carmack</a></li>
<li><a href="https://www.theverge.com/2023/1/3/23538131/qi2-wireless-charging-apple-samsung">Qi2: How Apple might finally harness MagSafe by giving it away</a></li>
<li><a href="https://www.macobserver.com/tips/quick-tip/wireless-audio-sync-apple-tv/">How to Set Up Wireless Audio Sync on Apple TV</a></li>
<li><a href="https://www.amazon.co.jp/dp/B0728D17SY?tag=bulknews-22">XGIMI Halo+ モバイルプロジェクター</a></li>
<li><a href="https://note.com/bayashiko1/n/n315d57e50849">GoogleのDurhamオフィスから追い出されました</a></li>
<li><a href="https://www.theverge.com/2023/1/17/23559180/twitter-blocking-apps-tweetbot">Twitter says it’s intentionally blocking apps like Tweetbot</a></li>
<li><a href="https://www.amazon.co.jp/dp/B0BQBK7KDG?tag=bulknews-22">三体０ 球状閃電</a></li>
<li><a href="https://www.pokemon.co.jp/ex/sv/ja/">ポケットモンスター スカーレット・バイオレット</a></li>
<li><a href="https://news.stanford.edu/2019/05/06/regular-pokemon-players-pikachu-brain/">Regular Pokémon players have Pikachu on the brain</a></li>
<li><a href="https://bocchi.rocks/">ぼっち・ざ・ろっく！</a></li>
<li><a href="https://www.youtube.com/watch?v=E5O0mCrUdAM">転がる岩、君に朝が降る</a></li>
<li><a href="https://www.imdb.com/title/tt1757678/">Avatar 3 (2024) - IMDb</a></li>
<li><a href="https://rrr-movie.jp/">ＲＲＲ アールアールアール</a></li>
<li><a href="https://www.netflix.com/title/81476453">RRR (Hindi) | Netflix</a></li>
<li><a href="https://www.rottentomatoes.com/m/white_noise_2022">White Noise</a></li>
<li><a href="https://www.rottentomatoes.com/m/black_crab">Black Crab</a></li>
<li><a href="https://www.rottentomatoes.com/m/shin_ultraman">Shin Ultraman</a></li>
<li><a href="http://www.drivein-tori.jp/">ドライブイン鳥</a></li>
<li><a href="https://ai-no-idenshi.com/">AIの遺電子</a></li>
</ul>
"""

private let rebuild350Description = """
<p>Naoki Hiroshima さん、Kazuho Okui さんをゲストに迎えて、近況、Twitter, USB-C, ChatGPT などについて話しました。</p>
<h3>Show Notes</h3><ul>
<li><a href="https://www.theverge.com/2022/12/15/23512113/twitter-blocking-mastodon-links-elon-musk-elonjet">Twitter is blocking links to Mastodon</a></li>
<li><a href="https://www.npr.org/2022/12/15/1143291081/twitter-suspends-journalists-elon-musk-jet#:%7E:text=Twitter%20suspends%20journalists%20who%20shared%20information%20about%20Elon%20Musk&#x27;s%20jet%20%3A%20NPR&text=Press-,Twitter%20suspends%20journalists%20who%20shared%20information%20about%20Elon%20Musk&#x27;s%20jet,journalists%20who%20cover%20the%20billionaire.">Twitter suspends journalists who shared information about Elon Musk&#39;s jet</a></li>
<li><a href="https://nypost.com/2022/12/30/twitter-employees-using-own-toilet-paper-offices-stink-after-musk-cut-janitors-report/">Twitter employees using own toilet paper after janitor cuts</a></li>
<li><a href="https://www.theverge.com/2022/12/20/23519922/george-hotz-geohot-twitter-internship-resigns">Geohot resigns from Twitter</a></li>
<li><a href="https://techcrunch.com/2022/11/11/tesla-opens-its-ev-connector-design-to-other-automakers/">Tesla opens its EV connector design to other automakers</a></li>
<li><a href="https://www.uscis.gov/working-in-the-united-states/temporary-workers/o-1-visa-individuals-with-extraordinary-ability-or-achievement">O-1 Visa: Individuals with Extraordinary Ability or Achievement</a></li>
<li><a href="https://www.mistero1.com/">Mister O1 | Extraordinary Pizza</a></li>
<li><a href="https://www.amazon.co.jp/dp/B0BN7YKJSR?tag=bulknews-22">笑い神　M-1、その純情と狂気</a></li>
<li><a href="https://macwright.com/2022/12/09/activitypub.html">Playing with ActivityPub</a></li>
<li><a href="https://www.theguardian.com/technology/2022/dec/30/explainer-us-congress-tiktok-ban">Why did the US just ban TikTok from government-issued cellphones?</a></li>
<li><a href="https://www.theverge.com/23520625/chatgpt-openai-amazon-kindle-novel">How Kindle novelists are using OpenAI’s ChatGPT</a></li>
</ul>
"""
#endif

// swiftlint:enable line_length

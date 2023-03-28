import 'package:reddit_clione/features/feed/screens/feed_screen.dart';
import 'package:reddit_clione/features/posts/screens/add_post_screen.dart';

class Constants{
  static const logoPath = 'assets/images/logo.png';
  static const loginEmotePath = 'assets/images/loginEmote.png';
  static const googlePath = 'assets/images/google.png';

  //awards
  static const awesomeAnswerPath = 'assets/images/awards/awesomeanswer.png';
  static const goldPath = 'assets/images/awards/gold.png';
  static const helpfulPath = 'assets/images/awards/helpful.png';
  static const platinumPath = 'assets/images/awards/platinum.png';
  static const plusOnePath = 'assets/images/awards/plusone.png';
  static const thankYouPath = 'assets/images/awards/thankyou.png';
  static const rocketPath = 'assets/images/awards/rocket.png';
  static const tilPath = 'assets/images/awards/til.png';

  //defaults
  static const bannerDefault =
      'https://thumbs.dreamstime.com/b/abstract-stained-pattern-rectangle-background-blue-sky-over-fiery-red-orange-color-modern-painting-art-watercolor-effe-texture-123047399.jpg';
  static const avatarDefault =
      'https://external-preview.redd.it/5kh5OreeLd85QsqYO1Xz_4XSLYwZntfjqou-8fyBFoE.png?auto=webp&s=dbdabd04c399ce9c761ff899f5d38656d1de87c2';

  static const tabScreens = [
    FeedScreen(),
    AddPostScreen(),
  ];
}
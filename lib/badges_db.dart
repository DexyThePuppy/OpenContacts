class Badge {
  final String name;
  final String assetUrl;
  final String description;
  final List<String> apiKeywords;

  const Badge({
    required this.name,
    required this.assetUrl,
    required this.description,
    required this.apiKeywords,
  });
}

class BadgesDB {
  // Common Badges
  static const Map<String, Badge> commonBadges = {
    'host': Badge(
      name: 'Host',
      assetUrl:
          'resdb:///cef8313f2418512a52c718a505c8882684dfa6556bdf2af1da655d3e6a0f878e.png',
      description: 'Session Host',
      apiKeywords: ['host'],
    ),
    'supporter': Badge(
      name: 'Supporter',
      assetUrl:
          'resdb:///ef12d18cf37c0255ccae7ca1bf8d2856ed2d9d10f364ffd33cf1782a3143f0fc.png',
      description: 'Patreon Supporter',
      apiKeywords: ['supporter'],
    ),
    'spark_2018': Badge(
      name: '2018 Spark',
      assetUrl:
          'resdb:///63ba2228a4d09cf615f18cf483966f4e3c13f1960f5c7f52e8d3789cad45233d.png',
      description: 'Registered in 2018',
      apiKeywords: ['spark 2018'],
    ),
    'flame_2019': Badge(
      name: '2019 Flame',
      assetUrl:
          'resdb:///81b014eba11b630c2e0b30baa511e9cf8bc52954bd0b67f6293c8609346f11e2.png',
      description: 'Registered in 2019',
      apiKeywords: ['flame 2019'],
    ),
    'bonfire_2020': Badge(
      name: '2020 Bonfire',
      assetUrl:
          'resdb:///f9e0c8fb51252f33be0b8d3349c637f1b49b32be30a9b7c7fd691de460786939.png',
      description: 'Registered in 2020',
      apiKeywords: ['bonfire 2020'],
    ),
    'bread_day': Badge(
      name: 'Bread Day',
      assetUrl:
          'resdb:///ce37aa41210d5c0079d652f77dedc12082a93f8faefb9e82b1c97d98de953c7a.png',
      description: 'Account Registration Anniversary',
      apiKeywords: ['bread day'],
    ),
    'durian_tester': Badge(
      name: 'Durian Tester',
      assetUrl:
          'resdb:///1c62e8c224af005c9293bc636dd3e93e8f6d2aba202287cf40cbcfe1259129d4.png',
      description: 'Durian Beta Tester',
      apiKeywords: ['durian tester'],
    ),
    'live': Badge(
      name: 'Live',
      assetUrl: '', // Live badge doesn't have a resdb URL in the wiki
      description: 'Currently Streaming/Recording',
      apiKeywords: ['live'],
    ),
  };

  // Team Badges
  static const Map<String, Badge> teamBadges = {
    'team': Badge(
      name: 'Team',
      assetUrl:
          'resdb:///da11582c477cfd9afd957268c72961cca4130f64bea8440e381840425c898078.png',
      description: 'Resonite Team Member',
      apiKeywords: ['team member', 'platform admin'],
    ),
    'moderator': Badge(
      name: 'Moderator',
      assetUrl:
          'resdb:///43b2368b3779c9413d24ba77ec9a9e00fce4d16e021e386941cde3247bdd1aa5.png',
      description: 'Resonite Moderator',
      apiKeywords: ['moderator'],
    ),
    'mentor': Badge(
      name: 'Mentor',
      assetUrl:
          'resdb:///b765be132f8ddce120665b531ce8874fd2034529103ca72b0de9dfa896dfc9fc.png',
      description: 'Volunteer Mentor',
      apiKeywords: ['mentor'],
    ),
    'htc_ambassador': Badge(
      name: 'HTC Ambassador',
      assetUrl:
          'resdb:///f92c0a3e31882b8075081dfa2d0f4d3403b89422ccebf75acaf6cb8947f51175.png',
      description: 'HTC Ambassador Program Volunteer',
      apiKeywords: ['htc ambassador'],
    ),
  };

  // Platform Badges
  static const Map<String, Badge> platformBadges = {
    'linux': Badge(
      name: 'Linux',
      assetUrl:
          'resdb:///0a1ffbeb7be0b7378dd22e9e03696d826a2a19441aba7a2f541fa46a634726bc.png',
      description: 'Linux User',
      apiKeywords: ['linux'],
    ),
    'mobile': Badge(
      name: 'Mobile',
      assetUrl:
          'resdb:///8d5159ddf47538624b3e39c820607da8af81ac962db2a8898cbc7204f2cd91e0.png',
      description: 'Mobile User',
      apiKeywords: ['mobile'],
    ),
    'headless': Badge(
      name: 'Headless',
      assetUrl:
          'resdb:///e5d5db2a15934fe398f4ec00cd570a0a0266b62b6bf7b462593712865471c902.png',
      description: 'Headless Server',
      apiKeywords: ['headless'],
    ),
  };

  // Disability Awareness Badges
  static const Map<String, Badge> disabilityBadges = {
    'hearing_impaired': Badge(
      name: 'Hearing Impaired',
      assetUrl:
          'resdb:///b079a1bc258fd2bf2e56eefd88a0a1af04c47fe3dfed090fedfe04da523cab42.png',
      description: 'Hearing Impaired User',
      apiKeywords: ['hearing impaired'],
    ),
    'speech_impaired': Badge(
      name: 'Speech Impaired',
      assetUrl:
          'resdb:///89dcd8ab20fe52f799309e01b4a64a4f055bb864dd68ae52bce4382c0d1ea3b7.png',
      description: 'Speech Impaired User',
      apiKeywords: ['speech impaired'],
    ),
    'color_blind': Badge(
      name: 'Color Blind',
      assetUrl:
          'resdb:///b079a1bc258fd2bf2e56eefd88a0a1af04c47fe3dfed090fedfe04da523cab42.png',
      description: 'Color Vision Deficiency',
      apiKeywords: ['color blind'],
    ),
    'vision_impaired': Badge(
      name: 'Vision Impaired',
      assetUrl:
          'resdb:///b4e2da97dd3ccc2d49da3bb3adbb7f3fe575d133537dce5aea931e7a75c25926.png',
      description: 'Vision Impaired User',
      apiKeywords: ['vision impaired'],
    ),
  };

  // Optional Badges
  static const Map<String, Badge> optionalBadges = {
    'potato': Badge(
      name: 'Potato',
      assetUrl:
          'resdb:///9e2df387f7ab288486d5abd8ebb760d87872227a47779c897593c263f27b1f8e.png',
      description: 'Low-end PC User',
      apiKeywords: ['potato'],
    ),
  };

  // Event Badges
  static const Map<String, Badge> eventBadges = {
    'vblfc': Badge(
      name: 'VBLFC',
      assetUrl:
          'resdb:///a3a9380f5e4b97b686dbc64e30fd7eae6ff325eb00eba785c1646df5d451431f.png',
      description: 'Attended VBLFC convention in July 2021',
      apiKeywords: ['vblfc'],
    ),
    'vfe_2022': Badge(
      name: 'VFE 2022',
      assetUrl:
          'resdb:///d9654f19b527972427b4793fdfbad8abb680a1f159dd2e80ce1b35cf27590237.png',
      description: 'Attended Virtual Furnal Equinox 2022',
      apiKeywords: ['vfe 2022'],
    ),
    'festa_3': Badge(
      name: 'Festa 3',
      assetUrl:
          'resdb:///8f329d39f0f6c4778afe7dd1f2c85461cfd0c57a79ebdbe648cfb5de797261b1.png',
      description: 'Festa 3 Event Ambassador',
      apiKeywords: ['festa 3'],
    ),
    'festa_3_participant': Badge(
      name: 'Festa 3 Participant',
      assetUrl:
          'resdb:///db19e650645cc15516a4e95f02253e3aefd7bd2a9ffeb838d95a08d9eb4334f1.png',
      description: 'Participated in Festa 3',
      apiKeywords: ['festa 3 participant'],
    ),
    'festa_4': Badge(
      name: 'Festa 4',
      assetUrl:
          'resdb:///b3e14476da9ee56a2bfd618e3281b7314999797ba654eabb0588852ee1ef04aa.png',
      description: 'Festa 4 Event Ambassador',
      apiKeywords: ['neos festa 4', 'festa 4'],
    ),
    'unifesta_idea_participant': Badge(
      name: 'UniFesta Idea Participant',
      assetUrl:
          'resdb:///fa88adba5c5c3910052ec801852ed56138ac606b45e66a5f4f51a02af032166e.png',
      description: 'Festa 5 Event Ambassador',
      apiKeywords: ['unifesta idea participant'],
    ),
  };

  // MMC Badges by Year
  static const Map<String, Badge> mmcBadges = {
    // MMC 2024
    'mmc24_participant': Badge(
      name: 'MMC24 Participant',
      assetUrl: 'resdb:///9/91/MMC24-Participation.png',
      description: 'Participated in MMC 2024',
      apiKeywords: ['mmc24 participant'],
    ),
    'mmc24_sponsor': Badge(
      name: 'MMC24 Sponsor',
      assetUrl: 'resdb:///f/f4/MMC24_Sponsor_Badge.png',
      description: 'Donated during MMC 2024',
      apiKeywords: ['mmc24 sponsor'],
    ),
    'mmc24_world': Badge(
      name: 'MMC24 World',
      assetUrl: 'resdb:///7/73/MMC24-World.png',
      description: 'MMC24 World Category Winner',
      apiKeywords: ['mmc24 world'],
    ),
    'mmc24_avatar': Badge(
      name: 'MMC24 Avatar',
      assetUrl: 'resdb:///1/18/MMC24-Avatar.png',
      description: 'MMC24 Avatar Category Winner',
      apiKeywords: ['mmc24 avatar'],
    ),
    'mmc24_other': Badge(
      name: 'MMC24 Other',
      assetUrl: 'resdb:///0/01/MMC24-Other.png',
      description: 'MMC24 Other Category Winner',
      apiKeywords: ['mmc24 other'],
    ),
    'mmc24_art': Badge(
      name: 'MMC24 Art',
      assetUrl: 'resdb:///8/8c/MMC24-Art.png',
      description: 'MMC24 Art Category Winner',
      apiKeywords: ['mmc24 art'],
    ),
    'mmc24_esd': Badge(
      name: 'MMC24 ESD',
      assetUrl: 'resdb:///5/59/MMC24-ESD.png',
      description: 'MMC24 ESD Category Winner',
      apiKeywords: ['mmc24 esd'],
    ),
    'mmc24_meme': Badge(
      name: 'MMC24 Meme',
      assetUrl: 'resdb:///d/d2/MMC24-Meme.png',
      description: 'MMC24 Meme Category Winner',
      apiKeywords: ['mmc24 meme'],
    ),
    'mmc24_narrative': Badge(
      name: 'MMC24 Narrative',
      assetUrl: 'resdb:///f/fd/MMC24-Narrative.png',
      description: 'MMC24 Narrative Category Winner',
      apiKeywords: ['mmc24 narrative'],
    ),
    'mmc24_honorable': Badge(
      name: 'MMC24 Honorable Mention',
      assetUrl: 'resdb:///b/bb/MMC24-HonorableMention.png',
      description: 'MMC24 Honorable Mention',
      apiKeywords: ['mmc24 honorable'],
    ),
    'mmc24_ja_translator': Badge(
      name: 'MMC24 Japanese Translator',
      assetUrl: 'resdb:///c/cd/MMC24-litalita-RosettaStone.png',
      description: 'Given to litalita for MMC24 Japanese translations',
      apiKeywords: ['mmc24 ja translator'],
    ),
    'mmc24_ko_translator': Badge(
      name: 'MMC24 Korean Translator',
      assetUrl: 'resdb:///8/8b/MMC24-Holy_Water-SouthKoreaFloppyDisk.png',
      description: 'Given to Holy_Water for MMC24 Korean translations',
      apiKeywords: ['mmc24 ko translator'],
    ),
    'mmc24_doggy': Badge(
      name: 'MMC24 Doggy',
      assetUrl: 'resdb:///7/75/MMC24-ProbablePrime-Doggy.png',
      description:
          'Given to ProbablePrime for helping with the MMC24 voting system',
      apiKeywords: ['mmc24 doggy'],
    ),
    'mmc24_banana': Badge(
      name: 'MMC24 Banana',
      assetUrl: 'resdb:///3/3b/MMC24-Frooxius-BananaPlanet.png',
      description: 'Given to Frooxius for acting in the MMC24 shows',
      apiKeywords: ['mmc24 banana'],
    ),

    // MMC 2023
    'mmc23_participant': Badge(
      name: 'MMC23 Participant',
      assetUrl:
          'resdb:///a3a9380f5e4b97b686dbc64e30fd7eae6ff325eb00eba785c1646df5d451431f.png',
      description: 'Participated in MMC 2023',
      apiKeywords: ['mmc23 participant'],
    ),
    'mmc23_sponsor': Badge(
      name: 'MMC23 Sponsor',
      assetUrl:
          'resdb:///d9654f19b527972427b4793fdfbad8abb680a1f159dd2e80ce1b35cf27590237.png',
      description: 'Donated during MMC 2023',
      apiKeywords: ['mmc23 sponsor'],
    ),
    'mmc23_world': Badge(
      name: 'MMC23 World',
      assetUrl:
          'resdb:///8f329d39f0f6c4778afe7dd1f2c85461cfd0c57a79ebdbe648cfb5de797261b1.png',
      description: 'MMC23 World Category Winner',
      apiKeywords: ['mmc23 world'],
    ),
    'mmc23_avatar': Badge(
      name: 'MMC23 Avatar',
      assetUrl:
          'resdb:///db19e650645cc15516a4e95f02253e3aefd7bd2a9ffeb838d95a08d9eb4334f1.png',
      description: 'MMC23 Avatar Category Winner',
      apiKeywords: ['mmc23 avatar'],
    ),
    'mmc23_other': Badge(
      name: 'MMC23 Other',
      assetUrl:
          'resdb:///b3e14476da9ee56a2bfd618e3281b7314999797ba654eabb0588852ee1ef04aa.png',
      description: 'MMC23 Other Category Winner',
      apiKeywords: ['mmc23 other'],
    ),
    'mmc23_art': Badge(
      name: 'MMC23 Art',
      assetUrl:
          'resdb:///9e2df387f7ab288486d5abd8ebb760d87872227a47779c897593c263f27b1f8e.png',
      description: 'MMC23 Art Category Winner',
      apiKeywords: ['mmc23 art'],
    ),
    'mmc23_esd': Badge(
      name: 'MMC23 ESD',
      assetUrl:
          'resdb:///b079a1bc258fd2bf2e56eefd88a0a1af04c47fe3dfed090fedfe04da523cab42.png',
      description: 'MMC23 ESD Category Winner',
      apiKeywords: ['mmc23 esd'],
    ),
    'mmc23_meme': Badge(
      name: 'MMC23 Meme',
      assetUrl:
          'resdb:///89dcd8ab20fe52f799309e01b4a64a4f055bb864dd68ae52bce4382c0d1ea3b7.png',
      description: 'MMC23 Meme Category Winner',
      apiKeywords: ['mmc23 meme'],
    ),
    'mmc23_honorable': Badge(
      name: 'MMC23 Honorable Mention',
      assetUrl: 'resdb:///2/24/MMC23-HonorableMention.png',
      description: 'A badge awarded to honorable mentions of MMC23',
      apiKeywords: ['mmc23 honorable'],
    ),
    'mmc23_ja_translator': Badge(
      name: 'MMC23 Japanese Translator Badge',
      assetUrl: 'resdb:///a/aa/MMC23-ja-translation.png',
      description: 'Given to litalita for 2023 Japanese translations',
      apiKeywords: ['mmc23 ja translator'],
    ),
    'mmc23_ko_translator': Badge(
      name: 'MMC23 Korean Translator Badge',
      assetUrl: 'resdb:///3/3a/MMC23-ko-translation.png',
      description: 'Given to Holy_Water for 2023 Korean translations',
      apiKeywords: ['mmc23 ko translator'],
    ),
    'mmc23_mac_n_cheeze': Badge(
      name: 'MMC23 Mac \'n Cheeze',
      assetUrl: 'resdb:///7/77/MMC23-Mac-n-Cheeze.png',
      description:
          'Given to ProbablePrime for helping with the 2023 voting system',
      apiKeywords: ['mmc23 mac n cheeze'],
    ),

    // MMC 2022
    'mmc22_participant': Badge(
      name: 'MMC22 Participant',
      assetUrl: 'resdb:///b/bc/MMC22-Participation.png',
      description: 'Participated in MMC 2022',
      apiKeywords: ['mmc22 participant'],
    ),
    'mmc22_world': Badge(
      name: 'MMC22 World',
      assetUrl: 'resdb:///a/a4/MMC22-World.png',
      description: 'MMC22 World Category Winner',
      apiKeywords: ['mmc22 world'],
    ),
    'mmc22_avatar': Badge(
      name: 'MMC22 Avatar',
      assetUrl: 'resdb:///9/95/MMC22-Avatar.png',
      description: 'MMC22 Avatar Category Winner',
      apiKeywords: ['mmc22 avatar'],
    ),
    'mmc22_other': Badge(
      name: 'MMC22 Other',
      assetUrl: 'resdb:///4/4f/MMC22-Other.png',
      description: 'MMC22 Other Category Winner',
      apiKeywords: ['mmc22 other'],
    ),
    'mmc22_art': Badge(
      name: 'MMC22 Art',
      assetUrl: 'resdb:///0/00/MMC22-Art.png',
      description: 'MMC22 Art Category Winner',
      apiKeywords: ['mmc22 art'],
    ),
    'mmc22_esd': Badge(
      name: 'MMC22 ESD',
      assetUrl: 'resdb:///1/1e/MMC22-ESD.png',
      description: 'MMC22 ESD Category Winner',
      apiKeywords: ['mmc22 esd'],
    ),
    'mmc22_meme': Badge(
      name: 'MMC22 Meme',
      assetUrl: 'resdb:///b/b0/MMC22-Meme.png',
      description: 'MMC22 Meme Category Winner',
      apiKeywords: ['mmc22 meme'],
    ),
    'mmc22_honorable_mention': Badge(
      name: 'MMC22 Honorable Mention',
      assetUrl: 'resdb:///a/af/MMC22-HonorableMention.png',
      description: 'MMC22 Honorable Mention',
      apiKeywords: ['mmc22 honorable'],
    ),
    'mmc22_ja_translation': Badge(
      name: 'MMC22 Japanese Translator',
      assetUrl: 'resdb:///0/01/MMC22-ja-translation.png',
      description: 'Given to litalita for 2022 Japanese translations',
      apiKeywords: ['mmc22 ja translator'],
    ),
    'mmc22_ko_translation': Badge(
      name: 'MMC22 Korean Translator',
      assetUrl: 'resdb:///0/06/MMC22-ko-translation.png',
      description: 'Given to Holy_Water for 2022 Korean translations',
      apiKeywords: ['mmc22 ko translator'],
    ),
    'mmc22_cheeze_coin': Badge(
      name: 'MMC22 Cheeze Coin',
      assetUrl: 'resdb:///0/0a/MMC22-CheeseCoin-big-no.png',
      description:
          'Given to ProbablePrime for helping with the 2022 voting system',
      apiKeywords: ['mmc22 cheeze coin'],
    ),

    // MMC 2021
    'mmc21_participant': Badge(
      name: 'MMC21 Participant',
      assetUrl: 'resdb:///2/25/MMC21ParticipantBadge.png',
      description: 'Participated in MMC 2021',
      apiKeywords: ['mmc21 participant'],
    ),
    'mmc21_avatars_first': Badge(
      name: 'MMC21 Avatars First',
      assetUrl: 'resdb:///7/71/MMC21AvatarsFirstBadge.png',
      description: '1st Place in MMC21 Avatars category',
      apiKeywords: ['mmc21 avatars first'],
    ),
    'mmc21_avatars_second': Badge(
      name: 'MMC21 Avatars Second',
      assetUrl: 'resdb:///6/68/MMC21AvatarsSecondBadge.png',
      description: '2nd Place in MMC21 Avatars category',
      apiKeywords: ['mmc21 avatars second'],
    ),
    'mmc21_avatars_third': Badge(
      name: 'MMC21 Avatars Third',
      assetUrl: 'resdb:///4/46/MMC21AvatarsThirdBadge.png',
      description: '3rd Place in MMC21 Avatars category',
      apiKeywords: ['mmc21 avatars third'],
    ),
    'mmc21_worlds_first': Badge(
      name: 'MMC21 Worlds First',
      assetUrl: 'resdb:///8/82/MMC21WorldsFirstBadge.png',
      description: '1st Place in MMC21 Worlds category',
      apiKeywords: ['mmc21 worlds first'],
    ),
    'mmc21_worlds_second': Badge(
      name: 'MMC21 Worlds Second',
      assetUrl: 'resdb:///a/a3/MMC21WorldsSecondBadge.png',
      description: '2nd Place in MMC21 Worlds category',
      apiKeywords: ['mmc21 worlds second'],
    ),
    'mmc21_worlds_third': Badge(
      name: 'MMC21 Worlds Third',
      assetUrl: 'resdb:///3/3c/MMC21WorldsThirdBadge.png',
      description: '3rd Place in MMC21 Worlds category',
      apiKeywords: ['mmc21 worlds third'],
    ),
    'mmc21_other_first': Badge(
      name: 'MMC21 Other First',
      assetUrl: 'resdb:///9/9d/Mmc_other_first.png',
      description: '1st Place in MMC21 Other category',
      apiKeywords: ['mmc21 other first'],
    ),
    'mmc21_other_second': Badge(
      name: 'MMC21 Other Second',
      assetUrl: 'resdb:///0/07/Mmc_other_second.png',
      description: '2nd Place in MMC21 Other category',
      apiKeywords: ['mmc21 other second'],
    ),
    'mmc21_other_third': Badge(
      name: 'MMC21 Other Third',
      assetUrl: 'resdb:///5/5f/MMCCyanPlusBadge.png',
      description: '3rd Place in MMC21 Other category',
      apiKeywords: ['mmc21 other third'],
    ),
    'mmc21_meme_first': Badge(
      name: 'MMC21 Meme First',
      assetUrl: 'resdb:///d/d5/MMC21MemeFirstBadge.png',
      description: '1st Place in MMC21 Meme category',
      apiKeywords: ['mmc21 meme first'],
    ),
    'mmc21_meme_second': Badge(
      name: 'MMC21 Meme Second',
      assetUrl: 'resdb:///2/2d/MMC21MemeSecondBadge.png',
      description: '2nd Place in MMC21 Meme category',
      apiKeywords: ['mmc21 meme second'],
    ),
    'mmc21_meme_third': Badge(
      name: 'MMC21 Meme Third',
      assetUrl: 'resdb:///7/7a/MMC21MemeThirdBadge.png',
      description: '3rd Place in MMC21 Meme category',
      apiKeywords: ['mmc21 meme third'],
    ),
    'mmc21_translator': Badge(
      name: 'MMC21 Translator',
      assetUrl: 'resdb:///e/ea/Mmc_translation.png',
      description: 'MMC21 Japanese Translation Badge',
      apiKeywords: ['mmc21 translator'],
    ),
    'mmc21_cow': Badge(
      name: 'MMC21 Cow',
      assetUrl: 'resdb:///b/b9/Mmc_cow.png',
      description: 'MMC21 Voting System Management',
      apiKeywords: ['mmc21 cow'],
    ),

    // MMC 2020
    'mmc20_participant': Badge(
      name: 'MMC Participant',
      assetUrl: 'resdb:///d/db/MMCParticipantBadge.png',
      description: 'Participated in MMC 2020',
      apiKeywords: ['mmc20 participant'],
    ),
    'mmc20_worlds_first': Badge(
      name: 'MMC Worlds First',
      assetUrl: 'resdb:///5/57/MMCWorldsFirst.png',
      description:
          'Awarded to Team Vibez for 1st Place in the MMC Worlds category',
      apiKeywords: ['mmc20 worlds first'],
    ),
    'mmc20_worlds_second': Badge(
      name: 'MMC Worlds Second',
      assetUrl: 'resdb:///a/ab/MMCWorldsSecond.png',
      description:
          'Awarded to Beaned & Shorty0w0 for 2nd Place in the MMC Worlds category',
      apiKeywords: ['mmc20 worlds second'],
    ),
    'mmc20_worlds_third': Badge(
      name: 'MMC Worlds Third',
      assetUrl: 'resdb:///e/e8/MMCWorldsThird.png',
      description: 'Awarded to Jax for 3rd Place in the MMC Worlds category',
      apiKeywords: ['mmc20 worlds third'],
    ),
    'mmc20_avatar_first': Badge(
      name: 'MMC Avatar First',
      assetUrl: 'resdb:///7/76/Mmc_avatar_first.png',
      description:
          'Awarded to mohu_yan & orange for 1st Place in the MMC Avatars category',
      apiKeywords: ['mmc20 avatar first'],
    ),
    'mmc20_avatar_second': Badge(
      name: 'MMC Avatar Second',
      assetUrl: 'resdb:///4/43/Mmc_avatar_second.png',
      description:
          'Awarded to PurpleJuice for 2nd Place in the MMC Avatars category',
      apiKeywords: ['mmc20 avatar second'],
    ),
    'mmc20_avatar_third': Badge(
      name: 'MMC Avatar Third',
      assetUrl: 'resdb:///e/e4/Mmc_avatar_third.png',
      description:
          'Awarded to guheheP for 3rd Place in the MMC Avatars category',
      apiKeywords: ['mmc20 avatar third'],
    ),
    'mmc20_other_first': Badge(
      name: 'MMC Other First',
      assetUrl: 'resdb:///9/9d/Mmc_other_first.png',
      description:
          'Awarded to Ryuvi & Engi for 1st Place in the MMC Gadgets/Tools+ category',
      apiKeywords: ['mmc20 other first'],
    ),
    'mmc20_other_second': Badge(
      name: 'MMC Other Second',
      assetUrl: 'resdb:///0/07/Mmc_other_second.png',
      description:
          'Awarded to GONT_3 & KOMASHIBA for 2nd Place in the Gadgets/Tools+ category',
      apiKeywords: ['mmc20 other second'],
    ),
    'mmc20_other_third': Badge(
      name: 'MMC Other Third',
      assetUrl: 'resdb:///5/5f/MMCCyanPlusBadge.png',
      description:
          'Awarded to guillefix & A Monsoon of Babies for 3rd Place in the MMC Gadgets/Tools+ category',
      apiKeywords: ['mmc20 other third'],
    ),
    'mmc20_translation': Badge(
      name: 'MMC Translation',
      assetUrl: 'resdb:///e/ea/Mmc_translation.png',
      description:
          'Given to litalita for translating a lot of the MMC content to Japanese',
      apiKeywords: ['mmc20 translation'],
    ),
    'mmc20_cow': Badge(
      name: 'MMC Cow',
      assetUrl: 'resdb:///b/b9/Mmc_cow.png',
      description:
          'Given to ProbablePrime for his efforts in the creation and management of the MMC voting systems',
      apiKeywords: ['mmc20 cow'],
    ),
  };

  // Helper method to get badge by tag name
  static Badge? getBadgeByTag(String tag) {
    return commonBadges[tag] ??
        teamBadges[tag] ??
        platformBadges[tag] ??
        disabilityBadges[tag] ??
        eventBadges[tag] ??
        mmcBadges[tag] ??
        optionalBadges[tag];
  }

  // Updated helper method to use apiKeywords
  static List<Badge> getBadgesForUser(List<String> userTags) {
    Set<Badge> userBadges = {};

    for (String tag in userTags) {
      String normalizedTag = tag.toLowerCase().trim();

      // Check all badge maps
      void checkBadgeMap(Map<String, Badge> badgeMap) {
        badgeMap.forEach((key, badge) {
          // Check if any of the badge's apiKeywords match the tag
          for (String keyword in badge.apiKeywords) {
            if (normalizedTag.contains(keyword.toLowerCase())) {
              userBadges.add(badge);
              break;
            }
          }
        });
      }

      // Skip custom badges
      if (normalizedTag.startsWith('custom badge:') ||
          normalizedTag.startsWith('custom 3d badge:')) {
        continue;
      }

      // Check all badge maps
      checkBadgeMap(commonBadges);
      checkBadgeMap(teamBadges);
      checkBadgeMap(platformBadges);
      checkBadgeMap(disabilityBadges);
      checkBadgeMap(optionalBadges);
      checkBadgeMap(eventBadges);
      checkBadgeMap(mmcBadges);
    }

    return userBadges.toList();
  }
}

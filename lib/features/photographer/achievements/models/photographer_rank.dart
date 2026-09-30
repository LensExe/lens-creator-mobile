class PhotographerRank {
  const PhotographerRank({
    required this.name,
    required this.minimumSessions,
    required this.commissionPercent,
  });

  final String name;
  final int minimumSessions;
  final int commissionPercent;
}

const photographerRanks = [
  PhotographerRank(name: 'Tân binh', minimumSessions: 0, commissionPercent: 10),
  PhotographerRank(name: 'Thợ Đồng', minimumSessions: 10, commissionPercent: 9),
  PhotographerRank(name: 'Thợ Bạc', minimumSessions: 30, commissionPercent: 8),
  PhotographerRank(name: 'Thợ Vàng', minimumSessions: 60, commissionPercent: 7),
  PhotographerRank(
    name: 'Thợ Kim Cương',
    minimumSessions: 120,
    commissionPercent: 5,
  ),
];

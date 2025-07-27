
const tips = [
  { title: "Turn off lights when not in use" },
  { title: "Use energy-efficient bulbs" }
];

export const getTips = async (req, res) => {
  res.status(200).json({ tips });
};

export const getRandomTip = async (req, res) => {
  const random = tips[Math.floor(Math.random() * tips.length)];
  res.status(200).json({ tip: random });
};

export const getTipsByAppliance = async (req, res) => {
  const { applianceType } = req.params;
  res.status(200).json({ tips });
};

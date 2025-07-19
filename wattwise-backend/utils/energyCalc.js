// utils/energyCalc.js
export function estimateMonthlyCost(watts, hoursPerDay, ratePerKwh = 0.13) {
  const kWhPerMonth = (watts * hoursPerDay * 30) / 1000;
  return +(kWhPerMonth * ratePerKwh).toFixed(2);
}

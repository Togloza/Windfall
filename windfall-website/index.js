// Connect to the network
let provider = new ethers.providers.Web3Provider(window.ethereum);

// Create a new instance of the Contract 
// with the provider we created and the contract's ABI and address
let contract = new ethers.Contract(contractAddress, contractAbi, provider.getSigner());

let stakeButton = document.getElementById("stakeButton");
let unstakeButton = document.getElementById("unstakeButton");
let startUnstakingButton = document.getElementById("startUnstakingButton");
let claimRewardsButton = document.getElementById("claimRewardsButton");


let data = await contract.retrievePastData();
let dailyOrWeekly = "DAILY"; // or "WEEKLY"
let date = new Date();
date.setDate(date.getDate() - 1); // set to yesterday
let dateString = date.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });

document.querySelector(".Daily").innerText = dailyOrWeekly;
document.querySelector(".June242023").innerText = dateString;
document.querySelector(".Xu9448bgg83 span").innerText = data.address;
document.querySelector(".Canto span").style.color = "white";
document.querySelector(".Canto span").innerText = data.amount;


stakeButton.addEventListener("click", async function() {
  let amountToStake = document.getElementById("stakeAmount").value;
  await contract.stake(amountToStake);
});

unstakeButton.addEventListener("click", async function() {
  await contract.unStake();
});

startUnstakingButton.addEventListener("click", async function() {
  await contract.startUnStaking();
});

claimRewardsButton.addEventListener("click", async function() {
  await contract.claimRewards();
});

function startTimer(drawTime) {
    let countdown = document.getElementById("countdown");

    setInterval(function() {
        let currentTime = new Date().getTime();
        let distance = drawTime - currentTime;

        let hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        let minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
        let seconds = Math.floor((distance % (1000 * 60)) / 1000);

        countdown.innerText = hours + "h " + minutes + "m " + seconds + "s ";
        if (distance < 0) {
            countdown.innerText = "DRAW TIME!";
        }
    }, 1000);
}


let contract = new ethers.Contract(contractAddress, contractABI, provider.getSigner());

let totalStakedElement = document.getElementById("totalStaked");
let dailyWindfallElement = document.getElementById("dailyWindfall");
let weeklyWindfallElement = document.getElementById("weeklyWindfall");

totalStakedElement.innerText = await contract.getTotalStaked();
dailyWindfallElement.innerText = await contract.getDailyWindfall();
weeklyWindfallElement.innerText = await contract.getWeeklyWindfall();

let stakeButton = document.getElementById("stakeButtons");
stakeButton.addEventListener("click", async function() {
    let amountToStake = /* get the amount to stake */;
    await contract.stake(amountToStake);
});

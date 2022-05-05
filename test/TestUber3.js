const Uber3 = artifacts.require('Uber3');

contract('Uber3', (accounts) => {
    let driver = accounts[1];
    let passenger1 = accounts[2];
    let passenger2 = accounts[3];

    it('Passenger resquet drive', async () => {
        const uber3Instance = await Uber3.deployed();

        assert.equal(await uber3Instance.travelRequestCount(), 0, "No travels request should be found");

        await uber3Instance.driverConnects({ from: driver });
        await uber3Instance.passengerConnects({ from: passenger1 });
        
        await uber3Instance.passengerRequestDrive(1, 2, {from: passenger1, value: web3.utils.toWei("0.01", 'ether')});

        assert.equal(await uber3Instance.travelRequestCount(), 1, "One travel requested not found");
    });

    it('Driver accept drive', async () => {
        const uber3Instance = await Uber3.deployed();

        assert.equal(await uber3Instance.travelRequestCount(), 1, "One travels request should be found");

        await uber3Instance.driverAcceptDrive(0, {from: driver});
        await uber3Instance.driverFinishDrive(0, {from: driver});
        let actualBalance = await web3.eth.getBalance(driver);
        await uber3Instance.passengerFinishDrive(0, {from: passenger1});

        expectedBalance = parseInt(actualBalance) + parseInt(web3.utils.toBN(web3.utils.toWei("0.01", 'ether')));
        actualBalance = await web3.eth.getBalance(driver);
        assert.equal(actualBalance, expectedBalance, "Balance incorrect!");

    });
});
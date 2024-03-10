![readme_phish_forge](https://github.com/anubhav11156/Pharaonik/assets/86551390/826fbdae-498d-4978-8cbe-43e2b4419a45)
## Phish Forge
![Static Badge](https://img.shields.io/badge/Easy-green?style=flat-square)  ![Static Badge](https://img.shields.io/badge/Phishing%20Attack-blue?style=flat-square)

Alice relies on a smart contract called "Trove" to store her ETH savings. She deposits funds using the "deposit()" function and withdraws them as needed using "withdraw()". Your objective is to steal all of Alice's savings!
### Objective
- Phish Alice and steal all her ETH savings to complete this excecise.
### Instructions
- Complete the ```attack()``` function in the Attack contract.
- Complete the ```caller()``` function in the [test_phish_forge](https://github.com/anubhav11156/Pharaonik/blob/main/tests/test_phish_forge.cairo) test.
- Test Command :
    ```bash
    snforge test tests::test_phish_forge::TestPhishForge::test_exploit --exact
    ```


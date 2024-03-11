pub mod Math {
    pub fn mul_div_down(x: u256, y: u256, denominator: u256) -> u256 {
        let prod = x * y;
        prod / denominator
    }

    pub fn mul_div_up(x: u256, y: u256, denominator: u256) -> u256 {
        let Zero = 0;
        let One = 1;
        let prod = x * y;

        if (prod == Zero) {
            return Zero;
        }

        let dec_prod = prod - One;

        let q2 = dec_prod / denominator;
        let inc_q2 = q2 + One;
        return inc_q2;
    }
}

#[cfg(test)]
mod TestKillSwitch {
    #[test]
    #[feature("safe_dispatcher")]
    fn test_exploit() {
        assert(true == false, 'wtf');
    }
}

import Principal "mo:base/Principal";
import Debug "mo:base/Debug";

import Converter "../../src/";

import T "../../src/Types";
import TestUtil "../utils/TestUtil";

shared actor class OldIndexerMock() : async T.OldIndexerInterface = {

    public func get_account_transactions(request : T.NewIndexerRequest) : async T.GetNewTransactionsResult {

        let account : T.Account = {
            owner = Principal.fromText(request.account.owner);
            subaccount = null;
        };
        let dapp : T.Account = {
            owner = Principal.fromText("czysu-eaaaa-aaaag-qcvdq-cai");
            subaccount = null;
        };

        if (account == Principal.toText(TestUtil.get_test_account(1).owner)) {
            return [ TestUtil.get_old_tx(100, 1000000000000, acct, dapp) ]; // 1 old token
        };

        if (account == Principal.toText(TestUtil.get_test_account(2).owner)) {
            return [ 
                TestUtil.get_old_tx(100, 1000000000000, acct, dapp), // 1 old token
                TestUtil.get_old_tx(105, 2000000000000, acct, dapp)  // 2 old tokens
            ];
        };

        if (account == Principal.toText(TestUtil.get_test_account(3).owner)) {
            return [ 
                TestUtil.get_old_tx(100, 1000000000000, acct, dapp), // 1 old token
                TestUtil.get_old_tx(105, 2000000000000, acct, dapp),  // 2 old tokens
                TestUtil.get_old_tx(110, 500000000000, dapp, acct)  // 0.5 old tokens
            ];
        };

        if (account == Principal.toText(TestUtil.get_test_account(4).owner)) {
            return [ 
                TestUtil.get_old_tx(100, 1000000000000, acct, dapp), // 1 old token
                TestUtil.get_old_tx(105, 2000000000000, acct, dapp)  // 2 old tokens
            ];
        };

        if (account == Principal.toText(TestUtil.get_test_account(5).owner)) {
            return [ 
                TestUtil.get_old_tx(100, 1000000000000, acct, dapp), // 1 old token
                TestUtil.get_old_tx(105, 2000000000000, acct, dapp),  // 2 old tokens
                TestUtil.get_old_tx(110, 500000000000, dapp, acct)  // 0.5 old tokens
            ];
        };

        if (account == Principal.toText(TestUtil.get_test_account(6).owner)) {
            return [ 
                TestUtil.get_old_tx(100, 1000000000000, acct, dapp), // 1 old token
                TestUtil.get_old_tx(105, 2000000000000, acct, dapp),  // 2 old tokens
                TestUtil.get_old_tx(110, 500000000000, dapp, acct)  // 0.5 old tokens
            ];
        };

        if (account == Principal.toText(TestUtil.get_test_account(7).owner)) {
            return [ TestUtil.get_old_tx(100, 1234567891234, acct, dapp) ]; // 1 old token
        };

        if (account == Principal.toText(TestUtil.get_test_account(8).owner)) {
            return [ 
                TestUtil.get_old_tx(100, 1000000000000, acct, dapp), // 1 old token
                TestUtil.get_old_tx(195, 2000000000000, dapp, acct)  // 2 old tokens
            ];
        };

        if (account == Principal.toText(TestUtil.get_test_account(10).owner)) {
            return [ 
                TestUtil.get_old_tx(100, 1000000000000, acct, dapp) // 1 old token
            ];
        };

        if (account == Principal.toText(TestUtil.get_test_account(11).owner)) {
            return [ 
                    TestUtil.get_old_tx(195, 2000000000000, dapp, acct)  // 2 old tokens
            ];
        };

        if (account == Principal.toText(TestUtil.get_test_account(12).owner)) {
            return [ 
                TestUtil.get_old_tx(100, 1000000000000, acct, dapp), // 1 old token
                TestUtil.get_old_tx(195, 2000000000000, dapp, acct)  // 2 old tokens
            ];
        };

        if (account == Principal.toText(TestUtil.get_test_account(13).owner)) {
            return [ 
                TestUtil.get_old_tx(100, 1000000000000, acct, dapp) // 1 old token
            ];
        };

        if (account == Principal.toText(TestUtil.get_test_account(14).owner)) {
            return [ TestUtil.get_old_tx(100, 1001000000000000, acct, dapp) ]; // 1001 old tokens
        };

        if (account == Principal.toText(TestUtil.get_test_account(15).owner)) {
            return [ 
                TestUtil.get_old_tx(100, 2000000000000, acct, dapp), // 2 old token
                TestUtil.get_old_tx(105, 999000000000000, acct, dapp)  // 999 old tokens
            ];
        };

        if (account == Principal.toText(TestUtil.get_test_account(16).owner)) {
            return [ 
                TestUtil.get_old_tx(100, 1001000000000000, acct, dapp), // 1001 old token
                TestUtil.get_old_tx(195, 999000000000000, dapp, acct)  // 999 old tokens
            ];
        };

        if (account == Principal.toText(TestUtil.get_test_account(20).owner)) {
            return [ TestUtil.get_old_tx(100, 1001000000000000, acct, dapp) ]; // 1001 old tokens
        };

        if (account == Principal.toText(TestUtil.get_test_account(21).owner)) {
            return [ TestUtil.get_old_tx(100, 110000000, acct, dapp) ]; // 1 old fee + 1 new fee
        };

        if (account == Principal.toText(TestUtil.get_test_account(22).owner)) {
            return [ TestUtil.get_old_tx(100, 101000000, acct, dapp) ]; // 1 old fee + less than 1 new fee
        };

        if (account == Principal.toText(TestUtil.get_test_account(24).owner)) {
            Debug.trap("Old indexer canister mock trapped.")
        };

        if (account == Principal.toText(TestUtil.get_test_account(26).owner)) {
            return [ TestUtil.get_old_tx(100, 1000000000000, acct, dapp) ]; // 1 old token
        };

        #Ok(1);
    };

    public func synch_archive_full(token: Text) : async T.OldSynchStatus {
        {
            tx_total = 1234;
            tx_synched = 1233;
        };
    };

}
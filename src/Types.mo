import Time "mo:base/Time";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Hash "mo:base/Hash";
import Map "mo:base/HashMap";
import List "mo:base/List";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Error "mo:base/Error";

type Timestamp = Nat64;
type Subaccount = Blob;
type TxIndex = Nat;
type Balance = Nat;
type TxIndexes = List.List<TxIndex>;
type Log = Buffer.Buffer<LogItem>;

type ValidationResult = {
    #Ok : Text;
    #Err : Text;
};

type ConverterContext = {
    caller : Principal;
    state : ConverterState;
    account : Account;
    converter : Account;
    governance : Principal;
};

type ConverterState = {

    persistent : ConverterPersistentState;
    ephemeral : ConverterEphemeralState;

};

type ConverterPersistentState = {

    var stable_new_latest_sent_txids : [(Principal, TxIndex)];
    var stable_old_latest_sent_txids : [(Principal, TxIndex)];
    var stable_cooldowns : [(Principal, Time.Time)];
    var stable_log : [LogItem];

    var old_token_canister : OldToken;
    var old_indexer_canister : OldIndexerInterface;
    var new_token_canister : ICRC1;
    var new_indexer_canister : NewIndexerInterface; 

    var settings : Settings;

};

type ConverterEphemeralState = {
    var new_latest_sent_txids : Map.HashMap<Principal, TxIndex>;
    var old_latest_sent_txids : Map.HashMap<Principal, TxIndex>;
    var cooldowns : Map.HashMap<Principal, Time.Time>;
    var log : Log;
};

type Account = {
    owner : Principal;
    subaccount : ?Subaccount;
};

type AccountBalance = {
    owner : Principal;
    balance : Balance;
};

type NewTransactionWithId = {
    id : TxIndex;
    transaction : NewTransaction;
};

type GetNewTransactions = {
    transactions : [NewTransactionWithId];
    oldest_tx_id : ?TxIndex;
};

type GetNewTransactionsErr = {
    message : Text;
};

type GetNewTransactionsResult = {
    #Ok : GetNewTransactions;
    #Err : GetNewTransactionsErr;
};

type NewTransaction = {
    kind : Text;
    mint : ?Mint;
    burn : ?NewBurn;
    transfer : ?NewTransfer;
    approve : ?Approve;
    timestamp : Nat64;
};

type BlockIndex = Nat;

type NewIndexerRequest = {
    max_results : Nat;
    start : ?BlockIndex;
    account : Account;
};

type OldTransaction = {
    kind : Text;
    mint : ?Mint;
    burn : ?OldBurn;
    transfer : ?OldTransfer;
    index : TxIndex;
    timestamp : Timestamp;
};

type OldTransfer = {
    from : Account;
    to : Account;
    amount : Balance;
    fee : ?Balance;
    memo : ?Blob;
    created_at_time : ?Nat64;
};

type NewTransfer = {
    amount : Nat;
    from : Account;
    to : Account;
    spender : ?Account;
    memo : ?Blob;
    created_at_time : ?Nat64;
    fee : ?Nat;
};

type Mint = {
    to : Account;
    amount : Balance;
    memo : ?Blob;
    created_at_time : ?Nat64;
};

type OldBurn = {
    from : Account;
    amount : Balance;
    memo : ?Blob;
    created_at_time : ?Nat64;
};

type NewBurn = {
    amount : Nat;
    from : Account;
    spender : ?Account;
    memo : ?Blob;
    created_at_time : ?Nat64;
};

type Approve = {
    amount : Nat;
    from : Account;
    spender : ?Account;
    expected_allowance : ?Nat;
    expires_at : ?Nat64;
    memo : ?Blob;
    created_at_time : ?Nat64;
    fee : ?Nat;
};

type OldTransactionRange = {
    transactions: [OldTransaction];
};

type OldSynchStatus = {
    tx_total : TxIndex;
    tx_synched : TxIndex;
};

type TransferArgs = {
    from_subaccount : ?Subaccount;
    to : Account;
    amount : Balance;
    fee : ?Balance;
    memo : ?Blob;
    created_at_time : ?Nat64;
};

type BurnArgs = {
    from_subaccount : ?Subaccount;
    amount : Balance;
    memo : ?Blob;
    created_at_time : ?Nat64;
};

type TimeError = {
    #TooOld;
    #CreatedInFuture : { ledger_time : Timestamp };
};

type TransferError = TimeError or {
    #BadFee : { expected_fee : Balance };
    #BadBurn : { min_burn_amount : Balance };
    #InsufficientFunds : { balance : Balance };
    #Duplicate : { duplicate_of : TxIndex };
    #TemporarilyUnavailable;
    #GenericError : { error_code : Nat; message : Text };
};

type TransferResult = {
    #Ok : TxIndex;
    #Err : TransferError;
};

type ConvertError = TransferError or {
    #InvalidAccount;
    #OnCooldown : { since : Int; remaining : Int; };
    #StaleIndexer : { txid: ?TxIndex };
    #ExternalCanisterError : { message: Text };
    #IsSeeder;
    #IsBurner;
    #NotActive;
    #TooManyTransactions;
    #NotController;
    #ConversionsNotAllowed;
    #IndexUnderflow : { 
        new_total_balance_underflow_d8 : Balance;
        old_balance_underflow_d12 : Balance;
        new_sent_acct_to_dapp_d8 : Balance;
        new_sent_dapp_to_acct_d8 : Balance;
        old_sent_acct_to_dapp_d12 : Balance;
        old_sent_dapp_to_acct_d12 : Balance;
    };
};

type ConvertResult = {
    #Ok : TxIndex;
    #Err : ConvertError;
};

type IndexAccountResult = {
    #Ok : IndexedAccount;
    #Err : IndexAccountError;
};

type IndexAccountError = {
    #InvalidAccount;
    #NotActive;
    #TooManyTransactions;
    #ExternalCanisterError : { message: Text };   
};

type IndexedAccount = {
    new_total_balance_d8 : Balance;
    old_balance_d12 : Balance;
    new_total_balance_underflow_d8 : Balance;
    old_balance_underflow_d12 : Balance;
    new_sent_acct_to_dapp_d8 : Balance;
    new_sent_dapp_to_acct_d8 : Balance;
    old_sent_acct_to_dapp_d12 : Balance;
    old_sent_dapp_to_acct_d12 : Balance;
    is_seeder : Bool;
    is_burner : Bool;
    old_latest_send_found : Bool;
    old_latest_send_txid : ?TxIndex;
    new_latest_send_found : Bool;
    new_latest_send_txid : ?TxIndex;
};

type IndexOldBalanceResult = {
    old_balance_d12 : Balance;
    old_balance_underflow_d12 : Balance;
    old_sent_acct_to_dapp_d12 : Balance;
    old_sent_dapp_to_acct_d12 : Balance;
    is_burner : Bool;
    old_latest_send_found : Bool;
    old_latest_send_txid : ?TxIndex;
};

type IndexNewBalanceResult = {
    new_sent_acct_to_dapp_d8 : Balance;
    new_sent_dapp_to_acct_d8 : Balance;
    is_seeder : Bool;
    new_latest_send_found : Bool;
    new_latest_send_txid : ?TxIndex;
};

type CanisterIds = {
    new_token_canister_id : Principal;
    new_indexer_canister_id : Principal;
    old_token_canister_id : Principal;
    old_indexer_canister_id : Principal;
};

type GetCanisterIdsResult = CanisterIds;

type BurnOldTokensResult = {
    #Ok : TxIndex;
    #Err : BurnOldTokensErr;
};

type BurnOldTokensErr = ConvertError or {
    #IsNotController;
    #BurnsNotAllowed;
};

type Settings = {
  allow_conversions : Bool;
  allow_burns : Bool;
  new_fee_d8 : Balance;
  old_fee_d12 : Balance;
  d8_to_d12 : Int;
  new_seeder_min_amount_d8 : Balance;
  old_burner_min_amount_d12 : Balance;
  cooldown_ns : Nat; 
  max_transactions : Nat;
};

type Status = {
    active : Bool;
    canister_id : Text;
};

type LogItem = {
    name : Text;
    message : Text;
    timestamp : Timestamp;
    caller : Principal;
    account : Account;
    converter : Account;

    convert : ?ConvertLogItem;
    burn : ?BurnLogItem;
    set_settings : ?SetSettingsLogItem;
    set_canisters : ?SetCanistersLogItem;
    exit : ?ExitLogItem;
};

type ConvertLogItem = {
    result : ConvertResult;
    args : TransferArgs;
    account : IndexedAccount;
};

type BurnLogItem = {
    result : TransferResult;
    args : BurnArgs;
};

type SetSettingsLogItem = {
    old_settings : Settings;
    new_settings : Settings;
};

type SetCanistersLogItem = {
    old_canisters : CanisterIds;
    new_canisters : CanisterIds;
};

type ExitLogItem = {
    trapped_message : Text;
    convert_result : ?ConvertResult;
    burn_result : ?BurnOldTokensResult;
};

type Mocks = {
    old_token_mock : TokenInterface;
    old_indexer_mock : OldIndexerInterface;
    new_token_mock : TokenInterface;
    new_indexer_mock : NewIndexerInterface;
};

type ConverterInterface = actor {
    get_account(account: Account) : async IndexAccountResult;
    convert_account(account: Account) : async ConvertResult;
    burn_old_tokens(amount : Balance) : async BurnOldTokensResult;
};

type OldIndexerInterface = actor {
    get_account_transactions(request : NewIndexerRequest) : async GetNewTransactionsResult;
    synch_archive_full(token: Text) : async OldSynchStatus;
};  

type NewIndexerInterface = actor {
    get_account_transactions(request : NewIndexerRequest) : async GetNewTransactionsResult;
};  

type TokenInterface = actor {
    icrc1_transfer(args : TransferArgs) : async TransferResult;
    burn(args : BurnArgs) : async TransferResult;    
};

type Duration = Nat64;

type myTransferError = {
    #BadFee : { expected_fee : Nat };
    #BadBurn : { min_burn_amount : Nat };
    #InsufficientFunds : { balance : Nat };
    #TooOld;
    #CreatedInFuture : { ledger_time : Timestamp };
    #Duplicate : { duplicate_of : Nat };
    #TemporarilyUnavailable;
    #GenericError : { error_code : Nat; message : Text };
};

type Value = {
    #Nat : Nat;
    #Int : Int;
    #Text : Text;
    #Blob : Blob;
};

type Tokens = Nat;

type TxKind = {
    #Burn;
    #Mint;
    #Transfer;
};

type TransactionView = {
    amount : Tokens;
    fee : Tokens;
    from : Text;
    kind : TxKind;
    timestamp : Timestamp;
    to : Text;
};

type OldToken = actor {
    icrc1_metadata : query () -> async [(Text, Value)];
    icrc1_name : query () -> async Text;
    icrc1_symbol : query () -> async Text;
    icrc1_decimals : query () -> async Nat8;
    icrc1_fee : query () -> async Nat;
    icrc1_total_supply : query () -> async Nat;
    icrc1_minting_account : query () -> async ?Account;
    icrc1_balance_of : query (Account) -> async Nat;
    icrc1_transfer : (TransferArgs) -> async { #Ok : Nat; #Err : TransferError };
    icrc1_supported_standards : query () -> async [{ name : Text; url : Text }];
    transaction : shared query (Nat, Nat) -> async {
        content : [TransactionView];
        limit : Nat;
        offset : Nat;
        totalElements : Nat;
    };
};

type ICRC1 = actor {
    icrc1_metadata : query () -> async [(Text, Value)];
    icrc1_name : query () -> async Text;
    icrc1_symbol : query () -> async Text;
    icrc1_decimals : query () -> async Nat8;
    icrc1_fee : query () -> async Nat;
    icrc1_total_supply : query () -> async Nat;
    icrc1_minting_account : query () -> async ?Account;
    icrc1_balance_of : query (Account) -> async Nat;
    icrc1_transfer : (TransferArgs) -> async { #Ok : Nat; #Err : TransferError };
    icrc1_supported_standards : query () -> async [{ name : Text; url : Text }];
};

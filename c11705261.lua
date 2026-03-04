--エクシーズ・チェンジ・タクティクス
-- 效果：
-- ①：「超量变身战术」在自己场上只能有1张表侧表示存在。
-- ②：自己场上有「希望皇 霍普」怪兽超量召唤时，支付500基本分才能发动。自己抽1张。
function c11705261.initial_effect(c)
	c:SetUniqueOnField(1,0,11705261)
	-- ①：「超量变身战术」在自己场上只能有1张表侧表示存在。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：自己场上有「希望皇 霍普」怪兽超量召唤时，支付500基本分才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11705261,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c11705261.condition)
	e2:SetCost(c11705261.cost)
	e2:SetTarget(c11705261.target)
	e2:SetOperation(c11705261.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为己方的「希望皇 霍普」超量怪兽
function c11705261.filter(c,tp)
	return c:IsSetCard(0x107f) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果发动条件，判断是否有己方的「希望皇 霍普」超量怪兽被特殊召唤成功
function c11705261.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11705261.filter,1,nil,tp)
end
-- 支付LP的函数，检查是否能支付500基本分
function c11705261.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 设置效果目标的函数，判断玩家是否可以抽卡
function c11705261.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁处理的目标玩家为当前处理的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息为抽卡效果，目标为当前玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数，执行抽卡效果
function c11705261.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家以效果原因抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end

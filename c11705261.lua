--エクシーズ・チェンジ・タクティクス
-- 效果：
-- ①：「超量变身战术」在自己场上只能有1张表侧表示存在。
-- ②：自己场上有「希望皇 霍普」怪兽超量召唤时，支付500基本分才能发动。自己抽1张。
function c11705261.initial_effect(c)
	c:SetUniqueOnField(1,0,11705261)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
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
-- 筛选特殊召唤成功的怪兽中是否存在持有「希望皇 霍普」字段（0x107f）、控制者为发动玩家且为超量召唤的怪兽。
function c11705261.filter(c,tp)
	return c:IsSetCard(0x107f) and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 诱发条件判定：本次特殊召唤成功的怪兽组中，至少存在1只满足filter条件的「希望皇 霍普」怪兽。
function c11705261.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11705261.filter,1,nil,tp)
end
-- 发动代价处理：支付500基本分才能发动；先检查能否支付，能则实际支付。
function c11705261.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：在发动时确认玩家tp能否支付500基本分，若不能则不能发动。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分，作为发动效果的COST。
	Duel.PayLPCost(tp,500)
end
-- 效果发动时的目标设定：将抽卡对象玩家设为tp，抽卡数设为1，并向系统登记本次效果将进行的抽卡操作。
function c11705261.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认玩家tp能否通过效果抽1张卡，若不能则无法发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁处理的对象玩家设置为tp，表示该效果以tp为抽卡对象。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁处理的对象参数设置为1，即本次效果要抽的卡数为1。
	Duel.SetTargetParam(1)
	-- 向系统登记操作信息：本次效果将使tp抽1张卡（CATEGORY_DRAW），用于后续连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理部分：从连锁信息中取出目标玩家和抽卡数，并让该玩家以效果原因抽对应数量的卡。
function c11705261.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取效果处理所需的目标玩家p和抽卡参数d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以REASON_EFFECT为原因，让玩家p抽d张卡，完成抽卡效果。
	Duel.Draw(p,d,REASON_EFFECT)
end

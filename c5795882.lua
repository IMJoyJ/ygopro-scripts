--ヴァンパイアの領域
-- 效果：
-- ①：1回合1次，支付500基本分才能发动。这个回合自己在通常召唤外加上只有1次，自己主要阶段可以把1只「吸血鬼」怪兽召唤。
-- ②：只要这张卡在魔法与陷阱区域存在，自己的「吸血鬼」怪兽给与对方战斗伤害的场合发动。自己基本分回复那个数值。
function c5795882.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，支付500基本分才能发动。这个回合自己在通常召唤外加上只有1次，自己主要阶段可以把1只「吸血鬼」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5795882,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c5795882.sumcost)
	e2:SetTarget(c5795882.sumtg)
	e2:SetOperation(c5795882.sumop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在魔法与陷阱区域存在，自己的「吸血鬼」怪兽给与对方战斗伤害的场合发动。自己基本分回复那个数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5795882,1))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c5795882.reccon)
	e3:SetTarget(c5795882.rectg)
	e3:SetOperation(c5795882.recop)
	c:RegisterEffect(e3)
end
-- 支付500基本分的发动代价（Cost）
function c5795882.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分
	Duel.PayLPCost(tp,500)
end
-- 检查是否能增加召唤次数以及是否已使用过该效果
function c5795882.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以通常召唤以及是否可以获得额外的通常召唤次数
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 检查本回合是否尚未适用过此效果（确保1回合只能获得1次该效果）
		and Duel.GetFlagEffect(tp,5795882)==0 end
end
-- 注册增加「吸血鬼」怪兽召唤次数的效果，并注册已使用该效果的标记
function c5795882.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 若本回合已适用过此效果则直接返回
	if Duel.GetFlagEffect(tp,5795882)~=0 then return end
	-- ①：这个回合自己在通常召唤外加上只有1次，自己主要阶段可以把1只「吸血鬼」怪兽召唤。②：只要这张卡在魔法与陷阱区域存在，自己的「吸血鬼」怪兽给与对方战斗伤害的场合发动。自己基本分回复那个数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(5795882,2))  --"使用「吸血鬼的领域」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 设置额外召唤的怪兽必须是「吸血鬼」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x8e))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将增加召唤次数的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册本回合已适用该效果的标记，在回合结束时重置
	Duel.RegisterFlagEffect(tp,5795882,RESET_PHASE+PHASE_END,0,1)
end
-- 检查是否为自己的「吸血鬼」怪兽给与对方战斗伤害的场合
function c5795882.reccon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():IsControler(tp) and eg:GetFirst():IsSetCard(0x8e)
end
-- 效果2的发动准备，设置回复基本分的操作信息
function c5795882.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复基本分的对象为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复基本分的数值为受到的战斗伤害值
	Duel.SetTargetParam(ev)
	-- 设置当前连锁的操作信息为回复自己与伤害值等同的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果2的实际处理，使自己回复与伤害值等同的基本分
function c5795882.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行回复基本分的操作
	Duel.Recover(p,d,REASON_EFFECT)
end

--The big SATURN
-- 效果：
-- 这张卡不能作从手卡·卡组的特殊召唤。丢弃1张手卡并支付1000基本分。直到结束阶段时这张卡的攻击力上升1000。这个效果1回合只有1次在自己的主要阶段才能使用。对方控制的卡的效果把这张卡破坏送去墓地时，双方受到那个攻击力数值的伤害。
function c34004470.initial_effect(c)
	-- 这张卡不能作从手卡·卡组的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为无法特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 丢弃1张手卡并支付1000基本分。直到结束阶段时这张卡的攻击力上升1000。这个效果1回合只有1次在自己的主要阶段才能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34004470,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c34004470.atcost)
	e2:SetOperation(c34004470.atop)
	c:RegisterEffect(e2)
	-- 对方控制的卡的效果把这张卡破坏送去墓地时，双方受到那个攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34004470,1))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c34004470.damcon)
	e3:SetTarget(c34004470.damtg)
	e3:SetOperation(c34004470.damop)
	c:RegisterEffect(e3)
end
-- 检查玩家是否能支付1000基本分并手牌中是否存在可丢弃的卡。
function c34004470.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000)
		-- 检查玩家手牌中是否存在可丢弃的卡。
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家丢弃1张手牌。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	-- 让玩家支付1000基本分。
	Duel.PayLPCost(tp,1000)
end
-- 将自身攻击力上升1000点直到结束阶段。
function c34004470.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 设置攻击力增加1000的效果，并在结束阶段重置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 判断该卡是否因对方效果被送入墓地且玩家为控制者。
function c34004470.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,0x41)==0x41 and rp==1-tp and c:IsPreviousControler(tp)
end
-- 设置伤害效果的目标参数并注册操作信息。
function c34004470.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetAttack()
	-- 将当前处理的连锁对象参数设置为攻击力值。
	Duel.SetTargetParam(dam)
	-- 设置连锁操作信息为双方受到伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,dam)
end
-- 对双方造成等于攻击力的伤害并完成伤害处理流程。
function c34004470.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标参数（即攻击力值）。
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 给与对方玩家等于攻击力值的伤害。
	Duel.Damage(1-tp,d,REASON_EFFECT,true)
	-- 给与自己玩家等于攻击力值的伤害。
	Duel.Damage(tp,d,REASON_EFFECT,true)
	-- 完成伤害处理流程的触发时点。
	Duel.RDComplete()
end

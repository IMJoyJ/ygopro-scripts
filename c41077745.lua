--E・HERO アイスエッジ
-- 效果：
-- 1回合1次，自己的主要阶段一丢弃1张手卡发动。这个回合这张卡可以直接攻击对方玩家。此外，这张卡直接攻击给与对方基本分战斗伤害时，可以把对方的魔法与陷阱卡区域盖放的1张卡破坏。
function c41077745.initial_effect(c)
	-- 效果原文内容：1回合1次，自己的主要阶段一丢弃1张手卡发动。这个回合这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41077745,0))  --"直接攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c41077745.datcon)
	e1:SetCost(c41077745.datcost)
	e1:SetOperation(c41077745.datop)
	c:RegisterEffect(e1)
	-- 效果原文内容：此外，这张卡直接攻击给与对方基本分战斗伤害时，可以把对方的魔法与陷阱卡区域盖放的1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41077745,1))  --"魔陷破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(c41077745.descon)
	e2:SetTarget(c41077745.destg)
	e2:SetOperation(c41077745.desop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断是否处于主要阶段一
function c41077745.datcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：当前阶段等于主要阶段一
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 规则层面作用：设置丢弃手卡作为发动代价
function c41077745.datcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否有满足条件的手卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面作用：丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 规则层面作用：设置直接攻击效果
function c41077745.datop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 效果原文内容：这个回合这张卡可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 规则层面作用：判断是否为对方造成战斗伤害且未被阻挡
function c41077745.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：对方玩家不等于效果发动玩家且攻击对象为空
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 规则层面作用：过滤对方魔法与陷阱区域的盖放卡
function c41077745.filter(c)
	return c:IsFacedown() and c:GetSequence()~=5
end
-- 规则层面作用：设置破坏效果的目标选择
function c41077745.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c41077745.filter(chkc) end
	-- 规则层面作用：检查对方魔法与陷阱区域是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(c41077745.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 规则层面作用：提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面作用：选择对方魔法与陷阱区域的一张盖放卡
	local g=Duel.SelectTarget(tp,c41077745.filter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 规则层面作用：设置操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 规则层面作用：执行破坏效果
function c41077745.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 规则层面作用：以效果原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

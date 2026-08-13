--霊魂鳥－忍鴉
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：1回合1次，这张卡和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，从手卡丢弃1只灵魂怪兽才能发动。这张卡的攻击力·守备力直到战斗阶段结束时上升丢弃的怪兽的攻击力·守备力的各自数值。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c39817919.initial_effect(c)
	-- 为这张卡添加灵魂怪兽的回归效果：在召唤·反转成功的回合结束阶段，这张卡回到持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定值设为 false，使这张卡不能被特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：1回合1次，这张卡和对方怪兽进行战斗的从伤害步骤开始时到伤害计算前，从手卡丢弃1只灵魂怪兽才能发动。这张卡的攻击力·守备力直到战斗阶段结束时上升丢弃的怪兽的攻击力·守备力的各自数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39817919,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c39817919.atkcon)
	e2:SetTarget(c39817919.atkcost)
	e2:SetOperation(c39817919.atkop)
	c:RegisterEffect(e2)
end
-- 效果发动条件函数：仅在伤害步骤开始后、伤害计算前，且这张卡正与对方怪兽进行战斗时才满足发动条件。
function c39817919.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于伤害步骤。
	local phase=Duel.GetCurrentPhase()
	-- 若当前不是伤害步骤，或已经进行过伤害计算，则不满足发动条件，返回 false。
	if phase~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	-- 获取当前攻击怪兽，用于判断战斗对象。
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽是对方怪兽，则将判定对象改为被攻击的怪兽（即这张卡）。
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	-- 确认与战斗相关的是这张卡自身、这张卡仍与战斗关联，并且存在攻击目标（即确实在进行战斗）。
	return tc==e:GetHandler() and tc:IsRelateToBattle() and Duel.GetAttackTarget()~=nil
end
-- 手牌丢弃的过滤条件：必须是灵魂怪兽，且攻击力或守备力至少有一项大于0，并且能够被丢弃。
function c39817919.cfilter(c)
	return c:IsType(TYPE_SPIRIT) and (c:GetAttack()>0 or c:GetDefense()>0) and c:IsDiscardable()
end
-- 发动代价函数：从手卡选择并丢弃1只符合条件的灵魂怪兽作为代价，并将丢弃的怪兽记录在效果中，供后续处理使用。
function c39817919.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只符合条件的灵魂怪兽，作为能否发动的前提条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c39817919.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家显示选择提示，要求从手卡中选择要丢弃的卡牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家从手卡中选择1只符合条件的灵魂怪兽，用于支付代价。
	local g=Duel.SelectMatchingCard(tp,c39817919.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	-- 将选中的灵魂怪兽以代价和丢弃的理由送去墓地。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果处理函数：将丢弃怪兽的攻击力和守备力数值分别加到这张卡的攻击力、守备力上，直到战斗阶段结束。
function c39817919.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local atk=math.max(tc:GetAttack(),0)
	local def=math.max(tc:GetDefense(),0)
	if c:IsRelateToBattle() and c:IsFaceup() and c:IsControler(tp) then
		-- 这张卡的攻击力·守备力直到战斗阶段结束时上升丢弃的怪兽的攻击力·守备力的各自数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(def)
		c:RegisterEffect(e2)
	end
end

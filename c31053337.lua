--BF－激震のアブロオロス
-- 效果：
-- 这张卡不能特殊召唤。1回合1次，可以把这张卡的攻击力下降1000，对方的魔法与陷阱卡区域存在的卡全部回到持有者手卡。这个效果在主要阶段1才能使用。和这张卡进行战斗的怪兽不会被那次战斗破坏并在伤害计算后回到持有者手卡。
function c31053337.initial_effect(c)
	-- 对应效果原文：“这张卡不能特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件效果的值为false，使这张卡不能进行任何特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 对应效果原文：“1回合1次，可以把这张卡的攻击力下降1000，对方的魔法与陷阱卡区域存在的卡全部回到持有者手卡。这个效果在主要阶段1才能使用。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31053337,0))  --"对方魔法陷阱区的卡全部回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c31053337.condition)
	e2:SetTarget(c31053337.target)
	e2:SetOperation(c31053337.operation)
	c:RegisterEffect(e2)
	-- 对应效果原文：“和这张卡进行战斗的怪兽不会被那次战斗破坏”。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c31053337.indestg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 对应效果原文：“并在伤害计算后回到持有者手卡。”
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31053337,1))  --"战斗的怪兽回到手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLED)
	e4:SetOperation(c31053337.operation2)
	c:RegisterEffect(e4)
end
-- 该效果的发动条件：当前阶段必须为主要阶段1，否则不能发动。
function c31053337.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1，是则返回true。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 筛选条件：对方魔法陷阱区中位于主要魔陷区（序号<5，不含场地格）且可以被加入手卡的卡。
function c31053337.filter(c)
	return c:IsAbleToHand() and c:GetSequence()<5
end
-- 效果发动的合法性检查与目标设定：验证自身攻击力不低于1000且存在合法对象，并获取全部对象卡后设置回手牌的操作信息。
function c31053337.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：此卡的攻击力至少为1000，且对方魔陷区存在至少1张满足回手条件的卡。
	if chk==0 then return e:GetHandler():GetAttack()>=1000 and Duel.IsExistingMatchingCard(c31053337.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 获取对方魔法陷阱区中所有满足filter条件的卡，作为预计回手的对象集合。
	local g=Duel.GetMatchingGroup(c31053337.filter,tp,0,LOCATION_SZONE,nil)
	-- 设置操作信息：本次连锁效果将把这些卡加入持有者手卡（CATEGORY_TOHAND），数量为对象数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：若此卡与效果仍关联且表侧表示，则将对方魔陷区满足条件的卡全部送回持有者手卡，并使此卡攻击力下降1000。
function c31053337.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 效果处理时再次获取对方魔陷区中满足条件的卡，确定实际回手的卡。
		local g=Duel.GetMatchingGroup(c31053337.filter,tp,0,LOCATION_SZONE,nil)
		-- 将所有获取到的卡以效果原因送回其持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 对应效果原文：“把这张卡的攻击力下降1000”。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		c:RegisterEffect(e1)
	end
end
-- 战斗破坏抗性的对象判定：只有与这张卡进行战斗的怪兽才适用不被战斗破坏的效果。
function c31053337.indestg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
-- 伤害计算后效果处理：若战斗对象怪兽仍与本次战斗关联，则将其送回持有者手卡。
function c31053337.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		-- 将与这张卡战斗的怪兽以效果原因送回持有者手卡。
		Duel.SendtoHand(bc,nil,REASON_EFFECT)
	end
end

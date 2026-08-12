--BF－激震のアブロオロス
-- 效果：
-- 这张卡不能特殊召唤。1回合1次，可以把这张卡的攻击力下降1000，对方的魔法与陷阱卡区域存在的卡全部回到持有者手卡。这个效果在主要阶段1才能使用。和这张卡进行战斗的怪兽不会被那次战斗破坏并在伤害计算后回到持有者手卡。
function c31053337.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为始终返回假值，表示无法特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把这张卡的攻击力下降1000，对方的魔法与陷阱卡区域存在的卡全部回到持有者手卡。这个效果在主要阶段1才能使用。
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
	-- 和这张卡进行战斗的怪兽不会被那次战斗破坏并在伤害计算后回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c31053337.indestg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 战斗的怪兽回到手卡
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31053337,1))  --"战斗的怪兽回到手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLED)
	e4:SetOperation(c31053337.operation2)
	c:RegisterEffect(e4)
end
-- 效果在主要阶段1才能使用。
function c31053337.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 过滤函数，用于筛选可以送回手卡的魔法与陷阱卡
function c31053337.filter(c)
	return c:IsAbleToHand() and c:GetSequence()<5
end
-- 设置效果目标为对方魔法与陷阱区域的卡
function c31053337.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：攻击力大于等于1000且对方魔法与陷阱区域存在可送回手卡的卡
	if chk==0 then return e:GetHandler():GetAttack()>=1000 and Duel.IsExistingMatchingCard(c31053337.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 获取满足条件的对方魔法与陷阱区域的卡组
	local g=Duel.GetMatchingGroup(c31053337.filter,tp,0,LOCATION_SZONE,nil)
	-- 设置连锁操作信息，指定将卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 执行效果操作：将对方魔法与陷阱区域的卡送回手卡，并将自身攻击力下降1000
function c31053337.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 获取满足条件的对方魔法与陷阱区域的卡组
		local g=Duel.GetMatchingGroup(c31053337.filter,tp,0,LOCATION_SZONE,nil)
		-- 将卡送回手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将自身攻击力下降1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		c:RegisterEffect(e1)
	end
end
-- 判断目标是否为自身战斗中的怪兽
function c31053337.indestg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end
-- 当怪兽与自身战斗后，将其送回手卡
function c31053337.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		-- 将战斗怪兽送回手卡
		Duel.SendtoHand(bc,nil,REASON_EFFECT)
	end
end

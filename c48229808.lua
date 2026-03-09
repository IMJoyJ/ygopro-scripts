--ホルスの黒炎竜 LV8
-- 效果：
-- 这张卡不能通常召唤。只能通过「荷鲁斯之黑炎龙 LV6」的效果特殊召唤。只要这张卡在自己场上表侧表示存在，可以把魔法的发动和效果无效并且破坏。
function c48229808.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文内容：这张卡不能通常召唤。只能通过「荷鲁斯之黑炎龙 LV6」的效果特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 规则层面操作：设置该卡无法通过通常召唤方式特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 效果原文内容：只要这张卡在自己场上表侧表示存在，可以把魔法的发动和效果无效并且破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48229808,0))  --"魔法发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c48229808.condition)
	e2:SetTarget(c48229808.target)
	e2:SetOperation(c48229808.operation)
	c:RegisterEffect(e2)
end
c48229808.lvup={11224103}
c48229808.lvdn={75830094,11224103}
-- 规则层面操作：判断是否满足发动条件，即该卡未因战斗破坏、发动的是魔法卡且连锁可被无效
function c48229808.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 规则层面操作：判断发动的是魔法卡且连锁可被无效
		and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
end
-- 规则层面操作：设置将要无效的连锁效果分类为CATEGORY_NEGATE
function c48229808.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置将要破坏的连锁效果目标为CATEGORY_DESTROY
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面操作：设置当前处理的连锁的操作信息，包含破坏效果的目标和数量
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 规则层面操作：执行该卡的效果处理，包括无效连锁发动和破坏对应魔法卡
function c48229808.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 规则层面操作：判断是否成功使连锁发动无效并确认目标卡是否存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面操作：将满足条件的魔法卡从游戏中破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

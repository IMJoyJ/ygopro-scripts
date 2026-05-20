--ヴァンパイアの支配
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「吸血鬼」怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。那之后，破坏的卡是怪兽卡的场合，自己回复那个原本攻击力数值的基本分。
function c68688135.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「吸血鬼」怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。那之后，破坏的卡是怪兽卡的场合，自己回复那个原本攻击力数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,68688135+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c68688135.condition)
	e1:SetTarget(c68688135.target)
	e1:SetOperation(c68688135.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「吸血鬼」怪兽
function c68688135.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8e)
end
-- 发动条件：自己场上有「吸血鬼」怪兽存在，且怪兽的效果·魔法·陷阱卡发动时，并且该发动可以被无效
function c68688135.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「吸血鬼」怪兽
	return Duel.IsExistingMatchingCard(c68688135.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查发动的效果是否为怪兽效果或魔法·陷阱卡的发动，且该发动可以被无效
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 发动准备：设置无效、破坏以及回复生命值的操作信息
function c68688135.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动的卡可被破坏且仍与效果相关，设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		if re:GetHandler():IsType(TYPE_MONSTER) then
			-- 若发动的卡是怪兽卡，设置操作信息：自己回复该怪兽原本攻击力数值的生命值
			Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,re:GetHandler():GetBaseAttack())
		end
	end
end
-- 效果处理：使发动无效并破坏，若破坏的是怪兽卡，则回复其原本攻击力数值的生命值
function c68688135.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使该发动无效，并确认该卡在连锁中仍与效果相关
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		-- 将该卡破坏，并判断被破坏的卡是否为原本攻击力大于0的怪兽卡
		and Duel.Destroy(eg,REASON_EFFECT)~=0 and re:GetHandler():IsType(TYPE_MONSTER) and re:GetHandler():GetBaseAttack()>0 then
		-- 中断当前效果处理，使后续的回复生命值处理与破坏不同时处理
		Duel.BreakEffect()
		-- 自己回复该怪兽原本攻击力数值的生命值
		Duel.Recover(tp,re:GetHandler():GetBaseAttack(),REASON_EFFECT)
	end
end

--魔鍵錠－解－
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：「魔键」仪式怪兽或者从额外卡组特殊召唤的「魔键」怪兽在自己场上存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。那之后，可以宣言1个属性。那个场合，直到回合结束时对方场上的全部表侧表示怪兽变成宣言的属性。
function c98904974.initial_effect(c)
	-- ①：「魔键」仪式怪兽或者从额外卡组特殊召唤的「魔键」怪兽在自己场上存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。那之后，可以宣言1个属性。那个场合，直到回合结束时对方场上的全部表侧表示怪兽变成宣言的属性。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,98904974+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c98904974.condition)
	e1:SetTarget(c98904974.target)
	e1:SetOperation(c98904974.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「魔键」仪式怪兽，或者从额外卡组特殊召唤的「魔键」怪兽
function c98904974.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x165) and (c:IsType(TYPE_RITUAL) or c:IsSummonLocation(LOCATION_EXTRA))
end
-- 发动条件：自己场上有满足条件的「魔键」怪兽存在，且对方发动魔法·陷阱卡时，该发动可以被无效
function c98904974.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「魔键」仪式怪兽或从额外卡组特殊召唤的「魔键」怪兽
	if not Duel.IsExistingMatchingCard(c98904974.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 检查是否为对方发动的魔法·陷阱卡的发动，且该发动可以被无效
	return ep~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 效果的目标：确认发动无效与破坏的操作信息
function c98904974.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该魔法·陷阱卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该魔法·陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 过滤条件：场上表侧表示的怪兽卡
function c98904974.attfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 效果处理：使发动无效并破坏，之后可以宣言1个属性，使对方场上所有表侧表示怪兽变成该属性
function c98904974.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使该卡的发动无效，若该卡在场则将其破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0
		-- 询问玩家是否宣言属性并改变对方场上怪兽的属性
		and Duel.SelectYesNo(tp,aux.Stringid(98904974,0)) then  --"是否改变属性？"
		-- 中断当前效果，使后续的属性改变处理与无效破坏不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要宣言的属性
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
		-- 让玩家宣言1个属性
		local attr=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
		-- 直到回合结束时对方场上的全部表侧表示怪兽变成宣言的属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetValue(attr)
		-- 注册该全局效果，使属性改变效果生效
		Duel.RegisterEffect(e1,tp)
	end
end

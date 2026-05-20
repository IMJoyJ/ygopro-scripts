--妖仙獣の秘技
-- 效果：
-- ①：自己场上有「妖仙兽」卡存在，自己的怪兽区域没有「妖仙兽」怪兽以外的表侧表示怪兽存在的场合，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c54903668.initial_effect(c)
	-- ①：自己场上有「妖仙兽」卡存在，自己的怪兽区域没有「妖仙兽」怪兽以外的表侧表示怪兽存在的场合，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c54903668.condition)
	e1:SetTarget(c54903668.target)
	e1:SetOperation(c54903668.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的「妖仙兽」卡
function c54903668.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0xb3)
end
-- 过滤条件：表侧表示且非「妖仙兽」卡
function c54903668.filter2(c)
	return c:IsFaceup() and not c:IsSetCard(0xb3)
end
-- 发动条件：检查场上卡片状态、发动效果的类型以及是否可被无效
function c54903668.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「妖仙兽」卡
	return Duel.IsExistingMatchingCard(c54903668.filter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查自己的怪兽区域是否没有「妖仙兽」以外的表侧表示怪兽
		and not Duel.IsExistingMatchingCard(c54903668.filter2,tp,LOCATION_MZONE,0,1,nil)
		-- 检查当前连锁的发动是否为怪兽效果或魔陷卡的发动，且该发动可以被无效
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 设置效果的目标：确认是否满足发动条件，并向系统宣告无效与破坏的操作信息
function c54903668.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统宣告该效果包含「使发动无效」的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动效果的卡可被破坏且与效果有关联，则向系统宣告该效果包含「破坏」的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果的处理：尝试使发动无效，若成功则将其破坏
function c54903668.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使发动无效，且发动效果的卡在处理时仍与该效果存在联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动被无效的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

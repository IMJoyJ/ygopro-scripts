--ラプターズ・ガスト
-- 效果：
-- ①：自己场上有「急袭猛禽」卡存在，魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c66994718.initial_effect(c)
	-- ①：自己场上有「急袭猛禽」卡存在，魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(c66994718.condition)
	e1:SetTarget(c66994718.target)
	e1:SetOperation(c66994718.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「急袭猛禽」卡
function c66994718.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xba)
end
-- 判断发动条件：魔法·陷阱卡发动时，且该发动可被无效，同时自己场上有「急袭猛禽」卡存在
function c66994718.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁发动的是否为魔法·陷阱卡的发动，且该发动能否被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在表侧表示的「急袭猛禽」卡
		and Duel.IsExistingMatchingCard(c66994718.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置发动时的效果分类与操作信息，若被无效的卡存在且可破坏，则将其设为破坏对象
function c66994718.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		-- 设置操作信息：将该发动被无效的卡破坏
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,re:GetHandler(),1,0,0)
	end
end
-- 效果处理：使该魔法·陷阱卡的发动无效并破坏
function c66994718.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使该连锁的发动无效，且该卡与该效果仍有联系
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该发动被无效的卡破坏
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end

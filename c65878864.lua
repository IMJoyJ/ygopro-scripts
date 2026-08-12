--使徒喰い虫
-- 效果：
-- 反转：场上2只怪兽破坏。
function c65878864.initial_effect(c)
	-- 反转：场上2只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c65878864.target)
	e1:SetOperation(c65878864.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标选择函数。由于是强制发动的反转效果，chk==0时直接返回true。若场上存在2只及以上可选择的怪兽，则选择2只怪兽作为对象，并设置破坏的操作信息。
function c65878864.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	-- 判定场上是否存在至少2只可以成为效果对象的怪兽。
	if Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil) then
		-- 提示玩家选择要破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上2只怪兽作为该效果的对象。
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
		-- 设置当前连锁的操作信息，表明将要破坏所选择的卡片组。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	end
end
-- 效果处理函数。获取之前选择的对象，若2只对象均对该效果有效，则将其全部破坏。
function c65878864.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()~=2 then return end
	-- 因效果将这些怪兽破坏。
	Duel.Destroy(g,REASON_EFFECT)
end

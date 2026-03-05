--白い忍者
-- 效果：
-- 反转：破坏场上1只守备表示的怪兽。
function c1571945.initial_effect(c)
	-- 反转：破坏场上1只守备表示的怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1571945,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c1571945.target)
	e1:SetOperation(c1571945.operation)
	c:RegisterEffect(e1)
end
-- 筛选守备表示的怪兽
function c1571945.filter(c)
	return c:IsDefensePos()
end
-- 选择1只场上守备表示的怪兽作为破坏对象
function c1571945.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1571945.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1只场上守备表示的怪兽
	local g=Duel.SelectTarget(tp,c1571945.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏选择的怪兽
function c1571945.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsDefensePos() and tc:IsRelateToEffect(e) then
		-- 将怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

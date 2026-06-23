--執念深き老魔術師
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只怪兽为对象发动。那只对方怪兽破坏。
function c45141844.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1只怪兽为对象发动。那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45141844,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c45141844.target)
	e1:SetOperation(c45141844.operation)
	c:RegisterEffect(e1)
end
-- 选择破坏对象，筛选对方场上的怪兽作为目标
function c45141844.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为破坏目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，确定破坏效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将选定的怪兽破坏
function c45141844.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果而破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

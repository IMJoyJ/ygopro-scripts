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
-- 效果发动时的取对象处理：先判断对象必须是对方场上怪兽区的卡；在可以发动的场合，让玩家选择对方场上1只怪兽作为对象，并设置将破坏该对象的操作信息。
function c45141844.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 向当前玩家显示“请选择要破坏的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上（LOCATION_MZONE）选择1只怪兽作为效果对象，同时将该怪兽登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的效果操作信息：破坏所选择的怪兽，数量为已选择对象数，供后续效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时的破坏处理：取得发动时选择的对象怪兽，若该怪兽仍与效果关联（未离场或未被无效等），则将其破坏。
function c45141844.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的那1只对象怪兽（因为只选1只，所以就是唯一的目标）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）将那只对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--雷帝ザボルグ
-- 效果：
-- ①：这张卡上级召唤成功的场合，以场上1只怪兽为对象发动。那只怪兽破坏。
function c51945556.initial_effect(c)
	-- ①：这张卡上级召唤成功的场合，以场上1只怪兽为对象发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51945556,0))  --"破坏场上1只怪兽"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c51945556.condition)
	e1:SetTarget(c51945556.target)
	e1:SetOperation(c51945556.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：判断这张卡是否是通过上级召唤成功。
function c51945556.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 发动时的目标选择处理：指定场上1只怪兽为对象，并设置破坏相关的操作信息。
function c51945556.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	-- 向玩家发出选择提示，提示内容是“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方主要怪兽区选择1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将本次连锁的操作信息设置为破坏所选择的怪兽，用于其他卡片的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理部分：取得对象怪兽，若仍与效果关联则将其破坏。
function c51945556.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果破坏该对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

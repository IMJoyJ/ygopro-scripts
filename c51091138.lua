--導爆線
-- 效果：
-- ①：以和这张卡相同纵列的1张卡为对象才能把盖放的这张卡发动。那张卡破坏。
function c51091138.initial_effect(c)
	-- ①：以和这张卡相同纵列的1张卡为对象才能把盖放的这张卡发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c51091138.condition)
	e1:SetTarget(c51091138.target)
	e1:SetOperation(c51091138.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判断：该效果只有在发动者（这张卡）位于魔陷区时才能满足发动前提，即这张卡要存在于场上作为可发动的陷阱卡。
function c51091138.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_SZONE)
end
-- 过滤函数：判断候选卡是否包含在指定纵列组中，即是否与该卡处于同一纵列。
function c51091138.filter(c,g)
	return g:IsContains(c)
end
-- 发动时的目标选择处理：获取与发动卡同一纵列的所有卡，检查场上是否存在可选对象，提示玩家选择1张同纵列的卡作为对象，并设置破坏的操作信息。
function c51091138.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cg=e:GetHandler():GetColumnGroup()
	if chkc then return chkc:IsOnField() and c51091138.filter(chkc,cg) end
	-- 在发动时点确认是否存在合法对象：检查双方场上是否存在至少1张与发动卡同纵列且可以成为效果对象的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c51091138.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,cg) end
	-- 向发动玩家显示选择提示，提示文字为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动玩家从双方场上选择1张与发动卡同纵列的卡作为效果对象，同时将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c51091138.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,cg)
	-- 设置本次连锁的操作信息为“破坏1张卡”，供后续效果处理及连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段：取得效果对象卡，若该卡仍与当前效果关联（未离场或未被重置联系），则将其破坏。
function c51091138.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第1个对象卡，即发动时所选择的同纵列卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

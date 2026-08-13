--グレイブ・スクワーマー
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合，以场上1张卡为对象发动。那张卡破坏。
function c48343627.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地的场合，以场上1张卡为对象发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48343627,0))  --"场上1张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c48343627.condition)
	e1:SetTarget(c48343627.target)
	e1:SetOperation(c48343627.operation)
	c:RegisterEffect(e1)
end
-- 检查效果发动者（此卡）是否在墓地且因战斗破坏被送去墓地，作为本诱发效果的发动条件。
function c48343627.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果发动时进行取对象处理：选择场上存在的1张卡作为对象，并设置破坏效果的操作信息。
function c48343627.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	-- 向操作者显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张卡作为效果对象（取对象），并自动将其登记为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的对象，用于供其他卡效果进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，若对象卡仍与此效果关联，则将其破坏。
function c48343627.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

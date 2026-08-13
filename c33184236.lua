--カラクリ屋敷
-- 效果：
-- 自己场上表侧表示存在的名字带有「机巧」的怪兽的表示形式变更时才能发动。选择场上存在的1张卡破坏。
function c33184236.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「机巧」的怪兽的表示形式变更时才能发动。选择场上存在的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetCondition(c33184236.condition)
	e1:SetTarget(c33184236.target)
	e1:SetOperation(c33184236.activate)
	c:RegisterEffect(e1)
end
-- 筛选符合条件的机巧怪兽：该怪兽的控制者为发动玩家tp，属于「机巧」字段，且其表示形式在攻击表示与守备表示之间发生了变更。
function c33184236.cfilter(c,tp)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return c:IsControler(tp) and c:IsSetCard(0x11) and ((pp==0x1 and np==0x4) or (pp==0x4 and np==0x1))
end
-- 检查表示形式变更事件所涉及的怪兽组eg中，是否存在至少1只满足上述筛选条件的机巧怪兽。
function c33184236.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c33184236.cfilter,1,nil,tp)
end
-- 取对象效果的目标选择处理：选择场上除本卡以外的1张卡作为破坏对象。
function c33184236.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 效果发动合法性检查：确认场上是否存在除本卡以外能够成为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向操作玩家显示选择提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张除本卡以外的卡作为效果对象，并记录为连锁对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：本次连锁处理将破坏1张卡，对象为已选择的目标组g。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时的操作：取得之前选择的对象卡，若其仍与该效果关联，则将其破坏。
function c33184236.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得连锁处理时当前效果所选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果破坏的原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

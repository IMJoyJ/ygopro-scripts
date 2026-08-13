--反魔鏡
-- 效果：
-- 对方把速攻魔法卡发动时才能发动。选择场上存在的1张卡破坏。
function c20138923.initial_effect(c)
	-- 对方把速攻魔法卡发动时才能发动。选择场上存在的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c20138923.condition)
	e1:SetTarget(c20138923.target)
	e1:SetOperation(c20138923.activate)
	c:RegisterEffect(e1)
end
-- 判断发动条件：只有对方发动速攻魔法卡（ep≠tp且连锁中的效果re类型为速攻魔法）时，本效果才满足发动条件。
function c20138923.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_QUICKPLAY)
end
-- 效果发动时的目标处理：进行对象选择前的合法性检查、显示选择提示、选择场上1张卡作为对象，并设置破坏操作信息。
function c20138923.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 发动合法性检查：确认场上存在至少1张除反魔镜自身以外的卡可以作为破坏对象。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 显示提示消息，让当前玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 由当前玩家从场上选择1张除反魔镜自身以外的卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 登记本次连锁的破坏操作信息：确定要破坏的对象为g，数量为1，用于后续时点/效果判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段：取得之前选择的对象，若该对象仍与效果关联，则将其破坏。
function c20138923.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的第1张（也是唯一一张）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以卡的效果为原因，将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

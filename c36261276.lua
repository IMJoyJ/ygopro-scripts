--亜空間物質転送装置
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只自己的表侧表示怪兽直到结束阶段除外。
function c36261276.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只自己的表侧表示怪兽直到结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36261276.target)
	e1:SetOperation(c36261276.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：对象必须是自己场上表侧表示且可以被除外的怪兽。
function c36261276.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 发动时的目标选择处理：检查对象合法性、选择1只表侧表示怪兽作为对象，并设置除外相关的操作信息。
function c36261276.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c36261276.filter(chkc) end
	-- 判定是否存在至少1只满足条件的表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c36261276.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作者显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只表侧表示且可除外的怪兽作为效果对象（同时确定取对象）。
	local g=Duel.SelectTarget(tp,c36261276.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置本次连锁的处理信息，表明将执行除外1张卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：若对象仍合法，则将其暂时除外，并注册一个结束阶段将其返回场上的效果。
function c36261276.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那张对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 验证对象仍与效果关联、仍表侧表示且仍由自己控制，然后以“效果+暂时”的理由将其除外；若除外成功则继续处理。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 那只自己的表侧表示怪兽直到结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetOperation(c36261276.retop)
		-- 将“结束阶段返回”的持续效果注册到场上，使其在该回合结束阶段触发。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段的返回处理：被暂时除外的对象怪兽返回场上。
function c36261276.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将LabelObject中记录的怪兽（之前被暂时除外的怪兽）返回场上，表示形式默认取离场前的表示形式。
	Duel.ReturnToField(e:GetLabelObject())
end

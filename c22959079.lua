--ワーム・ホール
-- 效果：
-- 选自己场上的1只怪兽，在自己的下次的准备阶段之前除外。除外的时候，被选择的怪兽的怪兽区的位置不能使用。
function c22959079.initial_effect(c)
	-- 效果发动时，将该卡作为永续效果注册到场上，具有除外怪兽和在准备阶段返回的特性
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c22959079.target)
	e1:SetOperation(c22959079.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，判断目标怪兽是否可以被除外
function c22959079.filter(c)
	return c:IsAbleToRemove()
end
-- 效果处理时，选择自己场上一只可以被除外的怪兽作为对象
function c22959079.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c22959079.filter(chkc) end
	-- 判断是否满足发动条件，即自己场上是否存在可以被除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(c22959079.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一只可以被除外的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c22959079.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，说明将要除外一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理函数，执行除外操作并注册后续返回和区域封锁效果
function c22959079.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 将对象怪兽的位置转换为全局位掩码，用于区域封锁效果
	local val=aux.SequenceToGlobal(tc:GetControler(),LOCATION_MZONE,tc:GetSequence())
	-- 判断对象怪兽是否仍然在场且成功除外，若成功则注册后续处理效果
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 注册一个在准备阶段触发的返回效果，用于将除外的怪兽送回场上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY,2)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c22959079.rtcon)
		e1:SetOperation(c22959079.retop)
		-- 将准备阶段返回效果注册到场上
		Duel.RegisterEffect(e1,tp)
		-- 注册一个无效区域效果，使被除外怪兽所在区域在准备阶段无法使用
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_DISABLE_FIELD)
		e2:SetLabelObject(tc)
		e2:SetCondition(c22959079.discon)
		e2:SetValue(val)
		-- 将区域封锁效果注册到场上
		Duel.RegisterEffect(e2,tp)
	end
end
-- 准备阶段返回效果的触发条件函数
function c22959079.rtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家，决定是否触发返回效果
	return tp==Duel.GetTurnPlayer()
end
-- 准备阶段返回效果的执行函数
function c22959079.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对象怪兽返回到原位置
	Duel.ReturnToField(e:GetLabelObject())
end
-- 区域封锁效果的触发条件函数，判断对象怪兽是否仍在除外区
function c22959079.discon(e,c)
	if e:GetLabelObject():IsLocation(LOCATION_REMOVED) then
		return true
	else
		e:Reset()
		return false
	end
end

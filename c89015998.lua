--異次元の探求者
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽直到下个回合的结束阶段除外。这个效果在对方回合也能发动。
function c89015998.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽直到下个回合的结束阶段除外。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,89015998)
	e1:SetTarget(c89015998.rmtg)
	e1:SetOperation(c89015998.rmop)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示且可以除外的怪兽
function c89015998.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果①的发动准备与目标选择
function c89015998.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c89015998.rmfilter(chkc) end
	-- 检查自己场上是否存在可以作为除外对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c89015998.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c89015998.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息为除外该目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的效果处理，将对象怪兽暂时除外并注册在下个回合结束阶段返回场上的效果
function c89015998.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用此效果，则将其以效果原因暂时除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		tc:RegisterFlagEffect(89015998,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		-- 那只怪兽直到下个回合的结束阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c89015998.retcon)
		e1:SetOperation(c89015998.retop)
		-- 将当前回合数记录在效果的Label中，用于后续判断是否到了下个回合
		e1:SetLabel(Duel.GetTurnCount())
		-- 在全局环境注册该延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否到了下个回合的结束阶段，且该怪兽仍带有对应的标记
function c89015998.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 确认当前回合数不等于除外时的回合数（即至少到了下个回合），且怪兽的标记依然存在
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(89015998)~=0
end
-- 延迟效果处理，将暂时除外的怪兽返回场上
function c89015998.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的怪兽返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end

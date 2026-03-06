--霊子もつれ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽直到结束阶段除外。
function c28234578.initial_effect(c)
	-- 创建效果对象，设置为发动时点效果，具有取对象属性，发动次数限制为1次
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,28234578+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c28234578.target)
	e1:SetOperation(c28234578.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断目标怪兽是否为表侧表示且能被除外
function c28234578.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果处理函数：选择对方场上一只表侧表示怪兽作为对象
function c28234578.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c28234578.filter(chkc) end
	-- 检查阶段：确认对方场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c28234578.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一只对方场上的表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c28234578.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将选择的怪兽设为除外对象
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 发动效果函数：将目标怪兽除外并设置结束阶段返回效果
function c28234578.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽有效且成功除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 创建结束阶段返回效果，用于在结束阶段将怪兽送回场上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetOperation(c28234578.retop)
		-- 将结束阶段返回效果注册到玩家全局环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 返回效果处理函数：将指定怪兽返回场上
function c28234578.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将指定怪兽以原表示形式返回场上
	Duel.ReturnToField(e:GetLabelObject())
end

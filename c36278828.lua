--ヴェノム・サーペント
-- 效果：
-- 1回合只有1次，可以给对方场上1只怪兽放置1个毒指示物。
function c36278828.initial_effect(c)
	-- 1回合只有1次，可以给对方场上1只怪兽放置1个毒指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36278828,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c36278828.target)
	e1:SetOperation(c36278828.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的对方场上怪兽
function c36278828.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsCanAddCounter(0x1009,1) end
	-- 检查是否存在满足条件的对方场上怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1009,1) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的对方场上怪兽作为目标
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1009,1)
	-- 设置连锁操作信息为放置指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 处理效果的发动
function c36278828.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsCanAddCounter(0x1009,1) then
		local atk=tc:GetAttack()
		tc:AddCounter(0x1009,1)
		if atk>0 and tc:IsAttack(0) then
			-- 触发自定义时点事件
			Duel.RaiseEvent(tc,EVENT_CUSTOM+54306223,e,0,0,0,0)
		end
	end
end

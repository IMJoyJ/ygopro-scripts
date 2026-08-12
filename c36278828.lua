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
c36278828.mentioned_counter={
	[0x1009]=true,
}
-- 效果的对象选择函数：检查连锁对象是否合法、判断效果能否发动、选择对方场上1只可放置毒指示物的怪兽作为对象并设置操作信息。
function c36278828.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsCanAddCounter(0x1009,1) end
	-- 发动条件检查：对方主要怪兽区是否存在至少1只可以放置1个毒指示物（0x1009）且能成为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1009,1) end
	-- 向发动玩家发送选择提示信息「请选择表侧表示的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动玩家选择对方场上1只可以放置1个毒指示物的怪兽作为本效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1009,1)
	-- 设置当前连锁的操作信息为指示物效果（CATEGORY_COUNTER），确定要处理1个指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 效果处理函数：取得对象怪兽，若其仍与本效果关联且可以放置毒指示物，则记录其当前攻击力并放置1个毒指示物；若放置后攻击力由正数变为0，则触发相应的自定义事件。
function c36278828.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第1个对象卡（即被选择的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsCanAddCounter(0x1009,1) then
		local atk=tc:GetAttack()
		tc:AddCounter(0x1009,1)
		if atk>0 and tc:IsAttack(0) then
			-- 以该怪兽触发自定义事件EVENT_CUSTOM+54306223（用于该怪兽因毒指示物攻击力变为0的联动诱发时点）。
			Duel.RaiseEvent(tc,EVENT_CUSTOM+54306223,e,0,0,0,0)
		end
	end
end

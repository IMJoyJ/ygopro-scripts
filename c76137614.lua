--聖なる解呪師
-- 效果：
-- ①：1回合1次，以场上1张表侧表示的魔法卡为对象才能发动。场上1个魔力指示物取除，作为对象的表侧表示的卡回到持有者手卡。
function c76137614.initial_effect(c)
	-- ①：1回合1次，以场上1张表侧表示的魔法卡为对象才能发动。场上1个魔力指示物去除，作为对象的表侧表示的卡回到持有者手牌。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76137614,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c76137614.thtg)
	e1:SetOperation(c76137614.thop)
	c:RegisterEffect(e1)
end
c76137614.mentioned_counter={
	[0x1]=true,
}
-- 目标卡过滤条件：场上表侧表示且可加入手牌的魔法卡
function c76137614.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsFaceup() and c:IsAbleToHand()
end
-- ①效果发动准备：检查去除指示物条件并选择场上表侧魔法卡为对象
function c76137614.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c76137614.filter(chkc) end
	-- 发动条件检查：场上能否去除1个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1,1,REASON_EFFECT)
		-- 发动条件检查：场上是否存在可返回手牌的表侧魔法卡
		and Duel.IsExistingTarget(c76137614.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张表侧魔法卡作为对象
	local g=Duel.SelectTarget(tp,c76137614.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：将对象卡返回手牌1张
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：去除1个魔力指示物，并将对象卡返回手牌
function c76137614.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否仍能去除1个魔力指示物
	if Duel.IsCanRemoveCounter(tp,1,1,0x1,1,REASON_EFFECT) then
		-- 去除场上1个魔力指示物
		Duel.RemoveCounter(tp,1,1,0x1,1,REASON_EFFECT)
		-- 获取连锁中的对象卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将对象卡返回持有者手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end

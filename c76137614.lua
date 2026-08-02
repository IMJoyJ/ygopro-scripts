--聖なる解呪師
-- 效果：
-- ①：1回合1次，以场上1张表侧表示的魔法卡为对象才能发动。场上1个魔力指示物取除，作为对象的表侧表示的卡回到持有者手卡。
function c76137614.initial_effect(c)
	-- ①：1回合1次，以场上1张表侧表示的魔法卡为对象才能发动。场上1个魔力指示物取除，作为对象的表侧表示的卡回到持有者手卡。
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
-- 过滤条件：场上表侧表示且可以回到手卡的魔法卡
function c76137614.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsFaceup() and c:IsAbleToHand()
end
-- 若是对象选择操作则判断对象卡是否满足条件；若是效果发动条件判定：
function c76137614.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c76137614.filter(chkc) end
	-- 判断场上是否有可以取除的1个魔力指示物，且
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1,1,REASON_EFFECT)
		-- 存在满足条件的可以回到手卡的魔法卡
		and Duel.IsExistingTarget(c76137614.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择1张满足条件的魔法卡作为对象
	local g=Duel.SelectTarget(tp,c76137614.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：包含回手牌操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的操作：取除指示物并让对象卡回到手卡
function c76137614.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否可以取除1个魔力指示物
	if Duel.IsCanRemoveCounter(tp,1,1,0x1,1,REASON_EFFECT) then
		-- 从场上取除1个魔力指示物
		Duel.RemoveCounter(tp,1,1,0x1,1,REASON_EFFECT)
		-- 获取被选择的对象卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将该卡送回持有者手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end

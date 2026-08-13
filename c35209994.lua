--ヴェルズ・フレイス
-- 效果：
-- 反转：选择对方场上表侧表示存在的1张卡回到持有者手卡。
function c35209994.initial_effect(c)
	-- 反转：选择对方场上表侧表示存在的1张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35209994,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c35209994.target)
	e1:SetOperation(c35209994.operation)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：选择的对象必须是表侧表示且可以被加入手卡的卡。
function c35209994.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 发动时的目标选择处理：确认对象条件，选择对方场上1张表侧表示且能回手牌的卡，并设置回手牌的操作信息。
function c35209994.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c35209994.filter(chkc) end
	if chk==0 then return true end
	-- 弹出选择提示，提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从对方场上选择1张符合条件的卡作为效果对象，并自动记录为连锁对象。
	local g=Duel.SelectTarget(tp,c35209994.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息：效果分类为回手牌，处理对象为已选择的卡，数量为选择数。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理时的操作：若对象仍表侧表示且与效果关联，则将其送回持有者手卡。
function c35209994.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将该卡以效果原因送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

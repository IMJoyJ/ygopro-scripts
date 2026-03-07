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
-- 过滤函数：选择表侧表示且可以送入手卡的卡片
function c35209994.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果目标函数：选择对方场上表侧表示的1张可送入手卡的卡
function c35209994.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c35209994.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示选择要送入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的目标卡片组
	local g=Duel.SelectTarget(tp,c35209994.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息为送入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理函数：将选中的卡片送入持有者手卡
function c35209994.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因送入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

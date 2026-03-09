--ガジェット・アームズ
-- 效果：
-- 反转：选择自己墓地存在的1张名字带有「变形斗士」的魔法或者陷阱卡加入手卡。
function c47985614.initial_effect(c)
	-- 反转效果：选择自己墓地存在的1张名字带有「变形斗士」的魔法或者陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47985614,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c47985614.target)
	e1:SetOperation(c47985614.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检索满足条件的卡片组，条件为名字带有「变形斗士」且为魔法或陷阱卡且可以送去手卡。
function c47985614.filter(c)
	return c:IsSetCard(0x26) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果处理时点：设置选择目标，筛选自己墓地符合条件的卡作为目标。
function c47985614.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47985614.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张满足条件的卡作为目标。
	local g=Duel.SelectTarget(tp,c47985614.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为回手牌效果，并指定目标卡组及数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：将选定的卡加入手牌并确认对方可见。
function c47985614.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因送去手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认该张卡的发动
		Duel.ConfirmCards(1-tp,tc)
	end
end

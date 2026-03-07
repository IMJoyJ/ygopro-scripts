--剣現する武神
-- 效果：
-- 可以从以下效果选择1个发动。
-- ●选择自己墓地1只名字带有「武神」的怪兽加入手卡。
-- ●选择从游戏中除外的1只自己的名字带有「武神」的怪兽回到墓地。
function c30338466.initial_effect(c)
	-- 效果原文：选择自己墓地1只名字带有「武神」的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30338466,0))  --"墓地回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c30338466.target)
	e1:SetOperation(c30338466.activate)
	c:RegisterEffect(e1)
	-- 效果原文：选择从游戏中除外的1只自己的名字带有「武神」的怪兽回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30338466,1))  --"除外回到墓地"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(c30338466.target2)
	e2:SetOperation(c30338466.activate2)
	c:RegisterEffect(e2)
end
-- 检索满足条件的墓地怪兽（名字带武神且可加入手牌）
function c30338466.filter(c)
	return c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标为满足条件的墓地怪兽
function c30338466.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c30338466.filter(chkc) end
	-- 判断是否满足发动条件（存在满足条件的墓地怪兽）
	if chk==0 then return Duel.IsExistingTarget(c30338466.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c30338466.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息为将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果发动，将目标怪兽加入手牌并确认
function c30338466.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认手牌中的目标怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 检索满足条件的除外怪兽（名字带武神且表侧表示）
function c30338466.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and c:IsType(TYPE_MONSTER)
end
-- 设置效果目标为满足条件的除外怪兽
function c30338466.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c30338466.filter2(chkc) end
	-- 判断是否满足发动条件（存在满足条件的除外怪兽）
	if chk==0 then return Duel.IsExistingTarget(c30338466.filter2,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的除外怪兽作为目标
	Duel.SelectTarget(tp,c30338466.filter2,tp,LOCATION_REMOVED,0,1,1,nil)
end
-- 处理效果发动，将目标怪兽送回墓地
function c30338466.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送回墓地并标记为返回和效果原因
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end

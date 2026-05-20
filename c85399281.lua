--智天使ハーヴェスト
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时，以自己墓地1张反击陷阱卡为对象才能发动。那张卡加入手卡。
function c85399281.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时，以自己墓地1张反击陷阱卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85399281,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c85399281.condition)
	e1:SetTarget(c85399281.target)
	e1:SetOperation(c85399281.operation)
	c:RegisterEffect(e1)
end
-- 判定发动条件：这张卡因战斗破坏被送去墓地
function c85399281.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：墓地中的反击陷阱卡且能加入手牌
function c85399281.filter(c)
	return c:IsType(TYPE_COUNTER) and c:IsAbleToHand()
end
-- 效果发动时的对象选择与操作信息设置
function c85399281.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c85399281.filter(chkc) end
	-- 检查自己墓地是否存在符合条件的可选择对象
	if chk==0 then return Duel.IsExistingTarget(c85399281.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张反击陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c85399281.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将作为对象的卡加入手牌并给对方确认
function c85399281.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片通过效果加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end

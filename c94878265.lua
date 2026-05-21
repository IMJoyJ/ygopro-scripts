--モジャ
-- 效果：
-- 这张卡被战斗破坏并送去墓地时，可以把自己墓地存在的1只4星的兽族怪兽加入手卡。
function c94878265.initial_effect(c)
	-- 这张卡被战斗破坏并送去墓地时，可以把自己墓地存在的1只4星的兽族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94878265,0))  --"返回手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c94878265.condition)
	e1:SetTarget(c94878265.target)
	e1:SetOperation(c94878265.operation)
	c:RegisterEffect(e1)
end
-- 判定发动条件：自身因战斗破坏并送去墓地
function c94878265.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：等级4的兽族且能加入手牌的怪兽
function c94878265.filter(c)
	return c:IsLevel(4) and c:IsRace(RACE_BEAST) and c:IsAbleToHand()
end
-- 效果发动时的目标选择：选择自己墓地1只符合条件的怪兽作为对象，并设置操作信息
function c94878265.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c94878265.filter(chkc) end
	-- 在发动阶段，检查自己墓地是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c94878265.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c94878265.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示该效果的处理为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：将选中的对象怪兽加入手牌并给对方确认
function c94878265.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_BEAST) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end

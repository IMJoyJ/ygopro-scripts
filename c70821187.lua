--再生ミイラ
-- 效果：
-- 对方控制的卡的效果把这张卡从手卡送去墓地时，这张卡回到手卡。
function c70821187.initial_effect(c)
	-- 对方控制的卡的效果把这张卡从手卡送去墓地时，这张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70821187,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c70821187.condition)
	e1:SetTarget(c70821187.target)
	e1:SetOperation(c70821187.operation)
	c:RegisterEffect(e1)
end
-- 检查触发条件：这张卡原本在手牌，且是因为对方卡片的效果被送去墓地
function c70821187.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and rp==1-tp and bit.band(r,REASON_EFFECT)==REASON_EFFECT
end
-- 效果发动时的目标确认：检查自身是否仍与效果有联系，并设置回手牌的操作信息
function c70821187.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	-- 设置操作信息：将1张自身卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身送回手牌并给对方确认
function c70821187.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自身仍与效果有联系，则因效果原因将自身送回持有者手牌，并确认是否成功送回
	if e:GetHandler():IsRelateToEffect(e) and Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)==1 then
		-- 给对方玩家确认送回手牌的这张卡
		Duel.ConfirmCards(1-tp,e:GetHandler())
	end
end

--神竜 アポカリプス
-- 效果：
-- 1回合1次，丢弃1张手卡才能发动。选择自己墓地1只龙族怪兽加入手卡。
function c20277376.initial_effect(c)
	-- 效果原文内容：1回合1次，丢弃1张手卡才能发动。选择自己墓地1只龙族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20277376,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c20277376.thcost)
	e1:SetTarget(c20277376.thtg)
	e1:SetOperation(c20277376.thop)
	c:RegisterEffect(e1)
end
-- 规则层面操作：检查是否满足丢弃手卡的条件并执行丢弃操作
function c20277376.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 规则层面操作：执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 规则层面操作：定义过滤函数，用于筛选龙族且能加入手卡的墓地怪兽
function c20277376.filter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 规则层面操作：设置效果的目标选择逻辑，包括目标位置、条件和选择数量
function c20277376.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20277376.filter(chkc) end
	-- 规则层面操作：判断是否满足选择墓地龙族怪兽的条件
	if chk==0 then return Duel.IsExistingTarget(c20277376.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 规则层面操作：向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面操作：选择满足条件的墓地龙族怪兽作为效果目标
	local g=Duel.SelectTarget(tp,c20277376.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 规则层面操作：设置效果处理时的操作信息，包括效果分类和目标数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 规则层面操作：定义效果发动后的处理逻辑，包括将目标怪兽加入手牌并确认其存在
function c20277376.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 规则层面操作：将目标怪兽以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 规则层面操作：向对方确认目标怪兽的存在
		Duel.ConfirmCards(1-tp,tc)
	end
end

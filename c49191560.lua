--魔導剣士 シャリオ
-- 效果：
-- 1回合1次，从手卡丢弃1张名字带有「魔导书」的魔法卡才能发动。选择自己墓地1只魔法师族怪兽加入手卡。
function c49191560.initial_effect(c)
	-- 效果原文内容：1回合1次，从手卡丢弃1张名字带有「魔导书」的魔法卡才能发动。选择自己墓地1只魔法师族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49191560,0))  --"加入手牌"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c49191560.cost)
	e1:SetTarget(c49191560.target)
	e1:SetOperation(c49191560.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：名字带有「魔导书」的魔法卡
function c49191560.cfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 规则层面操作：检查玩家手牌是否存在满足条件的魔法卡并丢弃1张
function c49191560.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断是否满足丢弃条件
	if chk==0 then return Duel.IsExistingMatchingCard(c49191560.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面操作：执行丢弃1张满足条件的手卡
	Duel.DiscardHand(tp,c49191560.cfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 检索满足条件的卡片组：魔法师族且能加入手牌的怪兽
function c49191560.filter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 规则层面操作：设置效果目标，选择自己墓地1只魔法师族怪兽
function c49191560.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c49191560.filter(chkc) end
	-- 规则层面操作：判断是否满足选择目标条件
	if chk==0 then return Duel.IsExistingTarget(c49191560.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 规则层面操作：向玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面操作：选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,c49191560.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 规则层面操作：设置效果处理信息，确定将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 规则层面操作：执行效果处理，将目标怪兽加入手牌并确认对方可见
function c49191560.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_SPELLCASTER) then
		-- 规则层面操作：将目标怪兽以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 规则层面操作：向对方玩家确认目标怪兽的卡面
		Duel.ConfirmCards(1-tp,tc)
	end
end

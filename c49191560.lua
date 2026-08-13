--魔導剣士 シャリオ
-- 效果：
-- 1回合1次，从手卡丢弃1张名字带有「魔导书」的魔法卡才能发动。选择自己墓地1只魔法师族怪兽加入手卡。
function c49191560.initial_effect(c)
	-- 1回合1次，从手卡丢弃1张名字带有「魔导书」的魔法卡才能发动。选择自己墓地1只魔法师族怪兽加入手卡。
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
-- 过滤手卡中满足条件的卡片：卡名带有「魔导书」的魔法卡且能够被丢弃。
function c49191560.cfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 代价函数：检查能否丢弃手卡中的「魔导书」魔法卡作为发动代价；满足时实际丢弃1张符合条件的卡。
function c49191560.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：若此时不是正式支付代价（chk==0），则检查手卡中是否存在至少1张符合条件的「魔导书」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c49191560.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从手卡挑选并丢弃1张符合条件的「魔导书」魔法卡，丢弃原因为效果代价。
	Duel.DiscardHand(tp,c49191560.cfilter,1,1,REASON_DISCARD+REASON_COST)
end
-- 过滤墓地中的目标：魔法师族怪兽且能够加入手卡。
function c49191560.filter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 发动目标函数：选择自己墓地1只魔法师族怪兽作为对象，并设置将对象加入手牌的操作信息。
function c49191560.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c49191560.filter(chkc) end
	-- 发动合法性检测：自己墓地是否存在至少1只满足条件且能成为对象的魔法师族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c49191560.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发出选择提示：让玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己墓地选择1只满足条件的魔法师族怪兽，并将其设为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c49191560.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次处理将把1张对象卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：效果结算时，若对象仍然与效果有关联且仍为魔法师族怪兽，则将其加入手牌并向对方展示。
function c49191560.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得连锁处理时的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_SPELLCASTER) then
		-- 将对象卡加入其持有者的手牌，原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end

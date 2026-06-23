--聖騎士ジャンヌ
-- 效果：
-- ①：这张卡攻击的伤害步骤内，这张卡的攻击力下降300。
-- ②：这张卡被对方破坏送去墓地的场合，把1张手卡送去墓地，以自己墓地1只4星以下的战士族怪兽为对象才能发动。那只战士族怪兽加入手卡。
function c18426196.initial_effect(c)
	-- ①：这张卡攻击的伤害步骤内，这张卡的攻击力下降300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c18426196.condtion)
	e1:SetValue(-300)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏送去墓地的场合，把1张手卡送去墓地，以自己墓地1只4星以下的战士族怪兽为对象才能发动。那只战士族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18426196,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	-- 效果触发条件为：该卡被对方破坏送去墓地
	e1:SetCondition(aux.dogcon)
	e1:SetCost(c18426196.thcost)
	e1:SetTarget(c18426196.thtg)
	e1:SetOperation(c18426196.thop)
	c:RegisterEffect(e1)
end
-- 效果触发条件为：该卡在伤害步骤中进行攻击
function c18426196.condtion(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		-- 判断攻击怪兽是否为该卡
		and Duel.GetAttacker()==e:GetHandler()
end
-- 支付效果代价：丢弃1张手卡
function c18426196.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手卡操作
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 筛选墓地中的4星以下战士族怪兽
function c18426196.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 设置效果目标：选择1只满足条件的墓地怪兽
function c18426196.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c18426196.filter(chkc) end
	-- 检测是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c18426196.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c18426196.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理函数：将目标怪兽加入手牌并确认
function c18426196.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_WARRIOR) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end

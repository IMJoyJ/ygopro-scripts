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
	-- 设置②效果的发动条件：这张卡必须是从自己场上被对方破坏并送去墓地时才满足发动条件。
	e1:SetCondition(aux.dogcon)
	e1:SetCost(c18426196.thcost)
	e1:SetTarget(c18426196.thtg)
	e1:SetOperation(c18426196.thop)
	c:RegisterEffect(e1)
end
-- 定义①效果（攻击力增减）的适用条件：仅在伤害步骤或伤害计算时，且这张卡是正在攻击的怪兽时，才适用攻击力下降300。
function c18426196.condtion(e)
	-- 获取当前所处的阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		-- 并判定当前进行攻击的怪兽是否为效果持有者自身（即这张卡正在攻击）。
		and Duel.GetAttacker()==e:GetHandler()
end
-- 定义②效果的发动代价：从手卡把1张卡送去墓地作为代价才能发动。
function c18426196.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在1张可以送去墓地的手卡，用于支付②的发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从手牌选择1张卡丢弃到墓地。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 定义②效果的对象筛选条件：自己墓地中等级4以下、战士族、且可以加入手卡的怪兽。
function c18426196.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 定义②效果发动时的目标选择和操作信息设置：必须选择自己墓地1只符合条件的战士族怪兽为对象。
function c18426196.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c18426196.filter(chkc) end
	-- 发动时检查自己墓地是否存在至少1只满足条件的战士族怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c18426196.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示信息：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合条件的战士族怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c18426196.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁的操作信息：将选中的对象卡加入手牌，用于相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 定义②效果的实际处理：把对象怪兽加入手牌，并向对方展示那张卡。
function c18426196.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象卡（那只战士族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_WARRIOR) then
		-- 将那只战士族怪兽加入其持有者的手牌，处理原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认被加入手牌的那张卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end

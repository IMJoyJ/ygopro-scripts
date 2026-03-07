--不知火の武士
-- 效果：
-- 「不知火的武士」的①②的效果1回合各能使用1次。
-- ①：把自己墓地1只不死族怪兽除外才能发动。这张卡的攻击力直到回合结束时上升600，这个回合这张卡和怪兽进行战斗的场合，那只怪兽在伤害计算后除外。这个效果在对方回合也能发动。
-- ②：这张卡被除外的场合，以「不知火的武士」以外的自己墓地1只「不知火」怪兽为对象才能发动。那只怪兽加入手卡。
function c35818851.initial_effect(c)
	-- ①：把自己墓地1只不死族怪兽除外才能发动。这张卡的攻击力直到回合结束时上升600，这个回合这张卡和怪兽进行战斗的场合，那只怪兽在伤害计算后除外。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35818851,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,35818851)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c35818851.cost)
	e1:SetOperation(c35818851.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以「不知火的武士」以外的自己墓地1只「不知火」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35818851,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,35818852)
	e2:SetTarget(c35818851.thtg)
	e2:SetOperation(c35818851.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地中的不死族怪兽是否可以作为除外的代价
function c35818851.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的费用支付处理，需要从墓地选择一只不死族怪兽除外
function c35818851.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即墓地是否存在符合条件的不死族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35818851.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择符合条件的不死族怪兽并将其除外
	local g=Duel.SelectMatchingCard(tp,c35818851.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡从游戏中除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动后的处理，提升自身攻击力并设置战斗时的除外效果
function c35818851.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使自身攻击力上升600点
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 设置战斗时除外对方怪兽的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_BATTLED)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetOperation(c35818851.rmop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 战斗时的处理函数，用于将对方怪兽除外
function c35818851.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc then
		-- 将对方怪兽从游戏中除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤函数，用于选择墓地中符合条件的「不知火」怪兽
function c35818851.filter(c)
	return c:IsSetCard(0xd9) and c:IsType(TYPE_MONSTER) and not c:IsCode(35818851) and c:IsAbleToHand()
end
-- 发动效果时选择目标怪兽，将其加入手牌
function c35818851.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c35818851.filter(chkc) end
	-- 检查是否满足发动条件，即墓地是否存在符合条件的「不知火」怪兽
	if chk==0 then return Duel.IsExistingTarget(c35818851.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择符合条件的「不知火」怪兽
	local g=Duel.SelectTarget(tp,c35818851.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，表明将要将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果发动后的处理，将选中的怪兽加入手牌
function c35818851.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

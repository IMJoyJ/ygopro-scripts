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
	-- 设置①效果的发动条件为伤害步骤限制，即仅在伤害计算前或非伤害步骤才能发动，允许在对方回合发动。
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
-- ①效果的费用筛选：判断怪兽是否满足不死族且可作为代价除外。
function c35818851.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- ①效果的代价处理：从自己墓地选择1只不死族怪兽除外（发动代价），若不存在可选卡则不能发动。
function c35818851.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost的合法性检查：确认自己墓地存在至少1只满足过滤条件的不死族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c35818851.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示选择提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地的怪兽中选择1只满足过滤条件的不死族怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c35818851.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的不死族怪兽以表侧表示除外，作为效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的处理：本回合这张卡的攻击力上升600，并为其设置“与怪兽战斗的场合，该怪兽在伤害计算后除外”的效果。
function c35818851.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升600
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 这个回合这张卡和怪兽进行战斗的场合，那只怪兽在伤害计算后除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_BATTLED)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetOperation(c35818851.rmop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- ①效果的追加效果处理：伤害计算后，将这张卡进行过战斗的那只怪兽除外。
function c35818851.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc then
		-- 将战斗对象怪兽以表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的对象的筛选条件：我方墓地的「不知火」怪兽，卡名不是「不知火的武士」，且可以被加入手卡。
function c35818851.filter(c)
	return c:IsSetCard(0xd9) and c:IsType(TYPE_MONSTER) and not c:IsCode(35818851) and c:IsAbleToHand()
end
-- ②效果的发动与取对象：以自己墓地1只「不知火」怪兽（不含「不知火的武士」）为对象，并设置加入手卡的处理信息。
function c35818851.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c35818851.filter(chkc) end
	-- 合法性检查：确认自己墓地存在至少1只满足条件且能被作为对象的「不知火」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c35818851.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己墓地选择1只符合条件的「不知火」怪兽，将其设为效果对象。
	local g=Duel.SelectTarget(tp,c35818851.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次效果处理将1张对象卡加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理：将对象怪兽加入持有者手卡。
function c35818851.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回本次效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入持有者手卡（回手牌）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

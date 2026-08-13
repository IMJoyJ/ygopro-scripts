--サブテラーマリスの潜伏
-- 效果：
-- ①：从自己墓地把1只「地中族」怪兽除外才能发动。直到回合结束时，自己场上的里侧表示怪兽不会被效果破坏，不会成为对方的效果的对象。
-- ②：场上的这张卡被效果破坏的场合才能发动。从卡组把1只「地中族」怪兽加入手卡。
-- ③：把墓地的这张卡除外，以自己场上1只「地中族」怪兽为对象才能发动。那只怪兽变成里侧守备表示。
function c28369508.initial_effect(c)
	-- ①：从自己墓地把1只「地中族」怪兽除外才能发动。直到回合结束时，自己场上的里侧表示怪兽不会被效果破坏，不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c28369508.cost)
	e1:SetOperation(c28369508.activate)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被效果破坏的场合才能发动。从卡组把1只「地中族」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c28369508.thcon)
	e2:SetTarget(c28369508.thtg)
	e2:SetOperation(c28369508.thop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外，以自己场上1只「地中族」怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28369508,0))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_BATTLE_PHASE)
	-- 设置③效果的发动代价：把墓地的这张卡除外（aux.bfgcost为除外自身作代价的通用函数）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c28369508.postg)
	e3:SetOperation(c28369508.posop)
	c:RegisterEffect(e3)
end
-- 筛选可作为①发动代价的卡：自己墓地的「地中族」怪兽且满足可被除外的条件（IsAbleToRemoveAsCost）。
function c28369508.cfilter(c)
	return c:IsSetCard(0xed) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ①效果的发动代价：从自己墓地选择1只符合条件的「地中族」怪兽除外。
function c28369508.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己墓地存在至少1只满足cfilter的「地中族」怪兽，以判断能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c28369508.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出“请选择要除外的卡”的提示信息，引导玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1张符合条件的「地中族」怪兽（作为发动代价）。
	local g=Duel.SelectMatchingCard(tp,c28369508.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的「地中族」怪兽以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果处理：给自己场上的里侧表示怪兽赋予“不会被效果破坏”和“不会成为对方效果对象”的持续效果，直到回合结束。
function c28369508.activate(e,tp,eg,ep,ev,re,r,rp)
	-- ①从自己墓地把1只「地中族」怪兽除外才能发动。直到回合结束时，自己场上的里侧表示怪兽不会被效果破坏，不会成为对方的效果的对象。②场上的这张卡被效果破坏的场合才能发动。从卡组把1只「地中族」怪兽加入手卡。③把墓地的这张卡除外，以自己场上1只「地中族」怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(c28369508.tgfilter)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不会被效果破坏”的持续效果注册到当前玩家方的场上，作用于符合条件的己方里侧表示怪兽。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置“不会成为对方效果对象”的判定函数，使对方发动的效果不能以己方里侧怪兽为对象。
	e2:SetValue(aux.tgoval)
	-- 将“不会成为对方效果对象”的持续效果注册到当前玩家方的场上。
	Duel.RegisterEffect(e2,tp)
end
-- ①抗性效果的适用对象过滤：己方场上里侧表示且在怪兽区域的怪兽。
function c28369508.tgfilter(e,c)
	return c:IsFacedown() and c:IsLocation(LOCATION_MZONE)
end
-- ②效果的发动条件：这张卡因效果被破坏，且被破坏前位于场上。
function c28369508.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②检索卡片的筛选条件：卡组中的「地中族」怪兽且能够加入手卡。
function c28369508.thfilter(c)
	return c:IsSetCard(0xed) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动时点检查：确认卡组存在符合条件的「地中族」怪兽，并设置检索加入手卡的操作信息。
function c28369508.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查：确认卡组中存在至少1张满足thfilter的「地中族」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28369508.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将本次处理登记为从卡组把1张卡加入手卡（CATEGORY_TOHAND+CATEGORY_SEARCH）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只「地中族」怪兽加入手卡，并展示给对方确认。
function c28369508.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「地中族」怪兽。
	local g=Duel.SelectMatchingCard(tp,c28369508.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果对象的筛选条件：己方场上表侧表示的「地中族」怪兽且可以变更为里侧守备表示。
function c28369508.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xed) and c:IsCanTurnSet()
end
-- ③效果的目标处理：选择己方场上1只符合条件的「地中族」怪兽为对象，并登记变更表示形式的操作信息。
function c28369508.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c28369508.filter(chkc) end
	-- 目标检查：确认己方场上存在至少1只符合条件的「地中族」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c28369508.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出“请选择要改变表示形式的怪兽”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择己方场上1只符合条件的「地中族」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c28369508.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：将指定的对象怪兽登记为改变表示形式（CATEGORY_POSITION）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ③效果处理：将对象怪兽变成里侧守备表示（若对象仍表侧且与效果关联）。
function c28369508.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式变为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end

--呪眼の死徒 メドゥサ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时，以「咒眼之死徒 美杜莎」以外的自己墓地1张「咒眼」卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡有「太阴之咒眼」装备的场合，以对方墓地1只怪兽为对象才能发动。那只怪兽除外。这个效果在对方回合也能发动。
-- ③：这张卡的②的效果发动的场合，下次的准备阶段发动。选自己墓地1张卡除外。
function c18551923.initial_effect(c)
	-- ①：这张卡召唤成功时，以「咒眼之死徒 美杜莎」以外的自己墓地1张「咒眼」卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18551923,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c18551923.target)
	e1:SetOperation(c18551923.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡有「太阴之咒眼」装备的场合，以对方墓地1只怪兽为对象才能发动。那只怪兽除外。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18551923,1))  --"对方墓地1只怪兽除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,18551923)
	e2:SetCost(c18551923.rmcost1)
	e2:SetCondition(c18551923.rmcon1)
	e2:SetTarget(c18551923.rmtg1)
	e2:SetOperation(c18551923.rmop1)
	c:RegisterEffect(e2)
	-- ③：这张卡的②的效果发动的场合，下次的准备阶段发动。选自己墓地1张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18551923,2))  --"自己墓地1张卡除外"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c18551923.rmcon2)
	e3:SetTarget(c18551923.rmtg2)
	e3:SetOperation(c18551923.rmop2)
	c:RegisterEffect(e3)
end
-- 筛选函数：判断卡是否为「咒眼」字段卡、不是这张卡本身（卡号18551923）、且能够加入手卡。
function c18551923.filter(c)
	return c:IsSetCard(0x129) and not c:IsCode(18551923) and c:IsAbleToHand()
end
-- ①效果的发动条件和对象选择：在召唤成功时，从自己墓地选择1张满足条件的「咒眼」卡作为取对象目标，并设定加入手卡的操作信息。
function c18551923.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c18551923.filter(chkc) end
	-- 检查自己墓地是否存在至少1张满足过滤条件的「咒眼」卡，作为效果能否发动的依据。
	if chk==0 then return Duel.IsExistingTarget(c18551923.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足过滤条件的「咒眼」卡，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c18551923.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 记录本次处理将把1张卡加入手卡（回手牌类别），操作信息供其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：取得被选择的对象卡，若该卡仍与效果关联，则将其送入持有者手卡。
function c18551923.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的第一张效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因加入持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的发动代价：实际无卡牌消耗，而是根据发动时机为自身注册誓约标志，供③效果判断“下次准备阶段”，同时配合1回合1次的限制。
function c18551923.rmcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 判断当前阶段是否为准备阶段，以便决定誓约标志持续到何时。
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 若在准备阶段发动②，则给这张卡注册一个持续到下次准备阶段的誓约标志，并记录当前回合数；否则注册一个在当次准备阶段即重置的标志。
		e:GetHandler():RegisterFlagEffect(18551923,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_OATH,2,Duel.GetTurnCount())
	else
		e:GetHandler():RegisterFlagEffect(18551923,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_OATH,1,0)
	end
end
-- ②效果的发动条件：检查这张卡的装备区中是否存在「太阴之咒眼」（卡号44133040）。
function c18551923.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	local eg=e:GetHandler():GetEquipGroup()
	return eg and eg:GetCount()>0 and eg:IsExists(Card.IsCode,1,nil,44133040)
end
-- 筛选函数：判断对方墓地中的卡是否为怪兽且能够被除外。
function c18551923.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- ②效果的发动时点与对象选择：作为二速诱发即时效果，在对方回合也能发动；从对方墓地选择1只怪兽作为取对象目标，并设定除外操作信息。
function c18551923.rmtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c18551923.rmfilter(chkc) end
	-- 检查对方墓地是否存在至少1只满足过滤条件的怪兽，作为效果能否发动的依据。
	if chk==0 then return Duel.IsExistingTarget(c18551923.rmfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方墓地选择1只满足过滤条件的怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c18551923.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 记录本次处理将把对方墓地的1张卡除外（除外类别），操作信息供其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- ②效果处理：取得被选择的对象卡，若该卡仍与效果关联，则将其正面表示除外。
function c18551923.rmop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡正面表示除外，原因：效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ③效果的发动条件：检查这张卡上是否存在②效果发动时留下的誓约标志，且当前回合数不是标志记录的回合数，即已进入“下次准备阶段”。
function c18551923.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(18551923)
	-- 返回“誓约标志存在且记录的回合数不等于当前回合数”的判定结果，确保只在下次准备阶段满足条件。
	return tid and tid~=Duel.GetTurnCount()
end
-- ③效果的目标判定：无需选择对象，但需设定从自己墓地除外1张卡的操作信息。
function c18551923.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 记录本次处理将把自己墓地的1张卡除外（除外类别，不取对象），供后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果处理：从自己墓地选择1张可除外的卡并正面表示除外（不取对象，处理时选择）。
function c18551923.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要除外的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足可除外条件的卡（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡正面表示除外，原因：效果。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

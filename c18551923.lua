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
	-- ②：这张卡有「太阴之咒眼」装备的场合，以对方墓地1只怪兽为对象才能发动。那只怪兽除外。这个效果在对方回合也能发动。
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
-- 过滤函数，用于筛选满足条件的墓地「咒眼」卡（非美杜莎本体且可加入手牌）
function c18551923.filter(c)
	return c:IsSetCard(0x129) and not c:IsCode(18551923) and c:IsAbleToHand()
end
-- 处理①效果的选卡阶段，筛选满足条件的墓地「咒眼」卡作为对象
function c18551923.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c18551923.filter(chkc) end
	-- 判断是否满足①效果的发动条件：是否存在满足条件的墓地「咒眼」卡
	if chk==0 then return Duel.IsExistingTarget(c18551923.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地「咒眼」卡作为对象
	local g=Duel.SelectTarget(tp,c18551923.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理①效果的发动效果：将目标卡加入手牌
function c18551923.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的费用支付函数：记录当前回合数以限制使用次数
function c18551923.rmcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 判断当前阶段是否为准备阶段
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 注册标记效果，记录当前回合数以限制②效果使用次数
		e:GetHandler():RegisterFlagEffect(18551923,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_OATH,2,Duel.GetTurnCount())
	else
		e:GetHandler():RegisterFlagEffect(18551923,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_OATH,1,0)
	end
end
-- ②效果的发动条件函数：判断是否装备有「太阴之咒眼」
function c18551923.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	local eg=e:GetHandler():GetEquipGroup()
	return eg and eg:GetCount()>0 and eg:IsExists(Card.IsCode,1,nil,44133040)
end
-- 过滤函数，用于筛选满足条件的对方墓地怪兽（可除外）
function c18551923.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 处理②效果的选卡阶段，筛选满足条件的对方墓地怪兽作为对象
function c18551923.rmtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c18551923.rmfilter(chkc) end
	-- 判断是否满足②效果的发动条件：是否存在满足条件的对方墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c18551923.rmfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的对方墓地怪兽作为对象
	local g=Duel.SelectTarget(tp,c18551923.rmfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息：将选中的对方墓地怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 处理②效果的发动效果：将目标怪兽除外
function c18551923.rmop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ③效果的发动条件函数：判断是否满足下次准备阶段发动的条件
function c18551923.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(18551923)
	-- 判断标记的回合数是否与当前回合不同，以确保只发动一次
	return tid and tid~=Duel.GetTurnCount()
end
-- 处理③效果的选卡阶段，设置操作信息
function c18551923.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：将自己墓地1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 处理③效果的发动效果：选择自己墓地1张卡除外
function c18551923.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的自己墓地卡作为对象
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将目标卡以效果原因除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

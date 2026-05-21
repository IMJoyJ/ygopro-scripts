--いたずら風のフィードラン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：对方回合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。那之后，这张卡回到持有者手卡。
function c92597893.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92597893,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,92597893)
	e1:SetTarget(c92597893.pctg)
	e1:SetOperation(c92597893.pcop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方回合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的表示形式变更。那之后，这张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92597893,1))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_ATTACK+TIMING_END_PHASE)
	e3:SetCountLimit(1,92597894)
	e3:SetCondition(c92597893.poscon)
	e3:SetTarget(c92597893.postg)
	e3:SetOperation(c92597893.posop)
	c:RegisterEffect(e3)
end
-- ①号效果的发动准备，进行对象判定与选择。
function c92597893.pctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在可以作为对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示怪兽作为效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①号效果的处理，给作为对象的怪兽赋予贯通伤害效果。
function c92597893.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ②号效果的发动条件判定。
function c92597893.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合。
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤场上表侧表示且可以改变表示形式的怪兽。
function c92597893.posfilter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- ②号效果的发动准备，进行对象判定与选择，并设置操作信息。
function c92597893.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c92597893.posfilter(chkc) and chkc~=c end
	-- 检查场上是否存在除自身以外可以改变表示形式的表侧表示怪兽，且自身是否能回到手卡。
	if chk==0 then return Duel.IsExistingTarget(c92597893.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) and c:IsAbleToHand() end
	-- 提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上1只除自身以外的表侧表示怪兽作为效果的对象。
	Duel.SelectTarget(tp,c92597893.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置将自身送回手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ②号效果的处理，改变对象怪兽的表示形式，然后将自身送回手卡。
function c92597893.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍适用效果，并将其表示形式变更，若变更成功则继续判定自身是否仍适用效果且能回到手卡。
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0 and c:IsRelateToEffect(e) and c:IsAbleToHand() then
		-- 中断当前效果处理，使后续的回到手卡处理与表示形式变更不视为同时处理。
		Duel.BreakEffect()
		-- 将这张卡回到持有者手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

--ドラゴンメイド・フランメ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「半龙女仆」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升2000。
-- ②：只要自己场上有融合怪兽存在，这张卡不会被效果破坏。
-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只3星「半龙女仆」怪兽特殊召唤。
function c42055234.initial_effect(c)
	-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「半龙女仆」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升2000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42055234,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,42055234)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c42055234.atkcost)
	e1:SetTarget(c42055234.atktg)
	e1:SetOperation(c42055234.atkop)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有融合怪兽存在，这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c42055234.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只3星「半龙女仆」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42055234,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,42055235)
	e3:SetTarget(c42055234.sptg)
	e3:SetOperation(c42055234.spop)
	c:RegisterEffect(e3)
end
-- 将自身从手卡丢弃作为cost
function c42055234.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身送去墓地作为cost
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 判断目标是否为表侧表示的半龙女仆怪兽
function c42055234.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x133)
end
-- 选择一个满足条件的场上怪兽作为对象
function c42055234.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42055234.atkfilter(chkc) end
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c42055234.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的场上怪兽作为对象
	Duel.SelectTarget(tp,c42055234.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 使目标怪兽攻击力上升2000
function c42055234.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 给目标怪兽增加2000攻击力直到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断目标是否为表侧表示的融合怪兽
function c42055234.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 判断自己场上是否存在融合怪兽
function c42055234.indcon(e)
	-- 检查自己场上是否存在融合怪兽
	return Duel.IsExistingMatchingCard(c42055234.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 判断目标是否为3星半龙女仆怪兽
function c42055234.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否满足发动条件：自身能回手、场上存在空位、手卡存在符合条件的怪兽
function c42055234.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 检查场上是否存在空位
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查手卡是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c42055234.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：将自身送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 发动效果：将自身送回手卡并特殊召唤1只3星半龙女仆怪兽
function c42055234.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否在连锁中有效且成功送回手卡
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 检查自身是否在手卡且场上存在空位
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择要特殊召唤的怪兽
		local g=Duel.SelectMatchingCard(tp,c42055234.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

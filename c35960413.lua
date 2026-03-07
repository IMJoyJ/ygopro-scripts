--コウ・キューピット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽只有守备力600的怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：丢弃1张手卡，以自己场上1只天使族·光属性怪兽和场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的等级直到回合结束时变成和另1只怪兽的等级相同。这个效果在对方回合也能发动。
function c35960413.initial_effect(c)
	-- ①：自己场上的怪兽只有守备力600的怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35960413,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,35960413)
	e1:SetCondition(c35960413.spcon)
	e1:SetTarget(c35960413.sptg)
	e1:SetOperation(c35960413.spop)
	c:RegisterEffect(e1)
	-- ②：丢弃1张手卡，以自己场上1只天使族·光属性怪兽和场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的等级直到回合结束时变成和另1只怪兽的等级相同。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35960413,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,35960414)
	e2:SetCost(c35960413.lvcost)
	e2:SetTarget(c35960413.lvtg)
	e2:SetOperation(c35960413.lvop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在正面表示且守备力为600的怪兽
function c35960413.filter(c)
	return c:IsFaceup() and c:IsDefense(600)
end
-- 判断场上正面表示的守备力为600的怪兽数量是否大于0且等于场上怪兽数量
function c35960413.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上正面表示且守备力为600的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c35960413.filter,tp,LOCATION_MZONE,0,nil)
	-- 判断场上正面表示的守备力为600的怪兽数量是否大于0且等于场上怪兽数量
	return ct>0 and ct==Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
-- 设置特殊召唤的处理条件，检查是否有足够的召唤位置和卡牌是否可以被特殊召唤
function c35960413.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将卡牌特殊召唤到场上
function c35960413.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡牌以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置效果发动的代价，丢弃一张手牌
function c35960413.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可丢弃的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃一张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 过滤函数，用于判断场上是否存在正面表示且等级大于等于1的天使族·光属性怪兽
function c35960413.lvfilter(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)
		-- 检查是否存在满足条件的另一只怪兽作为等级变更目标
		and Duel.IsExistingTarget(c35960413.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetLevel())
end
-- 过滤函数，用于判断场上是否存在正面表示且等级大于等于1且等级与指定等级不同的怪兽
function c35960413.cfilter(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- 设置效果发动的目标选择，选择符合条件的怪兽作为对象
function c35960413.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否存在符合条件的怪兽作为等级变更目标
	if chk==0 then return Duel.IsExistingTarget(c35960413.lvfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的怪兽作为等级变更目标
	local g=Duel.SelectTarget(tp,c35960413.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的怪兽作为等级变更目标
	Duel.SelectTarget(tp,c35960413.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc,tc:GetLevel())
end
-- 执行等级变更效果，将目标怪兽的等级改为与另一只怪兽相同
function c35960413.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取当前连锁中设定的目标卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and lc:IsRelateToEffect(e) and lc:IsFaceup() then
		-- 创建一个等级变更效果，使目标怪兽的等级变为指定值，并在回合结束时重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

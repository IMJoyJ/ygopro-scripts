--コウ・キューピット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽只有守备力600的怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：丢弃1张手卡，以自己场上1只天使族·光属性怪兽和场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的等级直到回合结束时变成和另1只怪兽的等级相同。这个效果在对方回合也能发动。
function c35960413.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上的怪兽只有守备力600的怪兽的场合才能发动。这张卡从手卡特殊召唤。
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
-- 筛选自己场上表侧表示且守备力为600的怪兽。
function c35960413.filter(c)
	return c:IsFaceup() and c:IsDefense(600)
end
-- ①效果的发动条件：自己场上的怪兽只有守备力600的怪兽（存在至少1只守备力600的怪兽，且场上所有怪兽都是守备力600）。
function c35960413.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 统计自己场上满足表侧表示且守备力为600的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c35960413.filter,tp,LOCATION_MZONE,0,nil)
	-- 返回是否至少有1只守备力600的怪兽，并且该数量等于自己场上怪兽总数，即自己场上的怪兽只有守备力600的怪兽。
	return ct>0 and ct==Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
-- ①效果的发动目标：检查自己场上有空余怪兽区，且这张卡自身能够被特殊召唤。
function c35960413.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本次效果将进行特殊召唤（对象为这张卡自身），供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：若这张卡仍与效果关联，则将其从手卡特殊召唤。
function c35960413.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动代价：丢弃1张手卡。
function c35960413.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价的合法检查：手卡中是否存在1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际从手卡选1张卡丢弃，丢弃原因为代价与丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 筛选第一个对象：自己场上的表侧表示、等级1以上、天使族、光属性的怪兽（需能再选另一只等级不同的表侧表示怪兽）。
function c35960413.lvfilter(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT)
		-- 追加筛选：场上存在另一只表侧表示、等级1以上、且等级与候选怪兽不同的怪兽可作为第二个对象。
		and Duel.IsExistingTarget(c35960413.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetLevel())
end
-- 筛选第二个对象：场上表侧表示、等级1以上、且等级不等于指定等级的怪兽。
function c35960413.cfilter(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- ②效果的发动目标：选择自己场上1只天使族·光属性怪兽和场上1只表侧表示怪兽作为对象，且二者等级不同。
function c35960413.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法检查：自己场上是否存在满足条件的天使族·光属性怪兽，并能继续选择另一只等级不同的表侧表示怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c35960413.lvfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 弹出选择对象的提示，要求玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择第一个对象（自己的天使族·光属性怪兽），并将其记录到效果e的LabelObject中。
	local g=Duel.SelectTarget(tp,c35960413.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	-- 再次弹出选择对象的提示，要求玩家选择第二个对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择第二个对象：场上除第一只对象外的一只表侧表示且等级不同的怪兽。
	Duel.SelectTarget(tp,c35960413.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc,tc:GetLevel())
end
-- ②效果的处理：从连锁对象中取得另一只怪兽，若两个对象都仍与效果关联且表侧表示，则将第一个对象的等级变成第二个对象的等级直到回合结束时。
function c35960413.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取当前连锁记录下来的所有对象卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and lc:IsRelateToEffect(e) and lc:IsFaceup() then
		-- 那只自己怪兽的等级直到回合结束时变成和另1只怪兽的等级相同。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

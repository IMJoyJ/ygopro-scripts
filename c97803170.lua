--デーモンの呼び声
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以自己墓地1只5星以上的恶魔族怪兽为对象才能发动。从手卡丢弃1只恶魔族怪兽，作为对象的怪兽特殊召唤。
function c97803170.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：以自己墓地1只5星以上的恶魔族怪兽为对象才能发动。从手卡丢弃1只恶魔族怪兽，作为对象的怪兽特殊召唤。（卡片发动时可选择是否同时发动该效果）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c97803170.target)
	c:RegisterEffect(e1)
	-- ①：以自己墓地1只5星以上的恶魔族怪兽为对象才能发动。从手卡丢弃1只恶魔族怪兽，作为对象的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97803170,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(c97803170.cost)
	e2:SetTarget(c97803170.sptg)
	e2:SetOperation(c97803170.spop)
	c:RegisterEffect(e2)
end
-- 1回合只能使用1次限制的Cost判定与注册函数
function c97803170.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家本回合是否已使用过该效果
	if chk==0 then return Duel.GetFlagEffect(tp,97803170)==0 end
	-- 给玩家注册本回合已使用该效果的Flag（持续到回合结束）
	Duel.RegisterFlagEffect(tp,97803170,RESET_PHASE+PHASE_END,0,1)
end
-- 卡片发动时的Target函数，处理卡片发动时是否同时发动该卡的效果
function c97803170.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c97803170.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	if chk==0 then return true end
	local b1=c97803170.cost(e,tp,eg,ep,ev,re,r,rp,0)
		and c97803170.sptg(e,tp,eg,ep,ev,re,r,rp,0)
	-- 如果满足效果发动条件，询问玩家在卡片发动时是否同时发动该效果
	if b1 and Duel.SelectYesNo(tp,94) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(c97803170.spop)
		c97803170.cost(e,tp,eg,ep,ev,re,r,rp,1)
		c97803170.sptg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
-- 过滤自己墓地5星以上的恶魔族怪兽且能特殊召唤的卡
function c97803170.spfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤手卡中的恶魔族怪兽
function c97803170.cfilter(c)
	return c:IsRace(RACE_FIEND)
end
-- 效果发动的对象选择与操作信息设置函数
function c97803170.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c97803170.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的5星以上恶魔族怪兽
		and Duel.IsExistingTarget(c97803170.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查手卡中是否存在恶魔族怪兽
		and Duel.IsExistingMatchingCard(c97803170.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只5星以上的恶魔族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c97803170.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，执行丢弃手卡和特殊召唤
function c97803170.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 让玩家从手卡丢弃1只恶魔族怪兽，若成功丢弃则继续处理
	if Duel.DiscardHand(tp,c97803170.cfilter,1,1,REASON_EFFECT+REASON_DISCARD,nil)~=0 then
		-- 检查怪兽区域是否有空位，以及对象怪兽是否仍与效果相关联
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not tc:IsRelateToEffect(e) then return end
		-- 将作为对象的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

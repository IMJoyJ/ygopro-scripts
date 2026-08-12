--王の影 ロプトル
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：「王战之影 洛普特」在自己场上只能有1只表侧表示存在。
-- ②：自己场上的「王战」怪兽的攻击力·守备力在对方回合内上升1000。
-- ③：自己·对方的主要阶段，把自己场上1只「王战」怪兽解放才能发动。和那只怪兽卡名不同的1只9星「王战」怪兽从卡组特殊召唤。
function c94183877.initial_effect(c)
	c:SetUniqueOnField(1,0,94183877)
	-- ②：自己场上的「王战」怪兽的攻击力·守备力在对方回合内上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c94183877.atktg)
	e1:SetValue(1000)
	e1:SetCondition(c94183877.atkcon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ③：自己·对方的主要阶段，把自己场上1只「王战」怪兽解放才能发动。和那只怪兽卡名不同的1只9星「王战」怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(94183877,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,94183877)
	e3:SetCondition(c94183877.spcon)
	e3:SetCost(c94183877.spcost)
	e3:SetTarget(c94183877.sptg)
	e3:SetOperation(c94183877.spop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的「王战」怪兽作为攻击力上升效果的影响对象
function c94183877.atktg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x134)
end
-- 检查当前是否为对方回合，作为攻击力·守备力上升效果的生效条件
function c94183877.atkcon(e)
	-- 判断当前回合玩家是否为对方玩家
	return Duel.GetTurnPlayer()==1-e:GetHandlerPlayer()
end
-- 检查当前阶段是否为自己或对方的主要阶段，作为效果发动的条件
function c94183877.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤自己场上可解放的「王战」怪兽（需保证解放后有可用怪兽区域，且卡组中存在与其卡名不同的9星「王战」怪兽）
function c94183877.rfilter(c,e,tp)
	-- 检查卡片是否为「王战」怪兽，且该怪兽离开场上后有可用的怪兽区域
	return c:IsSetCard(0x134) and Duel.GetMZoneCount(tp,c)>0
		-- 检查卡组中是否存在至少1张满足特殊召唤条件的卡（与被解放怪兽卡名不同且为9星「王战」怪兽）
		and Duel.IsExistingMatchingCard(c94183877.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 过滤卡组中与被解放怪兽卡名不同的9星「王战」怪兽，且该怪兽可以特殊召唤
function c94183877.spfilter(c,e,tp,code)
	return c:IsSetCard(0x134) and c:IsLevel(9) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的代价：检查并选择自己场上1只「王战」怪兽解放，并记录其卡名
function c94183877.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查场上是否存在至少1只满足解放条件的「王战」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c94183877.rfilter,1,nil,e,tp) end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1只满足条件的「王战」怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c94183877.rfilter,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetCode())
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 效果发动的目标：在发动时进行可行性检查，并设置特殊召唤的操作信息
function c94183877.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的操作信息，表示将从卡组特殊召唤1张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组将1只与解放怪兽卡名不同的9星「王战」怪兽特殊召唤
function c94183877.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local code=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只与解放怪兽卡名不同的9星「王战」怪兽
	local g=Duel.SelectMatchingCard(tp,c94183877.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,code)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

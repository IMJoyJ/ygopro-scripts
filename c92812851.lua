--奇跡の魔導剣士
-- 效果：
-- 包含灵摆怪兽的效果怪兽2只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从自己的额外卡组（表侧）把1只灵摆怪兽加入手卡。
-- ②：这张卡的攻击力上升自己场上的灵摆怪兽卡数量×100。
-- ③：自己·对方的主要阶段才能发动。把持有用自己的灵摆区域2张卡的灵摆刻度可以灵摆召唤的等级的1只灵摆怪兽从自己的手卡·墓地守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：设置连接召唤手续，注册攻击力上升的永续效果，注册连接召唤成功时从额外卡组检索灵摆怪兽的诱发效果，注册主要阶段从手卡·墓地特殊召唤灵摆怪兽的即时任意效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：需要2只以上的效果怪兽作为素材，且必须包含灵摆怪兽。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_EFFECT),2,99,s.gchk)
	-- ②：这张卡的攻击力上升自己场上的灵摆怪兽卡数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	-- ①：这张卡连接召唤的场合才能发动。从自己的额外卡组（表侧）把1只灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：自己·对方的主要阶段才能发动。把持有用自己的灵摆区域2张卡的灵摆刻度可以灵摆召唤的等级的1只灵摆怪兽从自己的手卡·墓地守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 连接素材的过滤条件：素材组中必须包含至少1只灵摆怪兽。
function s.gchk(g)
	return g:IsExists(Card.IsType,1,nil,TYPE_PENDULUM)
end
-- 过滤条件：自己场上表侧表示的、原本类型为灵摆怪兽的卡。
function s.afilter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_PENDULUM~=0
end
-- 计算攻击力上升值：获取自己场上表侧表示的灵摆怪兽卡数量并乘以100。
function s.val(e,c)
	-- 返回自己场上表侧表示的灵摆怪兽卡数量乘以100的数值。
	return Duel.GetMatchingGroupCount(s.afilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*100
end
-- 效果①的发动条件：这张卡是连接召唤成功的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤条件：自己额外卡组表侧表示的、可以加入手卡的灵摆怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果①的发动准备：检查额外卡组是否存在满足条件的卡，并设置检索的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组（表侧）是否存在至少1只可以加入手卡的灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁的操作信息：从额外卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理：让玩家从额外卡组（表侧）选择1只灵摆怪兽加入手卡，并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己额外卡组（表侧）选择1只满足条件的灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡因效果加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果③的发动条件：自己或对方的主要阶段。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤条件：手卡·墓地的灵摆怪兽，其等级介于自己灵摆区域两张卡的灵摆刻度之间，且可以守备表示特殊召唤。
function s.sfilter(c,e,tp)
	-- 获取自己左右两个灵摆区域的卡。
	local l,r=Duel.GetFieldCard(tp,LOCATION_PZONE,0),Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not (l and r) then return false end
	local ls,rs,lv=l:GetCurrentScale(),r:GetCurrentScale(),c:GetLevel()
	return c:IsType(TYPE_PENDULUM) and (lv>ls and lv<rs or lv>rs and lv<ls)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果③的发动准备：检查怪兽区域是否有空位，以及手卡·墓地是否存在满足特召条件的灵摆怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡·墓地是否存在至少1只满足特召条件的灵摆怪兽。
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：从手卡或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果③的效果处理：在怪兽区域有空位的情况下，从手卡·墓地选择1只满足刻度范围的灵摆怪兽守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·墓地选择1只满足刻度范围且不受王家长眠之谷影响的灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的怪兽以守备表示特殊召唤。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end

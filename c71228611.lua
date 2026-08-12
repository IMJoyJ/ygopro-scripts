--ユーカリ・モール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只4星以下的兽族怪兽里侧守备表示特殊召唤。这张卡是攻击表示的场合，再让这张卡变成守备表示。
-- ②：这张卡被破坏的场合才能发动。从卡组把1只「树熊」怪兽特殊召唤，直到下个回合的结束时以下效果适用。
-- ●效果怪兽以外的自己场上的兽族怪兽的攻击力上升自身的原本守备力数值。
local s,id,o=GetID()
-- 初始化卡片效果，注册召唤·特殊召唤成功时发动的效果①，以及被破坏时发动的效果②。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只4星以下的兽族怪兽里侧守备表示特殊召唤。这张卡是攻击表示的场合，再让这张卡变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被破坏的场合才能发动。从卡组把1只「树熊」怪兽特殊召唤，直到下个回合的结束时以下效果适用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤「树熊」怪兽"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤卡组中等级4以下且可以里侧守备表示特殊召唤的兽族怪兽。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果①的启动阶段，检查怪兽区域是否有空位，以及卡组中是否存在符合条件的怪兽，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的4星以下兽族怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：从卡组将1只4星以下兽族怪兽里侧守备表示特殊召唤，若此卡为攻击表示，则再将其变为守备表示。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足条件的4星以下兽族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若成功选出怪兽，则将其以里侧守备表示特殊召唤。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0
		and c:IsRelateToChain() and c:IsPosition(POS_FACEUP_ATTACK) then
		-- 中断当前效果处理，使后续的改变表示形式处理不与特殊召唤同时发生（造成错时点）。
		Duel.BreakEffect()
		-- 将此卡变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 过滤卡组中可以特殊召唤的「树熊」怪兽。
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x1d6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的启动阶段，检查怪兽区域是否有空位，以及卡组中是否存在符合条件的「树熊」怪兽，并设置特殊召唤的操作信息。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的「树熊」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理：从卡组特殊召唤1只「树熊」怪兽，并注册直到下个回合结束时适用的攻击力上升效果。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足条件的「树熊」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若成功选出怪兽，则将其以表侧表示特殊召唤。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- ●效果怪兽以外的自己场上的兽族怪兽的攻击力上升自身的原本守备力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))  --"「桉树鼹鼠」效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(s.atktg)
		e1:SetValue(s.atkval)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 注册该全局效果，使其在场上生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤受攻击力上升效果影响的对象：自己场上效果怪兽以外的兽族怪兽。
function s.atktg(e,c)
	return not c:IsType(TYPE_EFFECT) and c:IsRace(RACE_BEAST)
end
-- 设定攻击力上升的数值为该怪兽的原本守备力。
function s.atkval(e,c)
	return c:GetBaseDefense()
end

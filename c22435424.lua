--竜輝巧－νⅡ
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是机械族怪兽不能仪式召唤。
-- ①：场上有「龙辉巧」卡存在的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡特殊召唤的场合才能发动。从卡组把「龙辉巧-ν2」以外的1只「龙辉巧」怪兽加入手卡。
local s,id,o=GetID()
-- 初始化效果：注册特殊召唤限制、①效果（特殊召唤及离场除外）、②效果（检索怪兽）以及添加仪式召唤限制计数器。
function s.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- ①：场上有「龙辉巧」卡存在的场合才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合才能发动。从卡组把「龙辉巧-ν2」以外的1只「龙辉巧」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.cost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 添加自定义活动计数器，用于检测本回合内是否进行过非机械族怪兽的仪式召唤。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 过滤函数：若进行特殊召唤，须满足该怪兽是表侧表示的机械族，或者进行的特殊召唤不是仪式召唤。
function s.counterfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsFaceup() or not c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 特殊召唤限制：限制只能通过卡的效果进行特殊召唤。
function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 过滤函数：场上表侧表示的「龙辉巧」卡片。
function s.cfilter(c)
	return c:IsSetCard(0x154) and c:IsFaceup()
end
-- ①的效果发动条件：场上存在表侧表示的「龙辉巧」卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1张表侧表示的「龙辉巧」卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- ①和②效果的发动cost：检查本回合是否曾进行过非机械族怪兽的仪式召唤，并注册本回合不能将非机械族怪兽仪式召唤的约束效果。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合在发动效果前是否未进行过非机械族怪兽的仪式召唤。
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这些效果发动的回合，自己不是机械族怪兽不能仪式召唤。①：场上有「龙辉巧」卡存在的场合才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册本回合内不能仪式召唤非机械族怪兽的效果。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤：限制不能进行非机械族怪兽的仪式召唤。
function s.splimit2(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_MACHINE) and sumtype&SUMMON_TYPE_RITUAL==SUMMON_TYPE_RITUAL
end
-- ①的效果的target函数：检查自己场上是否有空怪兽区域以及这张卡是否可以特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果的operation函数：特殊召唤这张卡，并注册其离场时除外的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若卡片仍关联该效果，则将该卡以表侧表示特殊召唤，并判断特殊召唤是否成功。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：这张卡特殊召唤的场合才能发动。从卡组把「龙辉巧-ν2」以外的1只「龙辉巧」怪兽加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤函数：卡组中与当前卡名不同的一只「龙辉巧」怪兽，且能加入手牌。
function s.thfilter(c)
	return c:IsSetCard(0x154) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and not c:IsCode(id)
end
-- ②的效果的target函数：检查卡组中是否存在可检索的目标怪兽，并设置加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在除了当前卡名以外的「龙辉巧」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②的效果的operation函数：从卡组选择一张符合条件的「龙辉巧」怪兽加入手牌，并向对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在界面提示玩家进行检索（加入手牌）的操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择一张符合条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽卡加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end

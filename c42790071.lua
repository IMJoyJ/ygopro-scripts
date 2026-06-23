--オルターガイスト・マルチフェイカー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己把陷阱卡发动的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动（这个效果发动的回合，自己不是「幻变骚灵」怪兽不能特殊召唤）。从卡组把「幻变骚灵·多功能诈骗者」以外的1只「幻变骚灵」怪兽守备表示特殊召唤。
function c42790071.initial_effect(c)
	-- ①：自己把陷阱卡发动的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42790071,0))  --"这张卡从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetCountLimit(1,42790071)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c42790071.spcon1)
	e2:SetTarget(c42790071.sptg1)
	e2:SetOperation(c42790071.spop1)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤的场合才能发动（这个效果发动的回合，自己不是「幻变骚灵」怪兽不能特殊召唤）。从卡组把「幻变骚灵·多功能诈骗者」以外的1只「幻变骚灵」怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42790071,1))  --"从卡组把「幻变骚灵」怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,42790072)
	e3:SetCost(c42790071.spcost)
	e3:SetTarget(c42790071.sptg2)
	e3:SetOperation(c42790071.spop2)
	c:RegisterEffect(e3)
	-- 注册自定义活动计数器，用于监控玩家特殊召唤的怪兽是否为「幻变骚灵」怪兽
	Duel.AddCustomActivityCounter(42790071,ACTIVITY_SPSUMMON,c42790071.counterfilter)
end
-- 计数器过滤条件：检查特殊召唤的怪兽是否是表侧表示的「幻变骚灵」怪兽
function c42790071.counterfilter(c)
	return c:IsSetCard(0x103) and c:IsFaceup()
end
-- 效果①的发动条件判定：自己发动陷阱卡
function c42790071.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
-- 效果①的发动检测：检查自己怪兽区域是否有空位，且手卡的这张卡是否可以特殊召唤
function c42790071.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空置的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：若这张卡仍存在，则将其特殊召唤
function c42790071.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动Cost与誓约限制：检查本回合是否只特殊召唤过「幻变骚灵」怪兽，并在发动时施加本回合不能特殊召唤非「幻变骚灵」怪兽的誓约
function c42790071.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合自己是否没有特殊召唤过「幻变骚灵」以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(42790071,tp,ACTIVITY_SPSUMMON)==0 end
	-- （这个效果发动的回合，自己不是「幻变骚灵」怪兽不能特殊召唤）。从卡组把「幻变骚灵·多功能诈骗者」以外的1只「幻变骚灵」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c42790071.splimit)
	-- 注册玩家限制效果，使本回合无法特殊召唤「幻变骚灵」以外的怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制判定：不能特殊召唤非「幻变骚灵」怪兽
function c42790071.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x103)
end
-- 特殊召唤的卡片过滤：属于「幻变骚灵」且卡名不是「幻变骚灵·多功能诈骗者」且可以守备表示特殊召唤的怪兽
function c42790071.filter(c,e,tp)
	return c:IsSetCard(0x103) and not c:IsCode(42790071) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动检测：检查自己场上是否有空怪兽区域，且卡组中存在可以特殊召唤的符合条件的「幻变骚灵」怪兽
function c42790071.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空置的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的符合条件的「幻变骚灵」怪兽
		and Duel.IsExistingMatchingCard(c42790071.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组将1只「幻变骚灵·多功能诈骗者」以外的「幻变骚灵」怪兽守备表示特殊召唤
function c42790071.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有空怪兽区域则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张符合条件的「幻变骚灵」怪兽
	local g=Duel.SelectMatchingCard(tp,c42790071.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

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
	-- 设置一个计数器，用于记录玩家在回合中特殊召唤的幻变骚灵怪兽数量
	Duel.AddCustomActivityCounter(42790071,ACTIVITY_SPSUMMON,c42790071.counterfilter)
end
-- 计数器过滤函数，判断卡片是否为幻变骚灵卡组
function c42790071.counterfilter(c)
	return c:IsSetCard(0x103)
end
-- 效果条件函数，判断是否为己方发动的陷阱卡
function c42790071.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
-- 效果发动时的处理函数，判断是否满足特殊召唤条件
function c42790071.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将此卡特殊召唤到场上
function c42790071.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作，将此卡以正面表示形式特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动时的处理函数，设置不能特殊召唤非幻变骚灵怪兽的效果
function c42790071.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否为本回合第一次特殊召唤幻变骚灵怪兽
	if chk==0 then return Duel.GetCustomActivityCount(42790071,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个永续效果，使本回合不能特殊召唤非幻变骚灵怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c42790071.splimit)
	-- 将效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标函数，禁止特殊召唤非幻变骚灵怪兽
function c42790071.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x103)
end
-- 过滤函数，筛选卡组中幻变骚灵怪兽（除自身外）
function c42790071.filter(c,e,tp)
	return c:IsSetCard(0x103) and not c:IsCode(42790071) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的处理函数，判断是否满足特殊召唤条件
function c42790071.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的幻变骚灵怪兽
		and Duel.IsExistingMatchingCard(c42790071.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将要从卡组特殊召唤幻变骚灵怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，从卡组选择并特殊召唤幻变骚灵怪兽
function c42790071.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的幻变骚灵怪兽
	local g=Duel.SelectMatchingCard(tp,c42790071.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作，将选中的幻变骚灵怪兽以守备表示形式特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

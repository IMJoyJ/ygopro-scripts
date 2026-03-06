--赫焉竜グランギニョル
-- 效果：
-- 「赫之圣女 卡尔特西娅」＋光·暗属性怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从卡组·额外卡组把1只6星以上的光·暗属性怪兽送去墓地。
-- ②：这张卡在怪兽区域或墓地存在的状态，对方发动的怪兽的效果让怪兽特殊召唤的场合，把这张卡除外才能发动。从卡组把1只「教导」怪兽或者从额外卡组把1只「死狱乡」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，注册融合召唤限制和两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为95515789的怪兽和1个满足条件的光暗属性怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,95515789,s.matfilter,1,true,true)
	-- ①：这张卡融合召唤的场合才能发动。从卡组·额外卡组把1只6星以上的光·暗属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域或墓地存在的状态，对方发动的怪兽的效果让怪兽特殊召唤的场合，把这张卡除外才能发动。从卡组把1只「教导」怪兽或者从额外卡组把1只「死狱乡」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	-- 设置效果发动时需要将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 融合素材过滤函数，判断是否为光暗属性怪兽
function s.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 效果①的发动条件，判断此卡是否为融合召唤
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①的目标过滤函数，判断是否为6星以上光暗属性可送去墓地的怪兽
function s.tgfilter(c)
	return c:IsLevelAbove(6) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
-- 效果①的发动时处理函数，检查是否有满足条件的怪兽
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置效果①的发动信息，提示将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果①的发动效果处理函数，选择并送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 判断对方发动的怪兽效果是否让怪兽特殊召唤的过滤函数
function s.cfilter(c,tp)
	local typ,se,sp=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_REASON_EFFECT,SUMMON_INFO_REASON_PLAYER)
	return se and typ&TYPE_MONSTER~=0 and se:IsActivated() and sp==1-tp
end
-- 效果②的发动条件，判断是否有对方发动的怪兽效果让怪兽特殊召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 效果②的目标过滤函数，判断是否为「教导」或「死狱乡」怪兽且满足特殊召唤条件
function s.spfilter(c,e,tp,exc)
	local b1=c:IsSetCard(0x145) and c:IsLocation(LOCATION_DECK)
		-- 判断是否有足够的怪兽区域
		and Duel.GetMZoneCount(tp,exc)>0
	local b2=c:IsSetCard(0x164) and c:IsLocation(LOCATION_EXTRA)
		-- 判断是否有足够的额外卡组召唤区域
		and Duel.GetLocationCountFromEx(tp,tp,exc,c)>0
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (b1 or b2)
end
-- 效果②的发动时处理函数，检查是否有满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置效果②的发动信息，提示将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果②的发动效果处理函数，选择并特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

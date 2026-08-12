--アイス・ライゼオル
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以把自己的手卡·场上1张卡送去墓地，从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是4阶超量怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤的场合才能发动。从卡组把「内燃雷火沸动机」以外的1只「雷火沸动」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特殊召唤的规则效果和召唤成功时从卡组特殊召唤的诱发效果。
function s.initial_effect(c)
	-- ①：这张卡可以把自己的手卡·场上1张卡送去墓地，从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是4阶超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤的场合才能发动。从卡组把「内燃雷火沸动机」以外的1只「雷火沸动」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片是否满足送去墓地的条件，且该卡送去墓地后能腾出可用的怪兽区域。
function s.cfilter(c,tp,f)
	-- 检查卡片是否满足过滤条件f（可以作为Cost送去墓地），且该卡离开场上后有可用的怪兽区域。
	return f(c) and Duel.GetMZoneCount(tp,c)>0
end
-- 手卡特殊召唤规则的条件函数：检查自己手卡或场上是否存在至少1张可以作为Cost送去墓地的卡。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己的手卡或场上是否存在至少1张可以作为Cost送去墓地的卡（排除自身）。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c,tp,Card.IsAbleToGraveAsCost)
end
-- 手卡特殊召唤规则的Target函数：让玩家选择1张手卡或场上的卡送去墓地，并将其记录在效果对象中。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己手卡或场上所有可以作为Cost送去墓地且能腾出怪兽区域的卡片组。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,c,tp,Card.IsAbleToGraveAsCost)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 手卡特殊召唤规则的Operation函数：将选择的卡送去墓地，并注册“这个回合自己不是4阶超量怪兽不能从额外卡组特殊召唤”的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡作为特殊召唤的代替（Cost）送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	-- 这个方法特殊召唤过的回合，自己不是4阶超量怪兽不能从额外卡组特殊召唤。②：这张卡召唤的场合才能发动。从卡组把「内燃雷火沸动机」以外的1只「雷火沸动」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该回合的特殊召唤限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制过滤函数：限制从额外卡组特殊召唤的怪兽必须是4阶超量怪兽。
function s.splimit(e,c)
	return not (c:IsType(TYPE_XYZ) and c:IsRank(4)) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数：检查卡组中是否存在「内燃雷火沸动机」以外的「雷火沸动」怪兽，且该怪兽可以特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1be) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的Target函数：检查怪兽区域是否有空位以及卡组中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件：在chk为0（检查是否可行）时，确认自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认卡组中是否存在至少1只满足条件的「雷火沸动」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的Operation函数：从卡组选择1只「内燃雷火沸动机」以外的「雷火沸动」怪兽特殊召唤到场上。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已没有可用的怪兽区域，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「雷火沸动」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

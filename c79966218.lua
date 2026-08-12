--血樹竜姫ドラセレア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是龙族·植物族怪兽不能特殊召唤。
-- ①：把除「血树龙姬 龙血树鬼」外的1只4星以下的植物族怪兽从卡组送去墓地才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的等级变成和送去墓地的怪兽相同。
-- ②：从自己墓地把这张卡和1只植物族怪兽除外才能发动。从自己的手卡·墓地把1只龙族怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果并设置特殊召唤限制的计数器
function s.initial_effect(c)
	-- ①：把除「血树龙姬 龙血树鬼」外的1只4星以下的植物族怪兽从卡组送去墓地才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的等级变成和送去墓地的怪兽相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和1只植物族怪兽除外才能发动。从自己的手卡·墓地把1只龙族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- 添加自定义活动计数器，用于检测本回合是否特殊召唤过龙族·植物族以外的怪兽
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤条件：表侧表示的龙族或植物族怪兽
function s.counterfilter(c)
	return c:IsRace(RACE_DRAGON+RACE_PLANT) and c:IsFaceup()
end
-- 过滤卡组中除「血树龙姬 龙血树鬼」以外的4星以下且能送去墓地的植物族怪兽
function s.thfilter(c)
	return not c:IsCode(id) and c:IsRace(RACE_PLANT) and c:IsLevelBelow(4) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动条件与代价检测：本回合未特殊召唤过龙族·植物族以外的怪兽，且卡组中存在满足条件的植物族怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否未特殊召唤过龙族·植物族以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
		-- 检查卡组中是否存在满足条件的植物族怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择卡组中1只满足条件的植物族怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
	-- 这些效果发动的回合，自己不是龙族·植物族怪兽不能特殊召唤。①：把除「血树龙姬 龙血树鬼」外的1只4星以下的植物族怪兽从卡组送去墓地才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的等级变成和送去墓地的怪兽相同。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册不能特殊召唤龙族·植物族以外怪兽的玩家限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非龙族且非植物族的怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_DRAGON+RACE_PLANT)
end
-- 效果①的靶向检测：检查怪兽区域是否有空位，且自身能否特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否可以特殊召唤到怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：特殊召唤自身，并将其等级变为与送去墓地的怪兽相同
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	-- 检查自身是否仍在连锁中，若成功特殊召唤且等级与送去墓地的怪兽不同，则进行等级变更处理
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsFaceup() and not c:IsLevel(lv) then
		-- 这个效果特殊召唤的这张卡的等级变成和送去墓地的怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤墓地中可以作为代价除外的植物族怪兽，且手牌或墓地存在可特殊召唤的龙族怪兽
function s.cfilter(c,e,tp,ec)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemoveAsCost()
		-- 检查手牌或墓地中是否存在除代价卡以外的、可特殊召唤的龙族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,Group.FromCards(c,ec),e,tp)
end
-- 效果②的发动条件与代价检测：本回合未特殊召唤过龙族·植物族以外的怪兽，自身可除外，且墓地存在可除外的植物族怪兽
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查本回合是否未特殊召唤过龙族·植物族以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
		and c:IsAbleToRemoveAsCost()
		-- 检查墓地中是否存在除自身以外、可作为代价除外的植物族怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,c,e,tp,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择墓地中1只满足条件的植物族怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp,c)
	g:AddCard(c)
	-- 将选择的怪兽和自身除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 这些效果发动的回合，自己不是龙族·植物族怪兽不能特殊召唤。②：从自己墓地把这张卡和1只植物族怪兽除外才能发动。从自己的手卡·墓地把1只龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册不能特殊召唤龙族·植物族以外怪兽的玩家限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤手牌或墓地中可以特殊召唤的龙族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向检测：检查怪兽区域是否有空位，且手牌或墓地是否存在可特殊召唤的龙族怪兽，并设置特殊召唤的操作信息
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地中是否存在可特殊召唤的龙族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置从手牌或墓地特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的处理：从手牌或墓地特殊召唤1只龙族怪兽
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择手牌或墓地中1只满足条件的龙族怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的龙族怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

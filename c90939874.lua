--六武式真伝天魔六段衝
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「六武众」同调怪兽3种类以上存在的场合才能发动（为这张卡发动而需要的怪兽种类改成自己场上的武士道指示物每有6个则少要1种类的数量）。对方场上的卡全部破坏。
-- ②：盖放的这张卡被对方的所发动的效果所破坏的场合或者所除外的场合才能发动。从卡组·额外卡组把1只「六武众」怪兽或「紫炎」效果怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（自由时点发动破坏对方全场卡）和②效果（盖放的此卡被对方效果破坏或除外时特召卡组·额外卡组的怪兽）。
function s.initial_effect(c)
	-- ①：自己场上有「六武众」同调怪兽3种类以上存在的场合才能发动（为这张卡发动而需要的怪兽种类改成自己场上的武士道指示物每有6个则少要1种类的数量）。对方场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被对方的所发动的效果所破坏的场合或者所除外的场合才能发动。从卡组·额外卡组把1只「六武众」怪兽或「紫炎」效果怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「六武众」同调怪兽。
function s.cfilter(c)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- ①效果的发动条件判定：计算己方场上武士道指示物数量，折算减少所需的同调怪兽种类数，并检查场上表侧表示的「六武众」同调怪兽种类数是否满足要求。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上存在的武士道指示物（0x3）的总数量。
	local ct=Duel.GetCounter(tp,1,0,0x3)
	local rt=3-math.floor(ct/6)
	if rt<=0 then return true end
	-- 获取己方场上所有表侧表示的「六武众」同调怪兽。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	return g:GetCount()>0 and g:GetClassCount(Card.GetCode)>=rt
end
-- ①效果的发动准备：确认对方场上存在至少1张卡，并向系统注册破坏对方场上所有卡的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果处理的操作信息，表示将要破坏对方场上的所有卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ①效果的效果处理：获取对方场上的所有卡并将其全部破坏。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 因效果破坏获取到的对方场上的所有卡。
	Duel.Destroy(sg,REASON_EFFECT)
end
-- ②效果的发动条件判定：此卡因对方发动的效果而被破坏（或除外），且在此之前是己方场上盖放的卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN) and re and re:IsActivated()
end
-- 过滤条件：卡组或额外卡组中可以特殊召唤的「六武众」怪兽或「紫炎」效果怪兽，且对应区域有空余怪兽槽。
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0x103d) or c:IsSetCard(0x20) and c:IsType(TYPE_EFFECT))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若卡片在卡组，则需要己方场上有可用的主要怪兽区域。
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若卡片在额外卡组，则需要己方场上有可用的额外怪兽区域或与其相关的怪兽区域。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ②效果的发动准备：确认卡组或额外卡组中存在可特殊召唤的符合条件的怪兽，并向系统注册特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组是否存在至少1只满足特殊召唤条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置效果处理的操作信息，表示将从卡组或额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ②效果的效果处理：让玩家从卡组或额外卡组选择1只符合条件的怪兽，并将其表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或额外卡组中选择1只满足特殊召唤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

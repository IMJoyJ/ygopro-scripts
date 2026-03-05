--神域 バ＝ティスティナ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从卡组把1只「提斯蒂娜」怪兽送去墓地。对方场上有表侧表示卡3张以上存在的场合，可以再从手卡·卡组把1只「结晶神 提斯蒂娜」特殊召唤。
-- ②：场地区域的这张卡被对方的效果破坏的场合才能发动。从自己的卡组·墓地把1只「提斯蒂娜」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果和两个效果，分别是①效果和②效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。从卡组把1只「提斯蒂娜」怪兽送去墓地。对方场上有表侧表示卡3张以上存在的场合，可以再从手卡·卡组把1只「结晶神 提斯蒂娜」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	-- ②：场地区域的这张卡被对方的效果破坏的场合才能发动。从自己的卡组·墓地把1只「提斯蒂娜」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选「提斯蒂娜」怪兽且能送去墓地
function s.filter(c)
	return c:IsSetCard(0x1a4) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ①效果的处理目标函数，检查是否能从卡组选择1只「提斯蒂娜」怪兽送去墓地
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能从卡组选择1只「提斯蒂娜」怪兽送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组选择1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于筛选「结晶神 提斯蒂娜」怪兽且能特殊召唤
function s.sfilter(c,e,tp)
	return c:IsCode(86999951) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理函数，选择并送去墓地1只「提斯蒂娜」怪兽，并判断是否满足再特殊召唤条件
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 从卡组选择1只「提斯蒂娜」怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡送去墓地且该卡在墓地
	if not (Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 判断对方场上是否有3张以上表侧表示的卡
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,3,nil)
		-- 判断自己场上是否有空位可特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then return end
	-- 获取自己卡组和手卡中所有「结晶神 提斯蒂娜」怪兽
	local tg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 判断是否有「结晶神 提斯蒂娜」怪兽可特殊召唤，并询问玩家是否发动
	if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=tg:Select(tp,1,1,nil)
		-- 中断当前效果处理，使后续效果处理视为不同时处理
		Duel.BreakEffect()
		-- 将选择的「结晶神 提斯蒂娜」怪兽特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件函数，判断该卡是否被对方效果破坏且在场地区域
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_FZONE) and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 过滤函数，用于筛选「提斯蒂娜」怪兽且能特殊召唤
function s.rfilter(c,e,tp)
	return c:IsSetCard(0x1a4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的处理目标函数，检查是否能从卡组或墓地选择1只「提斯蒂娜」怪兽特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空位可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否能从卡组或墓地选择1只「提斯蒂娜」怪兽特殊召唤
		and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从卡组或墓地选择1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的处理函数，从卡组或墓地选择并特殊召唤1只「提斯蒂娜」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空位可特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从卡组或墓地选择1只「提斯蒂娜」怪兽特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选择的「提斯蒂娜」怪兽特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end

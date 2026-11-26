--神域 バ＝ティスティナ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从卡组把1只「提斯蒂娜」怪兽送去墓地。对方场上有表侧表示卡3张以上存在的场合，可以再从手卡·卡组把1只「结晶神 提斯蒂娜」特殊召唤。
-- ②：场地区域的这张卡被对方的效果破坏的场合才能发动。从自己的卡组·墓地把1只「提斯蒂娜」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法发动许可及①②效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。从卡组把1只「提斯蒂娜」怪兽送去墓地。对方场上有表侧表示卡3张以上存在的场合，可以再从手卡·卡组把1只「结晶神 提斯蒂娜」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
-- 过滤条件：检查卡片是否为可以送去墓地的「提斯蒂娜」怪兽。
function s.filter(c)
	return c:IsSetCard(0x1a4) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ①效果的目标处理函数：检查发动条件并设置送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己卡组存在至少1只符合条件的「提斯蒂娜」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从自己卡组把1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：检查卡片是否为可以特殊召唤的「结晶神 提斯蒂娜」。
function s.sfilter(c,e,tp)
	return c:IsCode(86999951) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理函数：选卡组1只「提斯蒂娜」怪兽送墓，满足条件时可选特招「结晶神 提斯蒂娜」。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送提示信息，引导玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1只满足条件的「提斯蒂娜」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将所选怪兽以效果送去墓地，并确认其确实进入了墓地。
	if not (Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 检查对方场上是否存在至少3张表侧表示的卡。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,3,nil)
		-- 检查自己主要怪兽区是否有空位，若以上任一条件不满足则结束处理。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then return end
	-- 获取自己手卡和卡组中可特殊召唤的「结晶神 提斯蒂娜」卡片组。
	local tg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 若存在可特招的「结晶神 提斯蒂娜」，询问玩家是否将其特殊召唤。
	if #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把1只「结晶神 提斯蒂娜」特殊召唤？"
		-- 发送提示信息，引导玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=tg:Select(tp,1,1,nil)
		-- 中断当前效果处理，使后续特殊召唤与之前的送墓视为不同时处理。
		Duel.BreakEffect()
		-- 将选择的「结晶神 提斯蒂娜」以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：检查这张卡是否在己方场地区域被对方的效果破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_FZONE) and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 过滤条件：检查卡片是否为可以特殊召唤的「提斯蒂娜」怪兽。
function s.rfilter(c,e,tp)
	return c:IsSetCard(0x1a4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标处理函数：检查自己怪兽区空位以及卡组·墓地是否存在可特招的「提斯蒂娜」怪兽，并设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己怪兽区至少有1个空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己卡组或墓地存在至少1只可特殊召唤的「提斯蒂娜」怪兽。
		and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：预计从自己卡组或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的处理函数：从自己卡组或墓地选1只「提斯蒂娜」怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查自己怪兽区是否有空位，没有则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送提示信息，引导玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组·墓地选择1只不受王家长眠之谷影响的「提斯蒂娜」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将所选「提斯蒂娜」怪兽以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end

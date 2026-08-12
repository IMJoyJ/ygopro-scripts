--海皇龍神 ポセイドラ・アビス
-- 效果：
-- 7星怪兽×3
-- 「海皇龙神 波塞德拉·深渊」1回合1次也能在自己场上的「海皇」超量怪兽或「水精鳞」超量怪兽上面重叠来超量召唤。
-- ①：1回合1次，把这张卡2个超量素材取除，从手卡·卡组把1只水属性怪兽送去墓地才能发动。对方场上最多3张卡回到手卡。
-- ②：超量召唤的这张卡被送去墓地的场合，把1张手卡丢弃去墓地才能发动。从自己的手卡·墓地把3只3星以下的鱼族·海龙族·水族怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：设置超量召唤手续、苏生限制，并注册效果①和效果②。
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)  --"是否在超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡2个超量素材取除，从手卡·卡组把1只水属性怪兽送去墓地才能发动。对方场上最多3张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"回到手卡效果"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：超量召唤的这张卡被送去墓地的场合，把1张手卡丢弃去墓地才能发动。从自己的手卡·墓地把3只3星以下的鱼族·海龙族·水族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：用于重叠超量召唤的、场上表侧表示的「海皇」或「水精鳞」超量怪兽。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x77,0x74) and c:IsType(TYPE_XYZ)
end
-- 重叠超量召唤时的操作：检查并注册该召唤方式的每回合1次限制。
function s.xyzop(e,tp,chk)
	-- 检查本回合是否已经使用过该重叠超量召唤方式。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 注册本回合已使用过该重叠超量召唤方式的誓约标识，持续到回合结束。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 过滤条件：手卡或卡组中可以送去墓地的水属性怪兽。
function s.cfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价：检查是否能取除2个超量素材，并且手卡或卡组中存在可送去墓地的水属性怪兽。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST)
		-- 检查手卡或卡组中是否存在至少1只满足条件的水属性怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的水属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp)
	-- 将选择的怪兽作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的发动检查：检查对方场上是否存在可以回到手卡的卡，并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有可以回到手卡的卡片。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置连锁处理的操作信息：预计将对方场上的卡送回手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的效果处理：让玩家选择对方场上最多3张卡送回手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从对方场上选择1到3张可以回到手卡的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil):Select(tp,1,3,nil)
	if #g>0 then
		-- 为选择的卡片显示被选为效果影响对象的动画效果。
		Duel.HintSelection(g)
		-- 将选择的卡片送回持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 效果②的发动条件：检查这张卡是否曾是超量召唤的怪兽且从怪兽区域送去墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤条件：手卡中可以作为代价丢弃去墓地的卡。
function s.spcfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsDiscardable()
end
-- 效果②的发动代价：检查并执行丢弃1张手卡的操作。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡。
	Duel.DiscardHand(tp,s.spcfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：等级3以下的鱼族、海龙族或水族怪兽，且可以特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_AQUA+RACE_FISH+RACE_SEASERPENT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动检查：检查怪兽区域空位数、是否受青眼精灵龙限制，以及手卡或墓地是否存在3只满足条件的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域是否有3个以上的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检查手卡或墓地中是否存在至少3只满足条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,3,nil,e,tp) end
	-- 设置连锁处理的操作信息：预计从手卡或墓地特殊召唤3只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的效果处理：从手卡或墓地选择3只满足条件的怪兽特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查手卡或墓地（受王家长眠之谷影响）中满足条件的怪兽数量是否依然足3只，不足则不处理。
	if Duel.GetMatchingGroupCount(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)<3 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择3只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,3,3,nil,e,tp)
	if g:GetCount()>2 then
		-- 将选择的3只怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

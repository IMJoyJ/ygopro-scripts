--超電導戦騎プラズマ・マグナム
-- 效果：
-- 岩石族·地属性怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从卡组把1张「磁力」通常·速攻·场地魔法卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，场上的表侧表示怪兽变成地属性。
-- ③：从卡组把1只8星「磁石战士」怪兽送去墓地才能发动。进行1只4星以下的「磁石战士」怪兽的召唤。
local s,id,o=GetID()
-- 初始化效果：为「超电导战骑 等离子磁炮王」注册以2只岩石族·地属性怪兽为素材的融合召唤手续，以及①检索「磁力」魔法卡、②全场表侧怪兽地属性化、③从卡组送墓8星「磁石战士」并进行1只4星以下「磁石战士」召唤的三个效果。
function s.initial_effect(c)
	-- 为这张卡添加融合召唤手续：融合素材为2只满足s.matfilter条件的怪兽（即岩石族·地属性怪兽），且允许通过融合召唤特殊召唤。
	aux.AddFusionProcFunRep(c,s.matfilter,2,true)
	c:EnableReviveLimit()
	-- ①：这张卡融合召唤的场合才能发动。从卡组把1张「磁力」通常·速攻·场地魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，场上的表侧表示怪兽变成地属性。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(ATTRIBUTE_EARTH)
	c:RegisterEffect(e2)
	-- ③：从卡组把1只8星「磁石战士」怪兽送去墓地才能发动。进行1只4星以下的「磁石战士」怪兽的召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"召唤"
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.sumcost)
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤条件：怪兽必须为地属性且岩石族。
function s.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_ROCK)
end
-- ①效果的发动条件：这张卡以融合召唤方式特殊召唤成功时才能发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ①效果的检索对象过滤：卡名含有「磁力」的魔法卡，且为通常魔法、速攻魔法或场地魔法，并且能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1d9) and (c:GetType()==TYPE_SPELL or c:IsType(TYPE_QUICKPLAY+TYPE_FIELD)) and c:IsAbleToHand()
end
-- ①效果的目标判定与操作信息：检查卡组是否存在符合条件的「磁力」魔法卡，并设置效果处理时将1张卡从卡组加入手卡的信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查：卡组中是否存在至少1张符合条件的「磁力」魔法卡（若无则不能发动）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果处理时将会把1张卡从卡组加入持有者的手卡（用于连锁判定等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组检索1张「磁力」通常·速攻·场地魔法卡加入手卡，并让对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张符合条件的「磁力」魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡（不指定玩家时默认加入其持有者手卡），原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认所加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的cost过滤条件：卡名含有「磁石战士」、等级为8、并且可以作为cost送去墓地。
function s.cfilter(c)
	return c:IsSetCard(0xe9) and c:IsLevel(8) and c:IsAbleToGraveAsCost()
end
-- ③效果的cost处理：从卡组选择1只8星「磁石战士」怪兽送去墓地作为发动代价。
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查：卡组中是否存在至少1只符合条件的8星「磁石战士」怪兽（若无则不能发动）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 显示选择提示：请玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选出1只8星「磁石战士」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送去墓地，原因标记为代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ③效果的召唤对象过滤条件：卡名含有「磁石战士」、等级为4以下、并且当前可以进行通常召唤。
function s.sumfilter(c)
	return c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsSummonable(true,nil)
end
-- ③效果的目标判定与操作信息：检查手牌或场上是否存在可以通常召唤的4星以下「磁石战士」怪兽，并设置效果处理时将进行1只怪兽的召唤。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查：手牌或场上是否存在至少1只符合条件的「磁石战士」怪兽可以召唤（若无则不能发动）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：本效果处理时将会进行1只怪兽的通常召唤（用于连锁判定等）。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ③效果处理：选择手牌或场上1只4星以下的「磁石战士」怪兽，进行无视通召次数的通常召唤。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请玩家选择要召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌或场上选择1只符合条件的「磁石战士」怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		-- 将选择的怪兽进行通常召唤，忽略本回合的通常召唤次数限制。
		Duel.Summon(tp,tc,true,nil)
	end
end

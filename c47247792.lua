--超電導戦騎プラズマ・マグナム
-- 效果：
-- 岩石族·地属性怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从卡组把1张「磁力」通常·速攻·场地魔法卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，场上的表侧表示怪兽变成地属性。
-- ③：从卡组把1只8星「磁石战士」怪兽送去墓地才能发动。进行1只4星以下的「磁石战士」怪兽的召唤。
local s,id,o=GetID()
-- 初始化效果函数，设置融合召唤手续、启用复活限制并注册三个效果
function s.initial_effect(c)
	-- 添加融合召唤条件，使用2个满足s.matfilter条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,s.matfilter,2,true)
	c:EnableReviveLimit()
	-- 效果①：融合召唤成功时发动，检索1张「磁力」通常·速攻·场地魔法卡加入手牌
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
	-- 效果②：只要此卡在场，场上的表侧表示怪兽变为地属性
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(ATTRIBUTE_EARTH)
	c:RegisterEffect(e2)
	-- 效果③：从卡组将1只8星「磁石战士」怪兽送去墓地才能发动，召唤1只4星以下的「磁石战士」怪兽
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
-- 融合素材过滤函数，筛选地属性岩石族怪兽
function s.matfilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_ROCK)
end
-- 效果①的发动条件，判断此卡是否为融合召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 检索卡牌过滤函数，筛选「磁力」魔法卡（通常/速攻/场地）且可加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x1d9) and (c:GetType()==TYPE_SPELL or c:IsType(TYPE_QUICKPLAY+TYPE_FIELD)) and c:IsAbleToHand()
end
-- 效果①的目标设定函数，检查卡组是否存在满足条件的卡牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足s.thfilter条件的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数，选择并把符合条件的卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡牌组成group
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选卡牌
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 召唤cost过滤函数，筛选8星「磁石战士」怪兽且可送去墓地作为费用
function s.cfilter(c)
	return c:IsSetCard(0xe9) and c:IsLevel(8) and c:IsAbleToGraveAsCost()
end
-- 效果③的费用处理函数，选择并把符合条件的卡送去墓地
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足s.cfilter条件的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡牌组成group
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡牌送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 召唤目标过滤函数，筛选4星以下「磁石战士」怪兽且可通常召唤
function s.sumfilter(c)
	return c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsSummonable(true,nil)
end
-- 效果③的目标设定函数，检查手牌或场上是否存在满足条件的怪兽
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或场上是否存在满足s.sumfilter条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置连锁操作信息，指定召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果③的处理函数，选择并进行召唤
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足条件的怪兽
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		-- 执行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end

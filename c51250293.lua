--マジェスペクター・ウィンド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡也能把自己场上1只魔法师族·风属性怪兽解放来发动。
-- ①：从自己的手卡·墓地把1只「威风妖怪」怪兽特殊召唤。把怪兽解放来把这张卡发动的场合，也能作为代替从卡组把1只「威风妖怪」怪兽特殊召唤。
local s,id,o=GetID()
-- 创建效果，设置为自由连锁发动，限制每回合只能发动一次，设置消耗、目标和效果处理函数
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地把1只「威风妖怪」怪兽特殊召唤。把怪兽解放来把这张卡发动的场合，也能作为代替从卡组把1只「威风妖怪」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetLabel(0)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查场上是否存在满足条件的魔法师族·风属性怪兽
function s.cfilter(c,tp)
	-- 检查目标怪兽是否为魔法师族且风属性，并且场上存在可用怪兽区
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SPELLCASTER) and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤函数，用于筛选「威风妖怪」怪兽以供特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xd0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置发动时的消耗，判断是否需要解放怪兽并执行解放操作
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	-- 检查玩家场上是否有可用怪兽区
	local res=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌或墓地是否存在满足条件的「威风妖怪」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
	-- 检查玩家场上是否存在可解放的魔法师族·风属性怪兽
	if Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp)
		-- 询问玩家是否选择解放怪兽发动此卡，若选择则继续执行解放操作
		and (not res or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then  --"是否解放怪兽发动？"
		-- 提示玩家选择要解放的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 选择并返回一个满足条件的可解放怪兽组
		local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
		-- 将选中的怪兽进行解放处理
		Duel.Release(g,REASON_COST)
		e:SetLabel(LOCATION_DECK)
	end
end
-- 设置效果的目标，判断是否可以发动效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有可用怪兽区
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地是否存在「威风妖怪」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
		-- 检查是否已支付过消耗且为魔陷发动，并且场上有可解放的魔法师族·风属性怪兽
		or e:IsCostChecked() and e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp)
			-- 检查卡组中是否存在「威风妖怪」怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)) end
	if not e:IsCostChecked() then e:SetLabel(0) end
	-- 设置效果处理时的操作信息，包括特殊召唤的目标区域和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND+e:GetLabel())
end
-- 执行效果处理，选择并特殊召唤符合条件的怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌、墓地或卡组中选择一张满足条件的「威风妖怪」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND+e:GetLabel(),0,1,1,nil,e,tp)
	-- 将选中的怪兽特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end

--マジェスペクター・ウィンド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡也能把自己场上1只魔法师族·风属性怪兽解放来发动。
-- ①：从自己的手卡·墓地把1只「威风妖怪」怪兽特殊召唤。把怪兽解放来把这张卡发动的场合，也能作为代替从卡组把1只「威风妖怪」怪兽特殊召唤。
local s,id,o=GetID()
-- 定义初始化函数，创建并注册这张卡的魔法卡效果：使其可在自由时点发动，带有1回合1次的发动限制、可选择解放风属性魔法师族怪兽作为追加代价，并执行特殊召唤的处理。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。这张卡也能把自己场上1只魔法师族·风属性怪兽解放来发动。①：从自己的手卡·墓地把1只「威风妖怪」怪兽特殊召唤。把怪兽解放来把这张卡发动的场合，也能作为代替从卡组把1只「威风妖怪」怪兽特殊召唤。
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
-- 定义解放代价的过滤函数：选择可解放的怪兽，必须是风属性且魔法师族，并且将其解放后自己场上仍有可用的怪兽区。
function s.cfilter(c,tp)
	-- 作为过滤条件，检查目标是否为风属性·魔法师族怪兽，且解放后自己场上仍有空格子，以保证后续特殊召唤能够进行。
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SPELLCASTER) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义特殊召唤对象的过滤函数：必须是「威风妖怪」系列的怪兽，并且能被当前效果以通常方式特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xd0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义发动代价处理函数：无代价时检查通过；实际支付时先重置标签，再判断能否从手卡·墓地特殊召唤；若场上存在可解放的风属性魔法师族怪兽，且（无手卡·墓地目标或玩家选择解放），则解放1只并设置标签为卡组，表示可从卡组特殊召唤。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(0)
	-- 检查自己场上主要怪兽区是否有空位，以判断是否具备特殊召唤的基本条件。
	local res=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·墓地是否存在可特殊召唤的「威风妖怪」怪兽，作为非解放路线发动时的可能目标。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
	-- 检查自己场上是否存在满足解放条件的怪兽（风属性·魔法师族），以决定是否可以选择解放发动的路线。
	if Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp)
		-- 当存在可解放怪兽时，若当前不能从手卡·墓地特召或玩家选择是，则弹出询问框确认是否解放怪兽发动。
		and (not res or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then  --"是否解放怪兽发动？"
		-- 向玩家发送选择提示，要求选择要解放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 让玩家从自己场上选择1只满足条件的风属性·魔法师族怪兽作为解放代价。
		local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
		-- 将选择的怪兽解放，作为发动代价（REASON_COST），并因此允许本次效果改为从卡组特殊召唤。
		Duel.Release(g,REASON_COST)
		e:SetLabel(LOCATION_DECK)
	end
end
-- 定义发动目标条件判定：在发动时检查是否满足无解放路线（怪兽区有空位且手卡·墓地有可特召对象）或有解放路线（已确认解放代价且卡组有可特召对象）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件分支开始：若为发动时判定（chk==0），先确认自己怪兽区是否有空位，这是无解放路线的基本前提。
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己的手卡·墓地是否存在可特殊召唤的「威风妖怪」怪兽，以支持无解放发动。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
		-- 或者，若已经通过代价检查（选择了解放怪兽发动）且本效果是魔法卡发动，则检查场上是否有可解放的怪兽，用于确认解放路线的合法性。
		or e:IsCostChecked() and e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp)
			-- 并且检查卡组中是否存在可特殊召唤的「威风妖怪」怪兽，作为解放发动时需要从卡组特殊召唤的对象。
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)) end
	if not e:IsCostChecked() then e:SetLabel(0) end
	-- 设置本次连锁的操作信息：宣告将进行1只怪兽的特殊召唤，可能来源为手卡·墓地以及解放发动时追加的卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND+e:GetLabel())
end
-- 定义效果处理函数：在效果结算时，若怪兽区有空位，则提示玩家选择1只符合条件的「威风妖怪」怪兽（来源为手卡·墓地或卡组，取决于是否解放发动），并将其表侧表示特殊召唤到自己场上。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己怪兽区是否有空位，若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·墓地以及可能存在的卡组（由e:GetLabel决定）中选择1只满足「威风妖怪」系列且可特殊召唤的怪兽，并通过王家长眠之谷过滤器排除受影响者。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND+e:GetLabel(),0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧表示特殊召唤到自己场上，不检查召唤条件和苏生限制。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end

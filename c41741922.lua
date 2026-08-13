--ラヴァ・ドラゴン
-- 效果：
-- 把自己场上表侧守备表示存在的这张卡解放发动。从自己的手卡以及墓地各把1只3星以下的龙族怪兽特殊召唤。
function c41741922.initial_effect(c)
	-- 把自己场上表侧守备表示存在的这张卡解放发动。从自己的手卡以及墓地各把1只3星以下的龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41741922,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c41741922.spcost)
	e1:SetTarget(c41741922.sptg)
	e1:SetOperation(c41741922.spop)
	c:RegisterEffect(e1)
end
-- 代价判定：检查自己场上的这张卡是否表侧守备表示且可以解放；满足时以此卡的解放作为发动代价。
function c41741922.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDefensePos() and e:GetHandler():IsReleasable() end
	-- 以REASON_COST解放这张卡，作为发动代价且不检查其是否受其他效果影响。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选条件：等级3以下、种族为龙族且能够被当前效果特殊召唤的怪兽。
function c41741922.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件判定：确认『青眼精灵龙』的禁止效果未生效（即可同时特殊召唤2只以上怪兽）、自己主要怪兽区有空位，并且手牌和墓地各存在至少1只符合条件的龙族怪兽。
function c41741922.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认自己主要怪兽区存在至少1个可用空格，用于后续特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足筛选条件的龙族怪兽。
		and Duel.IsExistingMatchingCard(c41741922.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 检查墓地中是否存在至少1只满足筛选条件的龙族怪兽。
		and Duel.IsExistingMatchingCard(c41741922.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将进行2只怪兽的特殊召唤（位置来自手牌和墓地），供后续时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：若『青眼精灵龙』的禁止效果仍生效则直接失败；若自己主要怪兽区可用空格不足2个则失败；否则从手牌和墓地各选1只符合条件的龙族怪兽，合并后表侧表示特殊召唤。
function c41741922.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己主要怪兽区的可用空格数是否达到2，不足则无法同时特殊召唤2只怪兽。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取手牌中所有满足筛选条件的龙族怪兽作为候选组g1，供玩家选择1只。
	local g1=Duel.GetMatchingGroup(c41741922.filter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 获取墓地中满足筛选条件且不受王家长眠之谷影响的龙族怪兽作为候选组g2，供玩家选择1只。
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c41741922.filter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 在选择手牌怪兽前，向玩家发出“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=g1:Select(tp,1,1,nil)
	-- 在选择墓地怪兽前，向玩家发出“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	-- 将选出的手牌和墓地各1只龙族怪兽合并，以表侧表示特殊召唤到tp场上。
	Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
end

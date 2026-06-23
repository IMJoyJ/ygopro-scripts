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
-- 检查自身是否为守备表示且可被解放
function c41741922.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDefensePos() and e:GetHandler():IsReleasable() end
	-- 将自身解放作为效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤满足等级3以下、龙族且可特殊召唤的怪兽
function c41741922.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：未受青眼精灵龙效果影响、场上存在空位、手牌与墓地各存在一只符合条件的怪兽
function c41741922.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 判断场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c41741922.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 判断墓地中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c41741922.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的怪兽数量及来源
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行效果处理：检查是否受青眼精灵龙影响、判断场上空位是否足够、获取符合条件的怪兽组、选择并特殊召唤
function c41741922.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 判断场上是否至少有2个空怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 从手牌中获取符合条件的怪兽组
	local g1=Duel.GetMatchingGroup(c41741922.filter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 从墓地中获取符合条件的怪兽组（排除受王家长眠之谷影响的怪兽）
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c41741922.filter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg1=g1:Select(tp,1,1,nil)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	-- 将选择的怪兽特殊召唤到场上
	Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
end

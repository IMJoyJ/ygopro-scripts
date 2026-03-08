--ドラゴンを呼ぶ笛
-- 效果：
-- ①：从手卡把最多2只龙族怪兽特殊召唤。这个效果在场上有「龙之支配者」存在的场合才能发动和处理。
function c43973174.initial_effect(c)
	-- ①：从手卡把最多2只龙族怪兽特殊召唤。这个效果在场上有「龙之支配者」存在的场合才能发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c43973174.target)
	e1:SetOperation(c43973174.activate)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在表侧表示的「龙之支配者」
function c43973174.cfilter(c)
	return c:IsFaceup() and c:IsCode(17985575)
end
-- 检查手卡中是否存在龙族且可以特殊召唤的怪兽
function c43973174.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的条件判断
function c43973174.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上有无「龙之支配者」
		and Duel.IsExistingMatchingCard(c43973174.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 判断手卡中是否有龙族怪兽可以特殊召唤
		and Duel.IsExistingMatchingCard(c43973174.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时的执行函数
function c43973174.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 若场上没有「龙之支配者」则效果不成立
	if not Duel.IsExistingMatchingCard(c43973174.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的龙族怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c43973174.filter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

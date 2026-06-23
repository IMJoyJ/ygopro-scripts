--エクゾディアとの契約
-- 效果：
-- ①：自己墓地有「被封印的艾克佐迪亚」「被封印者的右腕」「被封印者的左腕」「被封印者的右足」「被封印者的左足」存在的场合才能发动。从手卡把1只「艾克佐迪亚的亡灵」特殊召唤。
function c33244944.initial_effect(c)
	-- 记录该卡具有「被封印的艾克佐迪亚」「被封印者的右腕」「被封印者的左腕」「被封印者的右足」「被封印者的左足」的卡名信息
	aux.AddCodeList(c,8124921,44519536,70903634,7902349,33396948)
	-- ①：自己墓地有「被封印的艾克佐迪亚」「被封印者的右腕」「被封印者的左腕」「被封印者的右足」「被封印者的左足」存在的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c33244944.condition)
	e1:SetTarget(c33244944.target)
	e1:SetOperation(c33244944.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件，即自己墓地同时存在「被封印的艾克佐迪亚」「被封印者的右腕」「被封印者的左腕」「被封印者的右足」「被封印者的左足」
function c33244944.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在「被封印的艾克佐迪亚」
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,8124921)
		-- 检查自己墓地是否存在「被封印者的右腕」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,44519536)
		-- 检查自己墓地是否存在「被封印者的左腕」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,70903634)
		-- 检查自己墓地是否存在「被封印者的右足」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,7902349)
		-- 检查自己墓地是否存在「被封印者的左足」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,33396948)
end
-- 定义用于筛选「艾克佐迪亚的亡灵」的过滤函数，确保该卡可以被特殊召唤
function c33244944.filter(c,e,tp)
	return c:IsCode(12600382) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 设置效果的目标处理，检查是否满足特殊召唤条件
function c33244944.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手牌中是否存在满足条件的「艾克佐迪亚的亡灵」
		and Duel.IsExistingMatchingCard(c33244944.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 设置效果的发动处理，执行特殊召唤操作
function c33244944.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有可用怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足条件的「艾克佐迪亚的亡灵」
	local tg=Duel.SelectMatchingCard(tp,c33244944.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if tg:GetCount()>0 then
		local tc=tg:GetFirst()
		-- 将选中的卡以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end

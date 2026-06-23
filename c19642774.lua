--フルール・シンクロン
-- 效果：
-- ①：这张卡作为同调素材送去墓地的场合才能发动。从手卡把1只2星以下的怪兽特殊召唤。
function c19642774.initial_effect(c)
	-- 创建效果，设置为单体诱发选发效果，当作为同调素材送去墓地时发动，效果描述为特殊召唤，分类为特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19642774,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c19642774.con)
	e1:SetTarget(c19642774.tg)
	e1:SetOperation(c19642774.op)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡在墓地且是因同调召唤被送去墓地
function c19642774.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤函数：选择手卡中等级为2或以下且可以特殊召唤的怪兽
function c19642774.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标设定：检查玩家手卡是否存在满足条件的怪兽且场上存在空位
function c19642774.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c19642774.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：确定将要特殊召唤1只手卡中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若场上存在空位则提示选择并特殊召唤手卡中符合条件的怪兽
function c19642774.op(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只手卡怪兽
	local g=Duel.SelectMatchingCard(tp,c19642774.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

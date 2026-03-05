--超戦士の儀式
-- 效果：
-- 「混沌战士」仪式怪兽的降临必需。「超战士的仪式」的②的效果1回合只能使用1次。
-- ①：从自己的手卡·场上把等级合计直到8的怪兽解放，从手卡把1只「混沌战士」仪式怪兽仪式召唤。
-- ②：从自己墓地把这张卡以及1只光属性怪兽和1只暗属性怪兽除外才能发动。从手卡把1只「混沌战士」仪式怪兽无视召唤条件特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c14094090.initial_effect(c)
	-- 为卡片添加仪式召唤效果，要求仪式怪兽的等级与解放的怪兽等级总和相等
	aux.AddRitualProcEqual(c,c14094090.ritual_filter)
	-- ②：从自己墓地把这张卡以及1只光属性怪兽和1只暗属性怪兽除外才能发动。从手卡把1只「混沌战士」仪式怪兽无视召唤条件特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,14094090)
	-- 设置效果的发动条件为：这张卡不在墓地的回合才能发动
	e1:SetCondition(aux.exccon)
	e1:SetCost(c14094090.spcost)
	e1:SetTarget(c14094090.sptg)
	e1:SetOperation(c14094090.spop)
	c:RegisterEffect(e1)
end
-- 定义仪式怪兽的过滤条件，必须是仪式类型且属于混沌战士系列
function c14094090.ritual_filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsSetCard(0x10cf)
end
-- 定义属性过滤函数，用于筛选满足属性要求的怪兽
function c14094090.cfilter(c,att)
	return c:IsAttribute(att) and c:IsAbleToRemoveAsCost()
end
-- 设置效果的发动费用，需要从墓地除外一张光属性和一张暗属性怪兽，以及自身
function c14094090.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查场上是否存在至少一张光属性的可除外怪兽
		and Duel.IsExistingMatchingCard(c14094090.cfilter,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_LIGHT)
		-- 检查场上是否存在至少一张暗属性的可除外怪兽
		and Duel.IsExistingMatchingCard(c14094090.cfilter,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_DARK) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择一张光属性的怪兽进行除外
	local g1=Duel.SelectMatchingCard(tp,c14094090.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,ATTRIBUTE_LIGHT)
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择一张暗属性的怪兽进行除外
	local g2=Duel.SelectMatchingCard(tp,c14094090.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,ATTRIBUTE_DARK)
	g1:Merge(g2)
	g1:AddCard(e:GetHandler())
	-- 将选中的怪兽从游戏中除外作为发动费用
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end
-- 定义特殊召唤的过滤条件，必须是混沌战士系列的仪式怪兽
function c14094090.spfilter(c,e,tp)
	return c:IsSetCard(0x10cf) and c:IsType(TYPE_RITUAL) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置效果的目标选择函数，检查是否有满足条件的怪兽可以特殊召唤
function c14094090.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，包括是否有足够的怪兽区域和手牌中是否有符合条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少一张符合条件的混沌战士仪式怪兽
		and Duel.IsExistingMatchingCard(c14094090.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 设置效果的发动后处理函数，执行特殊召唤操作
function c14094090.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从手牌中选择一张符合条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c14094090.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end

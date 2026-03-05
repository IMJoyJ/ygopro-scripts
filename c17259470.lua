--ゾンビ・マスター
-- 效果：
-- ①：1回合1次，从手卡把1只怪兽送去墓地，以自己或者对方的墓地1只4星以下的不死族怪兽为对象才能发动。那只不死族怪兽特殊召唤。这个效果在这张卡在怪兽区域表侧表示存在的场合才能发动和处理。
function c17259470.initial_effect(c)
	-- 效果原文内容：①：1回合1次，从手卡把1只怪兽送去墓地，以自己或者对方的墓地1只4星以下的不死族怪兽为对象才能发动。那只不死族怪兽特殊召唤。这个效果在这张卡在怪兽区域表侧表示存在的场合才能发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17259470,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c17259470.spcost)
	e1:SetTarget(c17259470.sptg)
	e1:SetOperation(c17259470.spop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的手卡怪兽组，用于支付效果的代价
function c17259470.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果作用：选择1只手卡怪兽送去墓地作为代价
function c17259470.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付代价的条件，即手卡是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c17259470.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1只满足条件的手卡怪兽
	local g=Duel.SelectMatchingCard(tp,c17259470.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡送去墓地作为效果的代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检索满足条件的墓地不死族怪兽组，用于特殊召唤
function c17259470.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：选择1只墓地的4星以下不死族怪兽作为特殊召唤对象
function c17259470.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c17259470.filter(chkc,e,tp) end
	-- 检查场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足条件的不死族怪兽
		and Duel.IsExistingTarget(c17259470.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只满足条件的墓地不死族怪兽作为目标
	local g=Duel.SelectTarget(tp,c17259470.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果处理时的操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：将目标不死族怪兽特殊召唤
function c17259470.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsRace(RACE_ZOMBIE) then
		-- 将目标怪兽以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

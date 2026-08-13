--正義の味方 カイバーマン
-- 效果：
-- 把这张卡解放才能发动。从手卡把1只「青眼白龙」特殊召唤。
function c34627841.initial_effect(c)
	-- 将卡号89631139（青眼白龙）登记到本卡的代码列表中，表示本卡效果中提及了该卡名，便于相关规则判定。
	aux.AddCodeList(c,89631139)
	-- 把这张卡解放才能发动。从手卡把1只「青眼白龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34627841,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c34627841.spcost)
	e1:SetTarget(c34627841.sptg)
	e1:SetOperation(c34627841.spop)
	c:RegisterEffect(e1)
end
-- 定义发动代价函数：在效果发动时检查并解放这张卡作为代价。
function c34627841.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以解放为代价，将效果持有者（这张卡）解放。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义筛选函数：检查卡是否为「青眼白龙」（89631139），且能够被当前效果合法特殊召唤。
function c34627841.filter(c,e,tp)
	return c:IsCode(89631139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动目标检查函数：若满足可发动条件（持有者可解放、有格子、手牌有目标）则允许发动，并设置特殊召唤的操作信息。
function c34627841.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否可能获得至少1个可用区域（通过解放自身后空出格子，因此> -1）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查我方手牌是否存在至少1张符合条件的「青眼白龙」，作为发动条件之一。
		and Duel.IsExistingMatchingCard(c34627841.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果操作信息，声明本次效果为特殊召唤，预计从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义效果处理函数：选择手牌中的1只「青眼白龙」并特殊召唤。
function c34627841.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时确认仍有可用怪兽区，否则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1张满足条件的「青眼白龙」。
	local g=Duel.SelectMatchingCard(tp,c34627841.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「青眼白龙」以表侧表示特殊召唤到控制者场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

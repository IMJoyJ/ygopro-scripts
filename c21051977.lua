--コロボックリ
-- 效果：
-- 自己的主要阶段时才能发动。从手卡把1只「松果小矮人」送去墓地，这张卡从手卡特殊召唤。
function c21051977.initial_effect(c)
	-- 创建效果并注册，设置效果描述为“特殊召唤”，分类为特殊召唤，类型为起动效果，发动位置为手卡，目标函数为sptg，运算函数为spop
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21051977,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c21051977.sptg)
	e1:SetOperation(c21051977.spop)
	c:RegisterEffect(e1)
end
-- 检查是否满足特殊召唤的条件，包括场上是否有空位、手卡是否有1只松果小矮人、此卡是否可以特殊召唤
function c21051977.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上主要怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡是否存在至少1张卡号为67445676（松果小矮人）的卡
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND,0,1,nil,67445676)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理效果的运算部分，包括提示选择送去墓地的卡、选择并送去墓地、检查此卡是否与效果相关、将此卡特殊召唤
function c21051977.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择手卡中1张卡号为67445676（松果小矮人）的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_HAND,0,1,1,nil,67445676)
	if g:GetCount()==0 then return end
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡从手卡特殊召唤到玩家场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

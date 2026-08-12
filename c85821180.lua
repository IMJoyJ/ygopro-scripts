--チューナーズ・ハイ
-- 效果：
-- ①：从手卡丢弃1只怪兽才能发动。和那只怪兽相同种族·属性而等级高1星的1只调整从卡组特殊召唤。
function c85821180.initial_effect(c)
	-- ①：从手卡丢弃1只怪兽才能发动。和那只怪兽相同种族·属性而等级高1星的1只调整从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCost(c85821180.cost)
	e1:SetTarget(c85821180.target)
	e1:SetOperation(c85821180.activate)
	c:RegisterEffect(e1)
end
-- 过滤手牌中可作为发动代价丢弃的怪兽（该怪兽必须能从卡组中检索到相同种族、属性且等级高1星的调整怪兽）
function c85821180.cfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
		-- 检查卡组中是否存在与该怪兽相同种族、属性且等级高1星的、可特殊召唤的调整怪兽
		and Duel.IsExistingMatchingCard(c85821180.filter,tp,LOCATION_DECK,0,1,nil,c:GetRace(),c:GetAttribute(),c:GetLevel()+1,e,tp)
end
-- 过滤卡组中满足特定种族、属性、等级且可以特殊召唤的调整怪兽
function c85821180.filter(c,race,att,lv,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsRace(race) and c:IsAttribute(att) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动代价处理函数，将Label设为100以标记进入了Cost检测流程
function c85821180.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 效果发动时的目标选择与代价支付处理
function c85821180.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 在发动条件检查时，确认是否通过了Cost检测标记，并检查己方场上是否有可用于特殊召唤的怪兽区域空位
		if e:GetLabel()~=100 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		-- 检查手牌中是否存在满足发动代价条件的怪兽
		return Duel.IsExistingMatchingCard(c85821180.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手牌选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c85821180.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetRace(),tc:GetAttribute(),tc:GetLevel())
	-- 将选择的怪兽作为发动代价丢弃送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
	-- 设置效果处理信息，声明该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（特殊召唤）的执行函数
function c85821180.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有可用于特殊召唤的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local race,att,lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只与丢弃怪兽相同种族、属性且等级高1星的调整怪兽
	local g=Duel.SelectMatchingCard(tp,c85821180.filter,tp,LOCATION_DECK,0,1,1,nil,race,att,lv+1,e,tp)
	if g:GetCount()>0 then
		-- 将选择的调整怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--ピラミッド・タートル
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只守备力2000以下的不死族怪兽特殊召唤。
function c77044671.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只守备力2000以下的不死族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77044671,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c77044671.condition)
	e1:SetTarget(c77044671.target)
	e1:SetOperation(c77044671.operation)
	c:RegisterEffect(e1)
end
-- 定义发动条件：自身因战斗破坏被送去墓地
function c77044671.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：守备力2000以下、不死族且可以特殊召唤的怪兽
function c77044671.filter(c,e,tp)
	return c:IsDefenseBelow(2000) and c:IsRace(RACE_ZOMBIE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果的目标：检查卡组中是否存在符合条件的怪兽，且己方场上有空余的怪兽区域
function c77044671.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c77044671.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 检查己方场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果的处理：若场上有空位，则从卡组选择1只符合条件的怪兽特殊召唤
function c77044671.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否仍有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c77044671.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

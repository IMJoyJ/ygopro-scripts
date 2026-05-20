--リトルトルーパー
-- 效果：
-- 这张卡被战斗破坏的场合，可以从卡组把1只2星以下的战士族怪兽里侧守备表示特殊召唤。
function c73702909.initial_effect(c)
	-- 这张卡被战斗破坏的场合，可以从卡组把1只2星以下的战士族怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73702909,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(c73702909.target)
	e1:SetOperation(c73702909.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中等级2以下、战士族、且能以里侧守备表示特殊召唤的怪兽
function c73702909.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果发动的目标检查，确认自身怪兽区域有空位且卡组中存在符合条件的怪兽
function c73702909.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身场上是否有可以特殊召唤怪兽的空余怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c73702909.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组选择1只符合条件的怪兽里侧守备表示特殊召唤，并给对方确认
function c73702909.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c73702909.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认特殊召唤的里侧表示怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end

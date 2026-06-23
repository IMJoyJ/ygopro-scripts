--アサルトワイバーン
-- 效果：
-- ①：这张卡战斗破坏对方怪兽时，把这张卡解放才能发动。从自己的手卡·墓地选「强袭翼龙」以外的1只龙族怪兽特殊召唤。
function c29311166.initial_effect(c)
	-- 创建效果，设置效果描述、分类、类型、时点、条件、费用、目标和效果处理
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29311166,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果的发动条件为：这张卡与对方怪兽战斗破坏对方怪兽时
	e1:SetCondition(aux.bdocon)
	e1:SetCost(c29311166.cost)
	e1:SetTarget(c29311166.target)
	e1:SetOperation(c29311166.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的龙族怪兽（非强袭翼龙）且可以特殊召唤
function c29311166.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and not c:IsCode(29311166) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 费用函数，检查是否可以解放此卡作为发动代价
function c29311166.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 实际执行解放此卡的操作
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 目标函数，检查是否满足特殊召唤条件（场上空间+存在符合条件的怪兽）
function c29311166.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查玩家手牌或墓地是否存在符合条件的龙族怪兽
		and Duel.IsExistingMatchingCard(c29311166.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理函数，检查场上空间并选择怪兽进行特殊召唤
function c29311166.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否还有空位进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只龙族怪兽（排除王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29311166.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

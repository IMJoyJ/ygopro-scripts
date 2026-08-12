--ヒーローアライブ
-- 效果：
-- ①：自己场上没有表侧表示怪兽存在的场合，把基本分支付一半才能发动。从卡组把1只4星以下的「元素英雄」怪兽特殊召唤。
function c8949584.initial_effect(c)
	-- ①：自己场上没有表侧表示怪兽存在的场合，把基本分支付一半才能发动。从卡组把1只4星以下的「元素英雄」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c8949584.condition)
	e1:SetCost(c8949584.cost)
	e1:SetTarget(c8949584.target)
	e1:SetOperation(c8949584.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查自己场上是否存在表侧表示怪兽
function c8949584.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在表侧表示的怪兽
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动代价：支付一半基本分
function c8949584.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 扣除玩家当前基本分一半的数值（向下取整）
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤条件：卡组中4星以下且可以特殊召唤的「元素英雄」怪兽
function c8949584.filter(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动准备：检查怪兽区域空位及卡组中是否存在可特召的怪兽，并设置操作信息
function c8949584.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c8949584.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组特殊召唤1只4星以下的「元素英雄」怪兽
function c8949584.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c8949584.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

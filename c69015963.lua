--デビル・フランケン
-- 效果：
-- ①：支付5000基本分才能发动。从额外卡组把1只融合怪兽攻击表示特殊召唤。
function c69015963.initial_effect(c)
	-- ①：支付5000基本分才能发动。从额外卡组把1只融合怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(69015963,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c69015963.cost)
	e1:SetTarget(c69015963.target)
	e1:SetOperation(c69015963.operation)
	c:RegisterEffect(e1)
end
-- 过滤额外卡组中可以攻击表示特殊召唤的融合怪兽的辅助函数
function c69015963.filter(c,e,tp)
	-- 检查卡片是否为融合怪兽、是否能以攻击表示特殊召唤，且额外卡组怪兽出场区域有空位
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 发动代价（Cost）处理函数
function c69015963.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付5000基本分
	if chk==0 then return Duel.CheckLPCost(tp,5000) end
	-- 扣除玩家5000基本分
	Duel.PayLPCost(tp,5000)
end
-- 效果发动目标（Target）处理函数
function c69015963.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只满足特殊召唤条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69015963.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理（Operation）函数
function c69015963.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c69015963.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end

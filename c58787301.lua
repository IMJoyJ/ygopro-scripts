--堕天使降臨
-- 效果：
-- ①：把基本分支付一半才能发动。选对方场上1只表侧表示怪兽，从自己墓地选和那只怪兽相同等级的最多2只「堕天使」怪兽守备表示特殊召唤。
function c58787301.initial_effect(c)
	-- ①：把基本分支付一半才能发动。选对方场上1只表侧表示怪兽，从自己墓地选和那只怪兽相同等级的最多2只「堕天使」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c58787301.cost)
	e1:SetTarget(c58787301.target)
	e1:SetOperation(c58787301.activate)
	c:RegisterEffect(e1)
end
-- 定义发动成本，检查并执行支付一半基本分
function c58787301.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半的当前基本分
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤对方场上表侧表示、有等级，且自己墓地有相同等级「堕天使」怪兽的怪兽
function c58787301.cfilter(c,e,tp)
	return c:IsFaceup() and c:GetLevel()>0
		-- 检查自己墓地是否存在至少1只与该怪兽等级相同的「堕天使」怪兽
		and Duel.IsExistingMatchingCard(c58787301.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel())
end
-- 过滤自己墓地中等级为指定值、可以守备表示特殊召唤的「堕天使」怪兽
function c58787301.spfilter(c,e,tp,lv)
	return c:IsSetCard(0xef) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义效果发动的合法性检测与操作信息注册
function c58787301.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否有至少1个空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动时，检查对方场上是否存在满足条件的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c58787301.cfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表明将从墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 定义效果处理的逻辑，选择对方怪兽并特殊召唤自己墓地相同等级的「堕天使」怪兽
function c58787301.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算当前可特殊召唤的最大数量（不超过空余怪兽区域且最多2只）
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择对方场上的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 让玩家选择对方场上1只满足条件的表侧表示怪兽
	local g=Duel.SelectMatchingCard(tp,c58787301.cfilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 为选中的对方怪兽显示选中动画
		Duel.HintSelection(g)
		local lv=g:GetFirst():GetLevel()
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己墓地选择最多ft只与所选怪兽等级相同的「堕天使」怪兽
		local sg=Duel.SelectMatchingCard(tp,c58787301.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp,lv)
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

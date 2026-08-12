--救魔の奇石
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示怪兽或者自己墓地1只怪兽除外才能把这张卡发动。这张卡发动后变成持有和除外的怪兽的原本等级相同等级的通常怪兽（魔法师族·光·攻/守0）在怪兽区域特殊召唤。这张卡也当作陷阱卡使用。
function c46984349.initial_effect(c)
	-- 创建效果，设置为陷阱卡发动效果，可以自由连锁，一回合只能发动一次，需要支付除外怪兽的费用，效果处理时特殊召唤自身
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,46984349+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c46984349.cost)
	e1:SetTarget(c46984349.target)
	e1:SetOperation(c46984349.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上或墓地的怪兽是否满足除外作为发动代价的条件
function c46984349.costfilter(c,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1) and c:IsAbleToRemoveAsCost()
		-- 确保玩家场上存在可用怪兽区域，并且可以特殊召唤指定等级的陷阱怪兽
		and Duel.GetMZoneCount(tp,c)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,46984349,0,TYPES_NORMAL_TRAP_MONSTER,0,0,c:GetOriginalLevel(),RACE_SPELLCASTER,ATTRIBUTE_LIGHT)
end
-- 发动时选择除外1只怪兽作为代价，将该怪兽除外并记录其原本等级
function c46984349.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足除外条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c46984349.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张怪兽卡
	local g=Duel.SelectMatchingCard(tp,c46984349.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选中的怪兽除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
end
-- 设置效果处理时的目标为自身，准备特殊召唤
function c46984349.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置连锁操作信息，表示将特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将自身变成指定等级的陷阱怪兽并特殊召唤
function c46984349.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	-- 检查是否可以特殊召唤该陷阱怪兽
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,46984349,0,TYPES_NORMAL_TRAP_MONSTER,0,0,lv,RACE_SPELLCASTER,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP,0,0,lv,0,0)
	-- 将自身以陷阱怪兽形式特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end

--レクンガ
-- 效果：
-- 从自己墓地里除外2只水属性怪兽，在自己场上以攻击表示特殊召唤1只「裂蕈牙衍生物」（水·2星·植物族·攻/守700）。
function c62543393.initial_effect(c)
	-- 从自己墓地里除外2只水属性怪兽，在自己场上以攻击表示特殊召唤1只「裂蕈牙衍生物」（水·2星·植物族·攻/守700）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62543393,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c62543393.cost)
	e1:SetTarget(c62543393.target)
	e1:SetOperation(c62543393.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地的水属性且可以作为代价值除外的怪兽
function c62543393.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动代价：从自己墓地除外2只水属性怪兽
function c62543393.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少2只满足过滤条件的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c62543393.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2只满足过滤条件的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c62543393.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动目标：检查是否可以特殊召唤衍生物，并设置操作信息
function c62543393.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的「裂蕈牙衍生物」（水属性·2星·植物族·攻/守700·表侧攻击表示）
		and Duel.IsPlayerCanSpecialSummonMonster(tp,62543394,0,TYPES_TOKEN_MONSTER,700,700,2,RACE_PLANT,ATTRIBUTE_WATER,POS_FACEUP_ATTACK) end
	-- 设置当前连锁的操作信息为：产生1张衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置当前连锁的操作信息为：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：在自己场上特殊召唤1只「裂蕈牙衍生物」
function c62543393.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否仍能特殊召唤指定的「裂蕈牙衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,62543394,0,TYPES_TOKEN_MONSTER,700,700,2,RACE_PLANT,ATTRIBUTE_WATER,POS_FACEUP_ATTACK) then
		-- 创建「裂蕈牙衍生物」的卡片数据
		local token=Duel.CreateToken(tp,62543394)
		-- 将创建的衍生物以表侧攻击表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end

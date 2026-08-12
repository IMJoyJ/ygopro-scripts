--フュージョン・ガード
-- 效果：
-- 给与伤害的效果发动时才能发动。那个发动和效果无效，从自己融合卡组随机把1只融合怪兽送去墓地。
function c73026394.initial_effect(c)
	-- 给与伤害的效果发动时才能发动。那个发动和效果无效，从自己融合卡组随机把1只融合怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c73026394.condition)
	e1:SetTarget(c73026394.target)
	e1:SetOperation(c73026394.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件：检查触发连锁是否为给与伤害的效果，且该连锁的发动能否被无效
function c73026394.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发连锁的操作信息，检查其是否包含给与伤害的分类
	local ex=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	-- 返回是否满足：含有伤害分类、由怪兽效果或魔陷卡发动引起、且该连锁的发动可以被无效
	return ex and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 过滤条件：属于融合怪兽且可以送去墓地的卡
function c73026394.filter(c)
	return c:IsType(TYPE_FUSION) and c:IsAbleToGrave()
end
-- 定义效果的目标：检查额外卡组是否有可送去墓地的融合怪兽，并设置无效发动和送去墓地的操作信息
function c73026394.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己额外卡组是否存在至少1只可以送去墓地的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c73026394.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息：将自己额外卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 定义效果的处理：使发动无效，并洗切额外卡组后随机将1只融合怪兽送去墓地
function c73026394.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效
	Duel.NegateActivation(ev)
	-- 洗切自己的额外卡组
	Duel.ShuffleExtra(tp)
	-- 从自己额外卡组中筛选出符合条件的融合怪兽并随机选择1张
	local g=Duel.GetMatchingGroup(c73026394.filter,tp,LOCATION_EXTRA,0,nil):RandomSelect(tp,1)
	-- 将选择的融合怪兽因效果送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end

--アビストローム
-- 效果：
-- 把自己场上表侧表示存在的「海」送去墓地才能发动。场上的魔法·陷阱卡全部送去墓地。
function c97697447.initial_effect(c)
	-- 注册卡片密码，表示这张卡的效果记有「海」的卡名
	aux.AddCodeList(c,22702055)
	-- 把自己场上表侧表示存在的「海」送去墓地才能发动。场上的魔法·陷阱卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c97697447.cost)
	e1:SetTarget(c97697447.target)
	e1:SetOperation(c97697447.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示存在的「海」
function c97697447.cfilter(c)
	return c:IsFaceup() and c:IsCode(22702055)
end
-- 发动代价（Cost）处理：将自己场上表侧表示存在的「海」送去墓地
function c97697447.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 获取自己场上所有表侧表示的「海」
	local g=Duel.GetMatchingGroup(c97697447.cfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return g:GetCount()>0 and g:FilterCount(Card.IsAbleToGraveAsCost,nil)==g:GetCount() end
	-- 将作为代价的「海」送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：场上的魔法·陷阱卡（排除作为发动代价送去墓地的「海」）
function c97697447.filter(c,tp)
	return (c:IsFacedown() or c:IsControler(1-tp) or not c:IsCode(22702055)) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的目标选择与检测（Target）处理
function c97697447.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then
			-- 检查场上是否存在除这张卡以外的魔法·陷阱卡（不考虑Cost时的检测）
			return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
		end
		e:SetLabel(0)
		-- 检查场上是否存在除这张卡和作为Cost送去墓地的「海」以外的魔法·陷阱卡（考虑Cost时的检测）
		return Duel.IsExistingMatchingCard(c97697447.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),tp)
	end
	e:SetLabel(0)
	-- 获取场上除这张卡以外的所有魔法·陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),TYPE_SPELL+TYPE_TRAP)
	-- 设置连锁信息，表示该效果的操作为将场上的魔法·陷阱卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果处理（Operation）阶段：将场上的魔法·陷阱卡全部送去墓地
function c97697447.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡以外的所有魔法·陷阱卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e),TYPE_SPELL+TYPE_TRAP)
	-- 将获取到的魔法·陷阱卡全部送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end

--騎士皇爆誕
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：怪兽的效果·魔法·陷阱卡发动时，把自己的魔法与陷阱区域1张表侧表示的怪兽卡送去墓地才能发动。那个发动无效并破坏。
local s,id,o=GetID()
-- 注册卡片发动时的效果：无效发动并破坏
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：怪兽的效果·魔法·陷阱卡发动时，把自己的魔法与陷阱区域1张表侧表示的怪兽卡送去墓地才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件：怪兽效果或魔法·陷阱卡的发动，且该发动可以被无效
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 触发连锁的效果是魔法·陷阱卡的发动或怪兽效果的发动，且该发动可以被无效
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)) and Duel.IsChainNegatable(ev)
end
-- 过滤条件：自己魔陷区（不含场地区）表侧表示的原本是怪兽的卡，且能作为代价送去墓地
function s.filter(c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER>0 and c:GetSequence()<5 and c:IsAbleToGraveAsCost()
end
-- 发动代价：将自己魔法与陷阱区域1张表侧表示的怪兽卡送去墓地
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否存在至少1张满足过滤条件的表侧表示怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选中的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果目标：确认发动无效与破坏的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：使发动无效并破坏
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功使该发动无效，且该卡仍存在于原区域，则将其破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then Duel.Destroy(eg,REASON_EFFECT) end
end

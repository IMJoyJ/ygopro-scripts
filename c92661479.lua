--フォトン・ストリーク・バウンサー
-- 效果：
-- 6星怪兽×2
-- 对方场上效果怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个效果无效，给与对方基本分1000分伤害。这个效果1回合只能使用1次。
function c92661479.initial_effect(c)
	-- 添加超量召唤手续：需要2只6星怪兽
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- 对方场上效果怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个效果无效，给与对方基本分1000分伤害。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92661479,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c92661479.condition)
	e1:SetCost(c92661479.cost)
	e1:SetTarget(c92661479.target)
	e1:SetOperation(c92661479.operation)
	c:RegisterEffect(e1)
end
-- 判断发动条件：此卡未被战斗破坏，且对方在怪兽区域发动了可被无效的怪兽效果
function c92661479.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前触发连锁的效果的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
		-- 判断效果发动位置是否在怪兽区域，且发动的效果属于怪兽卡，且该效果可以被无效
		and loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 发动代价：取除这张卡的1个超量素材
function c92661479.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果处理的目标信息：无效该效果并给与对方1000分伤害
function c92661479.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：包含使该效果无效的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	-- 设置操作信息：包含给与对方1000分伤害的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果处理：使该效果无效，并给与对方1000分伤害
function c92661479.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该连锁的效果无效
	if Duel.NegateEffect(ev) then
		-- 给与对方1000分效果伤害
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end

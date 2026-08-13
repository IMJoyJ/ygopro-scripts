--No.65 裁断魔人ジャッジ・バスター
-- 效果：
-- 暗属性2星怪兽×2
-- ①：对方把怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个发动无效，给与对方500伤害。
function c3790062.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以2只暗属性2星怪兽作为素材进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),2,2)
	c:EnableReviveLimit()
	-- ①：对方把怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个发动无效，给与对方500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3790062,0))  --"发动无效并伤害"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c3790062.condition)
	e1:SetCost(c3790062.cost)
	e1:SetTarget(c3790062.target)
	e1:SetOperation(c3790062.operation)
	c:RegisterEffect(e1)
end
-- 将该卡登录为No.65编号，用于No.相关效果判定。
aux.xyz_number[3790062]=65
-- 该效果的发动条件：仅在对方发动怪兽效果、此卡未被战斗破坏确定、且该连锁可被无效时满足。
function c3790062.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 并且对方发动的效果为怪兽效果，且该连锁可以被无效。
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 发动代价：取除这张卡的2个超量素材作为COST。
function c3790062.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果发动时设定处理信息：声明要将对方发动的那个效果无效，并设定给予对方500伤害的操作信息。
function c3790062.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本效果包含无效对方效果的处理，对象为正在发动的对方效果。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息：本效果包含给予对方500点伤害的处理。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理：先无效对方发动的效果，若无效成功则给予对方500伤害。
function c3790062.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效对方发动的那个连锁，并判断是否无效成功。
	if Duel.NegateActivation(ev) then
		-- 给予对方玩家500点效果伤害。
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end

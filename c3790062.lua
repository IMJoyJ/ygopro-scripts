--No.65 裁断魔人ジャッジ・バスター
-- 效果：
-- 暗属性2星怪兽×2
-- ①：对方把怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个发动无效，给与对方500伤害。
function c3790062.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足暗属性条件的2星怪兽作为素材进行召唤
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
-- 设置该卡的XYZ编号为65
aux.xyz_number[3790062]=65
-- 效果发动时的条件判断，确保是对方怪兽效果发动且连锁可无效
function c3790062.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 确保连锁发动的是怪兽类型且可以被无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 支付效果的代价，移除自身2个超量素材
function c3790062.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 设置效果处理时的操作信息，包括使发动无效和造成伤害
function c3790062.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使连锁发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置给与对方500伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理时执行的操作，先尝试使连锁无效再造成伤害
function c3790062.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使连锁发动无效，若成功则继续执行后续操作
	if Duel.NegateActivation(ev) then
		-- 对对方造成500点伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end

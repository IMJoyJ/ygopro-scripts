--No.68 魔天牢サンダルフォン
-- 效果：
-- 8星怪兽×2
-- ①：这张卡的攻击力·守备力上升双方墓地的怪兽数量×100。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。直到对方回合结束时，这张卡不会被效果破坏，双方不能把墓地的怪兽特殊召唤。
function c23085002.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用8星怪兽2只作为素材
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力·守备力上升双方墓地的怪兽数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c23085002.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。直到对方回合结束时，这张卡不会被效果破坏，双方不能把墓地的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23085002,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c23085002.cost)
	e3:SetOperation(c23085002.operation)
	c:RegisterEffect(e3)
end
-- 设置该卡的XYZ编号为68
aux.xyz_number[23085002]=68
-- 计算双方墓地怪兽数量并乘以100作为攻击力和守备力的增加量
function c23085002.value(e,c)
	-- 检索双方墓地中怪兽卡的数量并乘以100
	return Duel.GetMatchingGroupCount(Card.IsType,0,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_MONSTER)*100
end
-- 支付1个超量素材作为发动代价
function c23085002.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动效果时，使自身在对方回合结束前不会被效果破坏，并禁止双方将墓地怪兽特殊召唤
function c23085002.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 直到对方回合结束时，这张卡不会被效果破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
	end
	-- 双方不能把墓地的怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(c23085002.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 限制墓地中的怪兽不能被特殊召唤
function c23085002.splimit(e,c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)
end

--オイスターマイスター
-- 效果：
-- 这张卡被战斗破坏以外的方法从场上送去墓地时，在自己场上把1只「牡蛎衍生物」（水·1星·鱼族·攻/守0）特殊召唤。
function c83239739.initial_effect(c)
	-- 这张卡被战斗破坏以外的方法从场上送去墓地时，在自己场上把1只「牡蛎衍生物」（水·1星·鱼族·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83239739,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c83239739.condition)
	e1:SetTarget(c83239739.target)
	e1:SetOperation(c83239739.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否从场上送去墓地，且送去墓地的原因不是战斗破坏（即战斗破坏以外的方法）。
function c83239739.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and not (bit.band(r,REASON_BATTLE+REASON_DESTROY)==REASON_BATTLE+REASON_DESTROY)
end
-- 效果发动的目标处理，因为是必发效果，直接返回true，并设置产生衍生物和特殊召唤的操作信息。
function c83239739.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果包含产生1只衍生物的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，表示该效果包含特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理的执行函数，在自己场上特殊召唤1只「牡蛎衍生物」。
function c83239739.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否有空位，若没有则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 检查玩家是否可以特殊召唤特定属性、种族、攻守和等级的衍生物怪兽，若不能则不处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,83239740,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FISH,ATTRIBUTE_WATER) then return end
	-- 在卡片数据库中创建「牡蛎衍生物」的卡片实例。
	local token=Duel.CreateToken(tp,83239740)
	-- 将创建的衍生物以表侧表示特殊召唤到自己的场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end

--ヴォルカニック・カウンター
-- 效果：
-- 自己受到战斗伤害时，墓地存在的这张卡从游戏中除外。那个时候，自己墓地有「火山反击兽」以外的炎属性怪兽存在的场合，给与对方基本分和自己受到的战斗伤害相同的伤害。
function c66436257.initial_effect(c)
	-- 自己受到战斗伤害时，墓地存在的这张卡从游戏中除外。那个时候，自己墓地有「火山反击兽」以外的炎属性怪兽存在的场合，给与对方基本分和自己受到的战斗伤害相同的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66436257,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c66436257.condition)
	e1:SetTarget(c66436257.target)
	e1:SetOperation(c66436257.operation)
	c:RegisterEffect(e1)
end
-- 检查受到战斗伤害的玩家是否为自己
function c66436257.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 效果发动的目标处理，作为必发效果直接返回true，并设置除外自身的操作信息
function c66436257.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为将自己墓地的这张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 过滤出「火山反击兽」以外的炎属性怪兽
function c66436257.filter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsCode(66436257)
end
-- 效果处理，将自身除外，若成功且自己墓地存在其他炎属性怪兽，则给与对方与自己受到的战斗伤害相同数值的伤害
function c66436257.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡表侧表示除外，并检查是否除外成功
	if Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)~=0
		-- 检查自己墓地是否存在至少1张「火山反击兽」以外的炎属性怪兽
		and Duel.IsExistingMatchingCard(c66436257.filter,tp,LOCATION_GRAVE,0,1,nil) then
		-- 给与对方玩家与自己受到的战斗伤害相同数值的伤害
		Duel.Damage(1-tp,ev,REASON_EFFECT)
	end
end

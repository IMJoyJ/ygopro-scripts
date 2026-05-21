--大火葬
-- 效果：
-- 当对方发动以墓地里的怪兽卡为对象的卡时这张卡才能发动。将双方墓地里的怪兽卡全部除外。
function c95472621.initial_effect(c)
	-- 当对方发动以墓地里的怪兽卡为对象的卡时这张卡才能发动。将双方墓地里的怪兽卡全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetCondition(c95472621.condition)
	e1:SetTarget(c95472621.target)
	e1:SetOperation(c95472621.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：位于墓地且是怪兽卡
function c95472621.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)
end
-- 发动条件：对方发动怪兽效果或魔法·陷阱卡，且该效果的对象中存在至少1张墓地里的怪兽卡
function c95472621.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and eg:IsExists(c95472621.cfilter,1,nil)
end
-- 过滤条件：墓地中的怪兽卡，且不能被除外
function c95472621.chkfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsAbleToRemove()
end
-- 过滤条件：墓地中的怪兽卡，且可以被除外
function c95472621.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果的目标处理：检查双方墓地是否存在可除外的怪兽，且不存在不能除外的怪兽，并设置除外的操作信息
function c95472621.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查双方墓地是否存在至少1张可以除外的怪兽卡
		return Duel.IsExistingMatchingCard(c95472621.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
			-- 并且双方墓地中不能存在无法被除外的怪兽卡（确保能除外全部墓地怪兽）
			and not Duel.IsExistingMatchingCard(c95472621.chkfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
	end
	-- 获取双方墓地中所有可以除外的怪兽卡
	local g=Duel.GetMatchingGroup(c95472621.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 设置操作信息：除外双方墓地的所有怪兽卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理的执行：获取双方墓地中所有可以除外的怪兽卡，并将其全部表侧表示除外
function c95472621.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方墓地中所有可以除外的怪兽卡
	local g=Duel.GetMatchingGroup(c95472621.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 将获取到的双方墓地怪兽卡全部表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end

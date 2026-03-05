--ヘル・テンペスト
-- 效果：
-- ①：自己受到3000以上的战斗伤害时才能发动。双方的卡组·墓地的怪兽全部除外。
function c14391920.initial_effect(c)
	-- 效果原文内容：①：自己受到3000以上的战斗伤害时才能发动。双方的卡组·墓地的怪兽全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c14391920.condition)
	e1:SetTarget(c14391920.target)
	e1:SetOperation(c14391920.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断是否为发动此卡的玩家受到的战斗伤害且伤害值大于等于3000
function c14391920.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and ev>=3000
end
-- 规则层面作用：过滤函数，用于检查卡组或墓地中的怪兽是否无法被除外
function c14391920.chkfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsAbleToRemove()
end
-- 规则层面作用：过滤函数，用于检查卡组或墓地中的怪兽是否可以被除外
function c14391920.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 规则层面作用：设置连锁处理的目标，检查是否满足发动条件并设置操作信息
function c14391920.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 规则层面作用：检查自己卡组与墓地是否存在至少一张可除外的怪兽
		return Duel.IsExistingMatchingCard(c14391920.filter,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
			-- 规则层面作用：确保自己卡组与墓地中没有无法被除外的怪兽
			and not Duel.IsExistingMatchingCard(c14391920.chkfilter,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
	end
	-- 规则层面作用：设置当前连锁处理的操作信息为除外效果，目标为双方卡组与墓地的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 规则层面作用：设置连锁发动后的处理函数，执行除外操作
function c14391920.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取满足条件的卡组与墓地中的所有怪兽组成集合
	local sg=Duel.GetMatchingGroup(c14391920.filter,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_DECK+LOCATION_GRAVE,nil)
	-- 规则层面作用：以效果原因将上述集合中的所有怪兽除外
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end

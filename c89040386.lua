--BF－バックフラッシュ
-- 效果：
-- 自己墓地有名字带有「黑羽」的怪兽5只以上存在的场合，对方怪兽的直接攻击宣言时才能发动。对方场上存在的怪兽全部破坏。
function c89040386.initial_effect(c)
	-- 自己墓地有名字带有「黑羽」的怪兽5只以上存在的场合，对方怪兽的直接攻击宣言时才能发动。对方场上存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c89040386.condition)
	e1:SetTarget(c89040386.target)
	e1:SetOperation(c89040386.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地中名字带有「黑羽」的怪兽
function c89040386.cfilter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER)
end
-- 发动条件：对方怪兽直接攻击宣言时，且自己墓地存在5只以上「黑羽」怪兽
function c89040386.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合（非自己回合）且攻击对象为空（即直接攻击）
	return tp~=Duel.GetTurnPlayer() and Duel.GetAttackTarget()==nil
		-- 检查自己墓地是否存在5只以上名字带有「黑羽」的怪兽
		and Duel.IsExistingMatchingCard(c89040386.cfilter,tp,LOCATION_GRAVE,0,5,nil)
end
-- 效果发动时的目标选择与处理：检查对方场上是否存在怪兽，并设置破坏操作信息
function c89040386.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏操作信息，包含要破坏的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：获取并破坏对方场上的所有怪兽
function c89040386.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 因效果破坏获取到的怪兽组
		Duel.Destroy(g,REASON_EFFECT)
	end
end

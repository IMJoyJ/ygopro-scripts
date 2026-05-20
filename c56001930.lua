--怪蹴一色
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：只让怪兽1只召唤·特殊召唤时才能发动。持有比那只怪兽低的攻击力的场上的怪兽全部破坏。
function c56001930.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：只让怪兽1只召唤·特殊召唤时才能发动。持有比那只怪兽低的攻击力的场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,56001930+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c56001930.condition)
	e1:SetTarget(c56001930.target)
	e1:SetOperation(c56001930.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 检查是否仅有1只怪兽表侧表示召唤成功，作为效果发动的条件
function c56001930.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:GetFirst():IsFaceup()
end
-- 过滤场上表侧表示且攻击力低于指定数值的怪兽
function c56001930.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 效果发动的靶向处理，确认是否存在可破坏的怪兽，并建立与召唤怪兽的联系，设置破坏的操作信息
function c56001930.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	local atk=tc:GetAttack()
	-- 在发动阶段，检查场上是否存在至少1只攻击力低于该召唤怪兽的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56001930.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,atk) end
	tc:CreateEffectRelation(e)
	-- 获取场上所有攻击力低于该召唤怪兽的表侧表示怪兽组
	local g=Duel.GetMatchingGroup(c56001930.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,atk)
	-- 设置连锁处理的操作信息，表明此效果将破坏上述获取的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理，若召唤的怪兽仍表侧表示存在且与效果有联系，则破坏场上所有攻击力比其低的怪兽
function c56001930.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 在效果处理时，获取场上所有攻击力低于该召唤怪兽当前攻击力的表侧表示怪兽组
		local g=Duel.GetMatchingGroup(c56001930.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc:GetAttack())
		if g:GetCount()>0 then
			-- 将满足条件的怪兽全部因效果破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

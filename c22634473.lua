--対峙する宿命
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「青眼白龙」或「黑魔术师」存在的场合才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
function c22634473.initial_effect(c)
	-- 记录该卡牌效果中涉及的「青眼白龙」和「黑魔术师」的卡片密码
	aux.AddCodeList(c,89631139,46986414)
	-- ①：自己场上有「青眼白龙」或「黑魔术师」存在的场合才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22634473+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c22634473.condition)
	e1:SetTarget(c22634473.target)
	e1:SetOperation(c22634473.activate)
	c:RegisterEffect(e1)
end
-- 定义用于筛选场上的「青眼白龙」或「黑魔术师」的过滤函数
function c22634473.cfilter(c)
	return c:IsFaceup() and c:IsCode(89631139,46986414)
end
-- 判断自己场上有「青眼白龙」或「黑魔术师」存在的条件函数
function c22634473.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场地上是否存在至少1张「青眼白龙」或「黑魔术师」
	return Duel.IsExistingMatchingCard(c22634473.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置发动时的目标选择逻辑，确认对方场上存在可被无效化的怪兽
function c22634473.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张可被无效化的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有可被无效化的怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，指定本次效果将使对方怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 设置效果发动后的处理逻辑，对对方场上所有怪兽施加效果无效化
function c22634473.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可被无效化的怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使目标怪兽相关的连锁效果无效化并重置
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果无效化效果在回合结束时解除
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end

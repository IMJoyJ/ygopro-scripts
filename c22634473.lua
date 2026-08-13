--対峙する宿命
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「青眼白龙」或「黑魔术师」存在的场合才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
function c22634473.initial_effect(c)
	-- 记录这张卡上记载了「青眼白龙」（89631139）和「黑魔术师」（46986414）的卡名，用于相关联动判定。
	aux.AddCodeList(c,89631139,46986414)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「青眼白龙」或「黑魔术师」存在的场合才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效化。
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
-- 定义筛选函数：判断怪兽是否为表侧表示且卡名为「青眼白龙」（89631139）或「黑魔术师」（46986414）。
function c22634473.cfilter(c)
	return c:IsFaceup() and c:IsCode(89631139,46986414)
end
-- 定义发动条件函数：检查自己场上是否存在至少1张满足cfilter的「青眼白龙」或「黑魔术师」。
function c22634473.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 执行条件判定：以自己方视角检索自己场上（LOCATION_ONFIELD）至少1张满足cfilter的卡，存在则条件成立。
	return Duel.IsExistingMatchingCard(c22634473.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义发动时目标选择与信息设置函数：检查对方场上存在可无效的表侧效果怪兽，并获取所有此类怪兽，设定本次处理将无效它们的效果。
function c22634473.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认对方场上存在至少1只满足aux.NegateMonsterFilter（表侧且可被无效）的效果怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有满足aux.NegateMonsterFilter的怪兽群组，作为无效化处理的对象集合。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	-- 将本次连锁的操作信息登记为：对g中的所有卡执行CATEGORY_DISABLE（效果无效），数量为g中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 定义效果处理函数：处理时重新获取对方场上所有可无效的表侧效果怪兽，对每只怪兽将其效果无效，并让该无效状态持续到回合结束，同时使相关连锁无效化。
function c22634473.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时再次获取对方场上全部可被无效的表侧效果怪兽，以处理时场上存在的怪兽为准。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使与这只怪兽相关的连锁（已发动效果）无效化，并在该怪兽变里侧时重置此无效状态（RESET_TURN_SET）。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对方场上的全部表侧表示怪兽的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 直到回合结束时无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end

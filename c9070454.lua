--龍皇の波動
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方把场上的怪兽的效果发动时才能发动。那个发动无效并破坏。那之后，以下效果可以适用。
-- ●从自己手卡选1只怪兽除外，这个效果破坏送去墓地的怪兽效果无效在自己场上特殊召唤。
function c9070454.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方把场上的怪兽的效果发动时才能发动。那个发动无效并破坏。那之后，以下效果可以适用。●从自己手卡选1只怪兽除外，这个效果破坏送去墓地的怪兽效果无效在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,9070454+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c9070454.condition)
	e1:SetTarget(c9070454.target)
	e1:SetOperation(c9070454.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c9070454.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方在场上发动的怪兽效果，且该发动可以被无效
	return ep==1-tp and re:GetActivateLocation()==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 定义发动准备（效果处理确定）函数
function c9070454.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若怪兽在场且可破坏，设置操作信息：破坏该怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 过滤手牌中可以除外的怪兽卡
function c9070454.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 定义效果处理函数
function c9070454.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 若成功使发动无效，且该卡在场，则将其破坏
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		-- 获取自己手牌中可以除外的怪兽组
		local g=Duel.GetMatchingGroup(c9070454.filter,tp,LOCATION_HAND,0,nil)
		-- 若手牌有可除外的怪兽，且被破坏的卡是怪兽并已送去墓地（受王家之谷影响）
		if g:GetCount()>0 and rc:IsType(TYPE_MONSTER) and rc:IsLocation(LOCATION_GRAVE) and aux.NecroValleyFilter()(rc)
			-- 且自己场上有空余怪兽区域，且该怪兽可以特殊召唤
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and rc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 询问玩家是否选择适用后续效果
			and Duel.SelectYesNo(tp,aux.Stringid(9070454,0)) then  --"是否把那只怪兽特殊召唤？"
			-- 中断当前效果，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 若成功将选中的手牌怪兽表侧表示除外
			if sg:GetCount()>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 and sg:GetFirst():IsLocation(LOCATION_REMOVED) then
				-- 将该墓地怪兽在自己场上表侧表示特殊召唤（分步处理）
				Duel.SpecialSummonStep(rc,0,tp,tp,false,false,POS_FACEUP)
				-- 效果无效
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				rc:RegisterEffect(e1)
				-- 效果无效
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetValue(RESET_TURN_SET)
				rc:RegisterEffect(e2)
				-- 完成特殊召唤的最终处理
				Duel.SpecialSummonComplete()
			end
		end
	end
end

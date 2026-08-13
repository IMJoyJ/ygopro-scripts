--神の氷結
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：场上有水属性怪兽2只以上存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽不能攻击，效果无效化。
-- ②：这张卡在墓地存在的状态，自己场上有5星以上的水属性怪兽召唤·特殊召唤的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c22748199.initial_effect(c)
	-- ①：场上有水属性怪兽2只以上存在的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽不能攻击，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22748199,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_ATTACK)
	e1:SetCondition(c22748199.condition)
	e1:SetTarget(c22748199.target)
	e1:SetOperation(c22748199.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的状态，自己场上有5星以上的水属性怪兽召唤·特殊召唤的场合才能发动。这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22748199,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,22748199)
	e2:SetCondition(c22748199.setcon)
	e2:SetTarget(c22748199.settg)
	e2:SetOperation(c22748199.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤出场上表侧表示且水属性的怪兽，用于后续检查场上是否存在满足条件的水属性怪兽。
function c22748199.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- ①效果的发动条件：双方怪兽区域存在至少2只表侧表示水属性怪兽时，才满足发动前提。
function c22748199.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断双方场上是否存在至少2只表侧表示水属性怪兽，作为①效果能否发动的条件判定。
	return Duel.IsExistingMatchingCard(c22748199.filter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil)
end
-- ①效果的目标选择：确认可发动后，从对方场上选择1只表侧表示且可被无效化的怪兽作为对象。
function c22748199.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理时校验候选对象：该卡必须是对方场上表侧表示、由对方控制且满足可被无效化的怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	-- 发动合法性确认：检查对方场上是否存在至少1只满足无效化条件的表侧表示怪兽可选为对象。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要无效的卡”的选择提示，用于引导选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从对方场上选择1只可无效化的表侧表示怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ①效果处理：对象怪兽仍有关联且表侧表示时，先使其不能攻击；若这张卡自身未被无效，再将其效果无效化并无效与其相关的连锁。
function c22748199.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得①效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只表侧表示怪兽不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if not c:IsDisabled() then
			-- 使对象怪兽相关的连锁无效化，并在回合结束时重置该无效化状态，用于实现“效果无效化”。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 效果无效化。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
-- 过滤出自己场上表侧表示、等级5以上且水属性的怪兽，用于判断②的触发条件。
function c22748199.setfilter(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsControler(tp)
end
-- ②的触发条件：本次召唤成功的怪兽中，存在至少1只自己控制的5星以上水属性表侧表示怪兽。
function c22748199.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c22748199.setfilter,1,nil,tp)
end
-- ②发动时确认这张墓地中的卡可以盖放，并登记其将从墓地离场的操作信息。
function c22748199.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 向系统登记本次处理包含“从墓地离开”的分类，以便相关卡牌能正确响应这张卡离开墓地的动作。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍在墓地且与效果关联，则将其盖放到自己场上；盖放成功后赋予它从场上离开时改为除外的替代效果。
function c22748199.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与②效果关联，并尝试将其盖放到自己场上；仅当盖放成功时才继续设置除外的替代效果。
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end

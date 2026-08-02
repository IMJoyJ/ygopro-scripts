--魔法効果の剣
local s,id,o=GetID()
-- 初始化函数，注册卡片的各个效果
function s.initial_effect(c)
	-- 记录卡片上记载着卡名「33599853」
	aux.AddCodeList(c,33599853)
	-- ①：可以从以下效果选择1个发动。●场上的表侧表示魔法卡全部破坏。●把手卡·墓地1张「33599853」给对方观看，以对方场上1只效果怪兽为对象才能发动。那只怪兽的攻击力变成0，效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	-- 设置效果1的条件：限制只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏的场合才能发动。从手卡选1张卡破坏。手卡没有卡的场合，选自己场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查卡片是否是表侧表示的魔法卡
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 过滤函数，检查卡片是否是卡号为33599853的卡
function s.cfilter(c)
	return c:IsCode(33599853)
end
-- 过滤函数，检查卡片是否是表侧表示，且攻击力大于0或可以被无效的怪兽
function s.disfilter(c)
	-- 判断卡片是否是表侧表示，且攻击力大于0或可以被无效的怪兽
	return c:IsFaceup() and (c:GetAttack()>0 or aux.NegateMonsterFilter(c))
end
-- 效果1的发动目标设定，根据选择决定破坏魔法卡还是无效怪兽效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==2 and chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.disfilter(chkc) end
	-- 判断当前是否不为伤害步骤
	local b1=Duel.GetCurrentPhase()~=PHASE_DAMAGE
		-- 判断场上是否存在表侧表示的魔法卡
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil)
	-- 判断手卡·墓地是否存在卡号为33599853的卡
	local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
		-- 判断对方场上是否存在满足条件的可以无效的怪兽
		and Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	-- 让玩家从满足条件的效果中选择1个发动
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},
		{b2,aux.Stringid(id,2),2})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		-- 获取场上所有的表侧表示魔法卡
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
		-- 设置操作信息：预期破坏场上所有的表侧表示魔法卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	else
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
		-- 提示玩家选择要无效的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家选择对方场上1只满足条件的怪兽作为对象
		local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置操作信息：预期无效选择的怪兽的效果
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	end
end
-- 效果1的处理逻辑，执行破坏魔法卡或降低攻击力并无效效果的操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 获取场上所有的表侧表示魔法卡
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			-- 将获取到的魔法卡破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 让玩家从手卡·墓地中选择1张卡号为33599853的卡
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
		local rc=g:GetFirst()
		if not rc then return end
		if rc:IsLocation(LOCATION_HAND) then
			-- 向对方展示选中的卡
			Duel.ConfirmCards(1-tp,rc)
			-- 洗切玩家的手卡
			Duel.ShuffleHand(tp)
		else
			-- 如果卡在墓地，则显示被选为对象的动画提示
			Duel.HintSelection(g)
		end
		-- 获取发动时选择的对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
			-- 那只怪兽的攻击力变成0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使和该怪兽有关的连锁都无效化，回合结束时重置
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 那只怪兽的效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 那只怪兽的效果无效化
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
-- 判断是否是对方的回合被破坏，并且在被破坏前是由自己控制的
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 效果2的发动目标设定，根据手卡数量决定破坏的范围
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果只是检查是否能发动，返回自己手卡或场上是否有卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)>0 end
	-- 判断自己手卡是否有卡
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
		-- 如果有手卡，设置操作信息：预期从手卡或场上破坏1张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_HAND)
	else
		-- 获取自己场上的所有卡
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		-- 如果没有手卡，设置操作信息：预期从自己场上破坏1张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,LOCATION_ONFIELD)
	end
end
-- 效果2的处理逻辑，随机破坏手卡或者让玩家选择破坏场上的卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己的所有手卡
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 获取自己场上的所有卡
	local fg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local g
	-- 如果手卡有卡，并且场上没卡或者玩家选择破坏手卡时
	if #hg>0 and (#fg==0 or Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))==0) then
		g=hg:RandomSelect(tp,1)
	else
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择自己场上的1张卡
		g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	end
	if g and #g>0 then
		-- 显示被选为对象的动画提示
		Duel.HintSelection(g)
		-- 将选中的卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end

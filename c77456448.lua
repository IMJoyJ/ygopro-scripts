--魔法効果の剣
local s,id,o=GetID()
-- 初始化卡片效果：注册关联卡片卡名、①魔法卡破坏/怪兽无效二选一发动效果、②盖放状态被对方效果破坏反制效果
function s.initial_effect(c)
	-- 注册特定卡名关联：「沉默剑士」
	aux.AddCodeList(c,33599853)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●对方场上的表侧表示魔法卡全部破坏。●从自己手卡·墓地把1只「沉默剑士」怪兽给对方确认，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0，效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	-- 设定发动条件：伤害步骤中只能在伤害姿势·伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被对方的效果破坏的场合才能发动。选择对方的手卡或场上的1张卡破坏。
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
-- 破坏过滤条件：对方场上表侧表示的魔法卡
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 确认过滤条件：卡名为「沉默剑士」的怪兽
function s.cfilter(c)
	return c:IsCode(33599853)
end
-- 无效目标过滤条件：对方场上攻击力大于0或效果可无效的表侧表示怪兽
function s.disfilter(c)
	-- 检查卡片是否为表侧表示且攻击力大于0或效果可无效
	return c:IsFaceup() and (c:GetAttack()>0 or aux.NegateMonsterFilter(c))
end
-- ①效果发动准备：选择效果分支并设置操作信息与对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==2 and chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.disfilter(chkc) end
	-- 分支1可行性判定：非伤害步骤且对方场上存在表侧表示魔法卡
	local b1=Duel.GetCurrentPhase()~=PHASE_DAMAGE
		-- 检查对方场上是否存在表侧表示魔法卡
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil)
	-- 分支2可行性判定：手卡/墓地有「沉默剑士」且对方场上有可无效怪兽
	local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
		-- 检查对方场上是否存在可选择的对象怪兽
		and Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	-- 让玩家从满足条件的效果分支中选择1个
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},
		{b2,aux.Stringid(id,2),2})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		-- 获取对方场上所有表侧表示魔法卡
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
		-- 设置连锁操作信息：破坏对方场上所有表侧表示魔法卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	else
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
		-- 提示玩家选择要无效效果的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 选择对方场上1只表侧表示怪兽作为对象
		local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置连锁操作信息：无效选中怪兽的效果
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	end
end
-- ①效果处理：根据选择的分支执行破坏对方魔法卡或确认卡片使对方怪兽攻变0且效果无效
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 获取对方场上表侧表示魔法卡
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			-- 破坏对方场上所有表侧表示魔法卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要确认的「沉默剑士」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从手卡或墓地选择1只「沉默剑士」怪兽
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
		local rc=g:GetFirst()
		if not rc then return end
		if rc:IsLocation(LOCATION_HAND) then
			-- 给对方确认手卡中的卡
			Duel.ConfirmCards(1-tp,rc)
			-- 将手卡洗牌
			Duel.ShuffleHand(tp)
		else
			-- 高亮显示墓地选中的卡片
			Duel.HintSelection(g)
		end
		-- 获取连锁关联的对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
			-- 那只怪兽的攻击力变成0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使目标怪兽涉及的已发动连锁无效
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 效果无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 效果无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
-- ②效果发动条件：盖放状态下被对方效果破坏
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- ②效果发动准备：设置破坏对方手卡或场上卡片的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：对方手卡或场上有卡存在
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)>0 end
	-- 判断对方手卡是否有卡存在
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
		-- 设置连锁操作信息：破坏对方手卡或场上1张卡（手卡有卡时）
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_HAND)
	else
		-- 获取对方场上的卡片组
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		-- 设置连锁操作信息：破坏对方场上1张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,LOCATION_ONFIELD)
	end
end
-- ②效果处理：破坏对方手卡的随机1张卡或场上的1张卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡卡组
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 获取对方场上卡组
	local fg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local g
	-- 判断是否破坏对方手卡（在手卡存在且选择破坏手卡时）
	if #hg>0 and (#fg==0 or Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))==0) then
		g=hg:RandomSelect(tp,1)
	else
		-- 提示玩家选择要破坏的场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上1张卡
		g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	end
	if g and #g>0 then
		-- 高亮显示选中的场上卡片
		Duel.HintSelection(g)
		-- 将选中的卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--魔法効果の剣
local s,id,o=GetID()
-- 初始化卡片效果：记录关联卡名、注册发动效果（破坏对方魔法卡/展示关联卡使对方怪兽攻变0并无效）及被对方破坏触发动破坏效果
function s.initial_effect(c)
	-- 记录卡名：此卡记载了「光与暗的仪式」的卡名
	aux.AddCodeList(c,33599853)
	-- ①：从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	-- 发动条件限制：伤害步骤中只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏的场合才能发动。对方的手卡·场上的1张卡破坏。
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
-- 展示卡过滤条件：记载有「光与暗的仪式」卡名的卡
function s.cfilter(c)
	return c:IsCode(33599853)
end
-- 无效过滤条件：对方场上表侧表示且攻击力大于0或效果未被无效的怪兽
function s.disfilter(c)
	-- 检查怪兽是否表侧表示且攻击力大于0或未被无效
	return c:IsFaceup() and (c:GetAttack()>0 or aux.NegateMonsterFilter(c))
end
-- 效果发动准备：检查发动条件并由玩家选择发动的效果分支
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==2 and chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.disfilter(chkc) end
	-- 分支1判定：当前不处于伤害步骤
	local b1=Duel.GetCurrentPhase()~=PHASE_DAMAGE
		-- 分支1判定：对方场上存在表侧表示的魔法卡
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil)
	-- 分支2判定：自己手牌或墓地存在记载有「光与暗的仪式」卡名的卡
	local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
		-- 分支2判定：对方场上存在可选择的表侧表示怪兽
		and Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	-- 提示玩家选择要发动的效果分支
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},
		{b2,aux.Stringid(id,2),2})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		-- 分支1：获取对方场上所有表侧表示的魔法卡
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
		-- 分支1：设置连锁操作信息：破坏对方场上的表侧魔法卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	else
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
		-- 提示玩家选择要无效的目标怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 分支2：选择对方场上1只表侧表示怪兽作为对象
		local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 分支2：设置连锁操作信息：无效目标怪兽的效果
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	end
end
-- 效果处理：根据选择的分支执行破坏魔法卡或展示卡片降攻无效
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 分支1处理：获取对方场上表侧表示的魔法卡
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			-- 分支1处理：破坏选中的魔法卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 分支2处理：从手牌或墓地选择1张记载有「光与暗的仪式」卡名的卡
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
		local rc=g:GetFirst()
		if not rc then return end
		if rc:IsLocation(LOCATION_HAND) then
			-- 给对方确认手牌中选中的卡
			Duel.ConfirmCards(1-tp,rc)
			-- 洗混手牌
			Duel.ShuffleHand(tp)
		else
			-- 高亮显示墓地中选中的卡
			Duel.HintSelection(g)
		end
		-- 获取发动时选择的目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
			-- 作为对象的怪兽的攻击力变成0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 中断目标怪兽已发动的连锁效果
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
-- 破坏效果条件：被对方破坏且此前由自己控制
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 破坏效果准备：检查对方手牌及场上卡片数量并设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上及手牌是否存在卡片
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)>0 end
	-- 检查对方手牌是否存在卡片
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
		-- 设置连锁操作信息：破坏对方手牌或场上的1张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_HAND)
	else
		-- 获取对方场上的卡片组
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		-- 设置连锁操作信息：破坏对方场上的1张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,LOCATION_ONFIELD)
	end
end
-- 破坏效果处理：从对方手牌随机破坏1张卡或从场上选择1张卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌卡片组
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 获取对方场上卡片组
	local fg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local g
	-- 选择破坏手牌还是场上的卡
	if #hg>0 and (#fg==0 or Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))==0) then
		g=hg:RandomSelect(tp,1)
	else
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的1张卡
		g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	end
	if g and #g>0 then
		-- 高亮显示选择的目标卡片
		Duel.HintSelection(g)
		-- 破坏选中的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end

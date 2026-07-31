--魔法効果の剣
local s,id,o=GetID()
-- 初始化卡片效果：注册①二选一发动效果（全爆对方表侧魔法 / 展示光剑无效对方怪兽攻设0）、②被对方破坏炸手卡/场上卡效果
function s.initial_effect(c)
	-- 注册记述卡号列表：记述「光之护封剑」（33599853）
	aux.AddCodeList(c,33599853)
	-- ①：可以从以下效果选择1个发动（伤害步骤中也可以发动）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	-- 设置发动条件：允许在伤害步骤中发动（除伤害计算时外）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被对方的效果破坏的场合才能发动。对方手卡·场上1张卡破坏。
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
-- 分支1破坏过滤条件：对方场上表侧表示的魔法卡
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 分支2展示过滤条件：卡名为「光之护封剑」
function s.cfilter(c)
	return c:IsCode(33599853)
end
-- 分支2目标过滤条件：表侧表示且攻击力大于0或效果未被无效的怪兽
function s.disfilter(c)
	-- 检查怪兽是否表侧表示且攻击力大于0或能被无效效果
	return c:IsFaceup() and (c:GetAttack()>0 or aux.NegateMonsterFilter(c))
end
-- ①效果发动准备：检查两个分支的发动条件，由玩家选择发动分支并设置对应的分类与目标信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==2 and chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.disfilter(chkc) end
	-- 检查分支1时点条件：非伤害步骤中
	local b1=Duel.GetCurrentPhase()~=PHASE_DAMAGE
		-- 检查分支1对象条件：对方场上是否存在表侧表示的魔法卡
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil)
	-- 检查分支2条件：己方手牌/墓地是否存在「光之护封剑」
	local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
		-- 检查分支2对象条件：对方场上是否存在可作为目标的表侧怪兽
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
		-- 获取对方场上所有表侧表示的魔法卡
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
		-- 设置连锁操作信息：破坏对方场上所有表侧魔法卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	else
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
		-- 提示玩家选择要无效的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 选择对方场上1只表侧表示怪兽作为目标
		local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置连锁操作信息：无效目标的卡片效果
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	end
end
-- ①效果处理：根据选定的分支执行破坏对方表侧魔法，或展示光剑并将目标怪兽攻击力变成0且效果无效
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 获取对方场上所有表侧表示的魔法卡
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			-- 破坏对方场上所有表侧表示的魔法卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要展示给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从手牌或墓地选择1张「光之护封剑」
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
		local rc=g:GetFirst()
		if not rc then return end
		if rc:IsLocation(LOCATION_HAND) then
			-- 向对方展示手牌中的「光之护封剑」
			Duel.ConfirmCards(1-tp,rc)
			-- 洗混己方手牌
			Duel.ShuffleHand(tp)
		else
			-- 高亮显示墓地中选中的「光之护封剑」
			Duel.HintSelection(g)
		end
		-- 获取连锁中选择的目标怪兽
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
			-- 那只怪兽的攻击力变成0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 中断目标怪兽已发动的连锁并重置其状态
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
-- ②效果触发条件：场上的此卡因对方的效果被破坏
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- ②效果发动准备：检查对方手牌及场上卡片数量并设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：对方手牌或场上是否存在卡片
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)>0 end
	-- 检查对方手牌是否存在卡片
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
		-- 手牌有卡时，设置对方手牌或场上破坏1张卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_HAND)
	else
		-- 获取对方场上的所有卡片
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		-- 手牌无卡时，设置对方场上破坏1张卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,LOCATION_ONFIELD)
	end
end
-- ②效果处理：从对方手牌随机破坏1张或由己方选择破坏对方场上1张卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌的所有卡片
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 获取对方场上的所有卡片
	local fg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local g
	-- 判断破坏选择：手牌有卡且场上无卡或玩家选择破坏手牌
	if #hg>0 and (#fg==0 or Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))==0) then
		g=hg:RandomSelect(tp,1)
	else
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上选择1张卡
		g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	end
	if g and #g>0 then
		-- 高亮显示所选的对方场上卡片
		Duel.HintSelection(g)
		-- 破坏选中的卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end

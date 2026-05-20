--サブテラーの決戦
-- 效果：
-- ①：可以从以下效果选择1个发动。发动后这张卡不送去墓地，直接盖放。
-- ●选自己场上1只里侧表示的「地中族」怪兽变成表侧攻击表示或者表侧守备表示。
-- ●选场上1只表侧表示的「地中族」怪兽变成里侧守备表示。
-- ●选场上1只表侧表示的「地中族」怪兽，那只怪兽的攻击力·守备力直到回合结束时变成那个原本的攻击力和守备力合计数值。
-- ●这个回合，「地中族」卡的所发动的效果不会被无效化。
function c74640994.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。发动后这张卡不送去墓地，直接盖放。●选自己场上1只里侧表示的「地中族」怪兽变成表侧攻击表示或者表侧守备表示。●选场上1只表侧表示的「地中族」怪兽变成里侧守备表示。●选场上1只表侧表示的「地中族」怪兽，那只怪兽的攻击力·守备力直到回合结束时变成那个原本的攻击力和守备力合计数值。●这个回合，「地中族」卡的所发动的效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_MSET+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	-- 设置效果发动条件为伤害计算前（配合伤害步骤发动限制）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c74640994.target)
	e1:SetOperation(c74640994.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示且拥有守备力的「地中族」怪兽。
function c74640994.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xed) and c:IsDefenseAbove(0)
end
-- 过滤场上里侧表示的「地中族」怪兽。
function c74640994.fufilter(c)
	return c:IsFacedown() and c:IsSetCard(0xed)
end
-- 过滤场上表侧表示且可以变成里侧表示的「地中族」怪兽。
function c74640994.fdfilter(c)
	return c74640994.filter(c) and c:IsCanTurnSet()
end
-- 效果发动时的目标选择与处理，检测并让玩家选择要发动的效果分支，并设置对应的操作信息。
function c74640994.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足分支1的发动条件：非伤害步骤且自己场上存在里侧表示的「地中族」怪兽。
	local b1=Duel.GetCurrentPhase()~=PHASE_DAMAGE and Duel.IsExistingMatchingCard(c74640994.fufilter,tp,LOCATION_MZONE,0,1,nil)
	-- 检查是否满足分支2的发动条件：非伤害步骤且场上存在可以变成里侧表示的表侧表示「地中族」怪兽。
	local b2=Duel.GetCurrentPhase()~=PHASE_DAMAGE and Duel.IsExistingMatchingCard(c74640994.fdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 检查是否满足分支3的发动条件：场上存在表侧表示的「地中族」怪兽（此效果可在伤害步骤发动）。
	local b3=Duel.IsExistingMatchingCard(c74640994.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 检查是否满足分支4的发动条件：非伤害步骤且本回合该玩家尚未适用过此效果。
	local b4=Duel.GetCurrentPhase()~=PHASE_DAMAGE and Duel.GetFlagEffect(tp,74640994)==0
	if chk==0 then return b1 or b2 or b3 or b4 end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(74640994,0)  --"翻开里侧表示怪兽"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(74640994,1)  --"盖放表侧表示怪兽"
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(74640994,2)  --"攻击力守备力上升"
		opval[off-1]=3
		off=off+1
	end
	if b4 then
		ops[off]=aux.Stringid(74640994,3)  --"发动的效果不会被无效"
		opval[off-1]=4
		off=off+1
	end
	-- 让玩家从满足发动条件的效果分支中选择一个发动。
	local op=Duel.SelectOption(tp,table.unpack(ops))
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==1 then
		e:SetCategory(CATEGORY_POSITION+CATEGORY_SSET)
		-- 设置连锁信息：包含改变表示形式的操作，数量为1张。
		Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
	elseif sel==2 then
		e:SetCategory(CATEGORY_POSITION+CATEGORY_MSET+CATEGORY_SSET)
		-- 设置连锁信息：包含改变表示形式的操作，数量为1张。
		Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
	elseif sel==3 then
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_SSET)
	elseif sel==4 then
		e:SetCategory(CATEGORY_SSET)
	end
end
-- 效果处理函数，根据选择的分支执行对应的效果，并在处理完毕后将这张卡在场上盖放。
function c74640994.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==1 then
		-- 提示玩家选择要改变表示形式的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 让玩家选择自己场上1只里侧表示的「地中族」怪兽。
		local g=Duel.SelectMatchingCard(tp,c74640994.fufilter,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 选中该怪兽并向双方玩家展示。
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			-- 让玩家选择该怪兽变成表侧攻击表示还是表侧守备表示。
			local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
			-- 改变该怪兽的表示形式为玩家选择的形式。
			Duel.ChangePosition(tc,pos)
		end
	elseif sel==2 then
		-- 提示玩家选择要改变表示形式的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 让玩家选择场上1只表侧表示的「地中族」怪兽。
		local g=Duel.SelectMatchingCard(tp,c74640994.fdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 选中该怪兽并向双方玩家展示。
			Duel.HintSelection(g)
			-- 将选中的怪兽变成里侧守备表示。
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	elseif sel==3 then
		-- 提示玩家选择表侧表示的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家选择场上1只表侧表示的「地中族」怪兽。
		local g=Duel.SelectMatchingCard(tp,c74640994.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 选中该怪兽并向双方玩家展示。
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			local atk=tc:GetBaseAttack()+tc:GetBaseDefense()
			-- 那只怪兽的攻击力·守备力直到回合结束时变成那个原本的攻击力和守备力合计数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			tc:RegisterEffect(e2)
		end
	else
		-- 这个回合，「地中族」卡的所发动的效果不会被无效化。发动后这张卡不送去墓地，直接盖放。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_DISEFFECT)
		e1:SetValue(c74640994.effectfilter)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 在全局环境中注册该玩家适用的场上效果。
		Duel.RegisterEffect(e1,tp)
		-- 给玩家注册一个回合内有效的标识效果，用于限制该分支效果每回合只能发动一次。
		Duel.RegisterFlagEffect(tp,74640994,RESET_PHASE+PHASE_END,0,1)
	end
	if c:IsRelateToEffect(e) and c:IsCanTurnSet() and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 中断当前效果处理，使后续的盖放卡片处理不与前面的效果同时进行。
		Duel.BreakEffect()
		c:CancelToGrave()
		-- 将这张卡在场上里侧表示盖放。
		Duel.ChangePosition(c,POS_FACEDOWN)
		-- 触发“卡片被效果盖放”的时点。
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
-- 过滤不会被无效化的效果，判定触发效果的卡片是否为「地中族」卡片。
function c74640994.effectfilter(e,ct)
	-- 获取指定连锁序号上正在发动的效果。
	local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	local tc=te:GetHandler()
	return tc:IsSetCard(0xed)
end

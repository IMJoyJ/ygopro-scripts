--迅雷の暴君 グローザー
-- 效果：
-- 调整＋调整以外的恶魔族怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方主要阶段，以场上1只效果怪兽为对象才能发动。从手卡选1只怪兽丢弃，作为对象的怪兽的效果直到回合结束时无效。
-- ②：恶魔族怪兽从手卡送去自己墓地的场合才能发动。从以下效果选1个直到回合结束时对这张卡适用。
-- ●不会被战斗破坏。
-- ●不会被对方的效果破坏。
-- ●不会成为对方的效果的对象。
function c45420955.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续，要求1只调整和1只调整以外的恶魔族怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_FIEND),1)
	-- ①：对方主要阶段，以场上1只效果怪兽为对象才能发动。从手卡选1只怪兽丢弃，作为对象的怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45420955,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,45420955)
	e1:SetCondition(c45420955.negcon)
	e1:SetTarget(c45420955.negtg)
	e1:SetOperation(c45420955.negop)
	c:RegisterEffect(e1)
	-- ②：恶魔族怪兽从手卡送去自己墓地的场合才能发动。从以下效果选1个直到回合结束时对这张卡适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45420955,1))  --"获得抗性"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c45420955.econ)
	e2:SetOperation(c45420955.eop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选可以丢弃的手卡怪兽
function c45420955.dcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果发动条件，判断是否为对方主要阶段
function c45420955.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断是否为对方主要阶段
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 设置效果目标，选择场上1只效果怪兽作为对象
function c45420955.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 设置效果目标时的过滤条件，筛选场上效果怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查是否满足效果发动条件，即场上存在效果怪兽且手卡有可丢弃的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.IsExistingMatchingCard(c45420955.dcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要无效的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1只效果怪兽作为对象
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，记录将要无效的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理函数，丢弃手卡怪兽并使目标怪兽效果无效
function c45420955.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 丢弃手卡1只怪兽，若成功则继续处理
	if Duel.DiscardHand(tp,c45420955.dcfilter,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
		local c=e:GetHandler()
		-- 获取效果目标怪兽
		local tc=Duel.GetFirstTarget()
		if ((tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
			-- 使目标怪兽相关的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使目标怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使目标怪兽效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 使目标陷阱怪兽效果无效
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
-- 过滤函数，用于筛选从手卡送去墓地的恶魔族怪兽
function c45420955.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FIEND) and c:IsPreviousLocation(LOCATION_HAND) and c:IsControler(tp)
end
-- 效果发动条件，判断是否有恶魔族怪兽从手卡送去墓地
function c45420955.econ(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(c45420955.cfilter,1,nil,tp)
		and (c:GetFlagEffect(45420955)==0 or bit.band(c:GetFlagEffectLabel(45420955),0x7)~=0x7 or not c:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) or not c:IsHasEffect(EFFECT_INDESTRUCTABLE_EFFECT)
			or not c:IsHasEffect(EFFECT_CANNOT_BE_EFFECT_TARGET))
end
-- 效果处理函数，选择并应用一种抗性
function c45420955.eop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=(c:GetFlagEffect(45420955)==0 or bit.band(c:GetFlagEffectLabel(45420955),0x1)==0 or not c:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE))
	local b2=(c:GetFlagEffect(45420955)==0 or bit.band(c:GetFlagEffectLabel(45420955),0x2)==0 or not c:IsHasEffect(EFFECT_INDESTRUCTABLE_EFFECT))
	local b3=(c:GetFlagEffect(45420955)==0 or bit.band(c:GetFlagEffectLabel(45420955),0x4)==0 or not c:IsHasEffect(EFFECT_CANNOT_BE_EFFECT_TARGET))
	if not b1 and not b2 and not b3 then return end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(45420955,2)  --"不会被战斗破坏"
		opval[off]=0
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(45420955,3)  --"不会被对方的效果破坏"
		opval[off]=1
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(45420955,4)  --"不会成为对方的效果的对象"
		opval[off]=2
		off=off+1
	end
	-- 选择要应用的抗性
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	if sel==0 then
		if c:GetFlagEffect(45420955)==0 then
			c:RegisterFlagEffect(45420955,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		c:SetFlagEffectLabel(45420955,bit.bor(c:GetFlagEffectLabel(45420955),0x1))
		-- 使自身不会被战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(45420955,2))  --"不会被战斗破坏"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	elseif sel==1 then
		if c:GetFlagEffect(45420955)==0 then
			c:RegisterFlagEffect(45420955,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		c:SetFlagEffectLabel(45420955,bit.bor(c:GetFlagEffectLabel(45420955),0x2))
		-- 使自身不会被对方的效果破坏
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(45420955,3))  --"不会被对方的效果破坏"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		-- 设置效果值为aux.indoval函数，用于判断是否不会被对方效果破坏
		e1:SetValue(aux.indoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	else
		if c:GetFlagEffect(45420955)==0 then
			c:RegisterFlagEffect(45420955,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		c:SetFlagEffectLabel(45420955,bit.bor(c:GetFlagEffectLabel(45420955),0x4))
		-- 使自身不会成为对方的效果的对象
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(45420955,4))  --"不会成为对方的效果的对象"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		-- 设置效果值为aux.tgoval函数，用于判断是否不会成为对方效果的对象
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

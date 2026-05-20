--ゴッド・ハンド・クラッシャー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡的发动和效果不会被无效化。
-- ①：自己场上有原本卡名是「欧贝利斯克之巨神兵」的怪兽存在的场合才能发动。选对方场上1只效果怪兽，把效果无效并破坏。这个回合，这个效果破坏的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。这张卡在自己主要阶段发动的场合，可以再让以下效果适用。
-- ●对方场上的魔法·陷阱卡全部破坏。
function c79868386.initial_effect(c)
	-- 注册卡片脚本中记载了「欧贝利斯克之巨神兵」（卡号10000000）的卡片密码。
	aux.AddCodeList(c,10000000)
	-- 这个卡名的卡在1回合只能发动1张。这张卡的发动和效果不会被无效化。①：自己场上有原本卡名是「欧贝利斯克之巨神兵」的怪兽存在的场合才能发动。选对方场上1只效果怪兽，把效果无效并破坏。这个回合，这个效果破坏的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。这张卡在自己主要阶段发动的场合，可以再让以下效果适用。●对方场上的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,79868386+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c79868386.condition)
	e1:SetTarget(c79868386.target)
	e1:SetOperation(c79868386.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示且原本卡名为「欧贝利斯克之巨神兵」的怪兽。
function c79868386.actfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(10000000)
end
-- 发动条件：自己场上存在原本卡名是「欧贝利斯克之巨神兵」的怪兽。
function c79868386.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在原本卡名是「欧贝利斯克之巨神兵」的怪兽。
	return Duel.IsExistingMatchingCard(c79868386.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标选择与操作信息注册。
function c79868386.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以被无效的效果怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置操作信息：包含无效效果的操作。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
	-- 设置操作信息：包含破坏卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
-- 效果处理的核心逻辑。
function c79868386.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择对方场上1只可以被无效的效果怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 把效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 把效果无效
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 立即刷新场上卡片的无效状态。
		Duel.AdjustInstantly()
		-- 使与该怪兽相关的连锁中已发动的效果无效。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 尝试破坏该怪兽，若成功破坏则执行后续处理。
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 这个回合，这个效果破坏的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_DISABLE)
			e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e3:SetTarget(c79868386.distg)
			e3:SetLabelObject(tc)
			e3:SetReset(RESET_PHASE+PHASE_END)
			-- 注册全局场上怪兽效果无效化的效果。
			Duel.RegisterEffect(e3,tp)
			-- 这个回合，这个效果破坏的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。这张卡在自己主要阶段发动的场合，可以再让以下效果适用。●对方场上的魔法·陷阱卡全部破坏。
			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e4:SetCode(EVENT_CHAIN_SOLVING)
			e4:SetCondition(c79868386.discon)
			e4:SetOperation(c79868386.disop)
			e4:SetLabelObject(tc)
			e4:SetReset(RESET_PHASE+PHASE_END)
			-- 注册用于无效同名怪兽发动效果的全局事件监听器。
			Duel.RegisterEffect(e4,tp)
			-- 获取对方场上所有的魔法·陷阱卡。
			local sg=Duel.GetMatchingGroup(c79868386.desfilter,tp,0,LOCATION_ONFIELD,nil)
			-- 检查对方场上是否存在魔陷，且当前为自己的回合。
			if #sg>0 and Duel.GetTurnPlayer()==tp
				-- 检查当前阶段是否为主要阶段1或主要阶段2。
				and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
				-- 询问玩家是否适用追加效果，破坏对方场上全部魔法·陷阱卡。
				and Duel.SelectYesNo(tp,aux.Stringid(79868386,0)) then  --"是否把对方场上的魔法·陷阱卡全部破坏？"
				-- 中断当前效果处理，使后续的破坏魔陷处理与前面的破坏怪兽处理不视为同时进行。
				Duel.BreakEffect()
				-- 破坏对方场上所有的魔法·陷阱卡。
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end
-- 过滤条件：魔法或陷阱卡。
function c79868386.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤条件：原本卡名与被破坏怪兽相同的怪兽。
function c79868386.distg(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 触发条件：发动的怪兽效果其原本卡名与被破坏怪兽相同。
function c79868386.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 效果处理：使该怪兽效果的发动无效。
function c79868386.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该连锁的效果。
	Duel.NegateEffect(ev)
end

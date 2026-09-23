--ゴッド・ハンド・クラッシャー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡的发动和效果不会被无效化。
-- ①：自己场上有原本卡名是「欧贝利斯克之巨神兵」的怪兽存在的场合才能发动。选对方场上1只效果怪兽，把效果无效并破坏。这个回合，这个效果破坏的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。这张卡在自己主要阶段发动的场合，可以再让以下效果适用。
-- ●对方场上的魔法·陷阱卡全部破坏。
function c79868386.initial_effect(c)
	-- 将「欧贝利斯克之巨神兵」卡号记入卡片关联代码列表
	aux.AddCodeList(c,10000000)
	-- ①：自己场上有原本卡名是「欧贝利斯克之巨神兵」的怪兽存在的场合才能发动。选对方场上1只效果怪兽，把效果无效并破坏。这个回合，这个效果破坏的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。这张卡在自己主要阶段发动的场合，可以再让以下效果适用。●对方场上的魔法·陷阱卡全部破坏。
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
	-- 这张卡的发动和效果不会被无效化。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
end
-- 过滤场上原本卡名是「欧贝利斯克之巨神兵」的怪兽
function c79868386.actfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(10000000)
end
-- 发动条件：自己场上有原本卡名为「欧贝利斯克之巨神兵」的怪兽存在
function c79868386.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在原本卡名为「欧贝利斯克之巨神兵」的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c79868386.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 效果发动目标检查
function c79868386.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可以无效效果的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置操作信息：无效1只怪兽的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
	-- 设置操作信息：破坏1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
-- 效果处理：无效并破坏对方怪兽，无效同名怪兽效果，可追加破坏魔陷
function c79868386.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选对方场上1只效果怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 选对方场上1只效果怪兽，把效果无效
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
		-- 立即刷新场上状态
		Duel.AdjustInstantly()
		-- 无效该怪兽在当前连锁上已经发动的效果
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 判断是否成功破坏目标怪兽
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 这个回合，这个效果破坏的怪兽以及原本卡名和那只怪兽相同的怪兽的效果无效化。
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_FIELD)
			e3:SetCode(EFFECT_DISABLE)
			e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e3:SetTarget(c79868386.distg)
			e3:SetLabelObject(tc)
			e3:SetReset(RESET_PHASE+PHASE_END)
			-- 注册破坏怪兽及其同名怪兽场上效果无效化的效果
			Duel.RegisterEffect(e3,tp)
			-- ●对方场上的魔法·陷阱卡全部破坏。
			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e4:SetCode(EVENT_CHAIN_SOLVING)
			e4:SetCondition(c79868386.discon)
			e4:SetOperation(c79868386.disop)
			e4:SetLabelObject(tc)
			e4:SetReset(RESET_PHASE+PHASE_END)
			-- 注册破坏怪兽及其同名怪兽发动效果无效化的效果
			Duel.RegisterEffect(e4,tp)
			-- 获取对方场上的魔法·陷阱卡
			local sg=Duel.GetMatchingGroup(c79868386.desfilter,tp,0,LOCATION_ONFIELD,nil)
			-- 判断对方场上是否存在魔陷且当前是自己的回合
			if #sg>0 and Duel.GetTurnPlayer()==tp
				-- 判断当前阶段是否为主要阶段
				and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
				-- 询问玩家是否破坏对方场上全部魔法·陷阱卡
				and Duel.SelectYesNo(tp,aux.Stringid(79868386,0)) then  --"是否把对方场上的魔法·陷阱卡全部破坏？"
				-- 中断前序效果处理阶段
				Duel.BreakEffect()
				-- 破坏对方场上的全部魔法·陷阱卡
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end
-- 过滤魔法·陷阱卡
function c79868386.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 无效目标匹配：判断是否与被破坏怪兽原本卡名相同
function c79868386.distg(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 无效发动条件：判断发动的怪兽效果是否与被破坏怪兽原本卡名相同
function c79868386.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 执行无效效果发动
function c79868386.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该怪兽效果的发动
	Duel.NegateEffect(ev)
end

--無限泡影
-- 效果：
-- 自己场上没有卡存在的场合，这张卡的发动从手卡也能用。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。盖放的这张卡发动的场合，再在这个回合中让和这张卡相同纵列的其他的魔法·陷阱卡的效果无效化。
function c10045474.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。盖放的这张卡发动的场合，再在这个回合中让和这张卡相同纵列的其他的魔法·陷阱卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c10045474.target)
	e1:SetOperation(c10045474.activate)
	c:RegisterEffect(e1)
	-- 自己场上没有卡存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10045474,0))  --"适用「无限泡影」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c10045474.handcon)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备：进行对象怪兽的合法性检测，并使玩家选择合法的怪兽作为对象
function c10045474.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 对象过滤：若已有指向的对象，验证该对象是否是处于对方怪兽区、表侧表示且未被无效的效果怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	-- 可行性检测：判断当前对方场上是否存在至少1只表侧表示且未被无效的怪兽可作为效果对象
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示信息：提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对象：由发动效果的玩家选择1只符合条件的怪兽作为对象
	Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ①效果的 operation 函数（效果处理）：无效作为对象的怪兽的效果，若此卡是盖放状态发动的，则在这个回合中让和这张卡相同纵列的其他的魔法·陷阱卡的效果无效化
function c10045474.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对象：获取当前连锁中被选为第一对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 无效相关连锁：使和该对象怪兽有关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效（使怪兽自身的效果失效）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效（使该怪兽已发动且在处理中的效果失效）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if not c:IsStatus(STATUS_ACT_FROM_HAND) and c:IsLocation(LOCATION_SZONE) then
			-- 再在这个回合中让和这张卡相同纵列的其他的魔法·陷阱卡的效果无效化（持续无效化场上同纵列的其他魔陷效果）
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD)
			e4:SetCode(EFFECT_DISABLE)
			e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
			e4:SetTarget(c10045474.distg)
			e4:SetReset(RESET_PHASE+PHASE_END)
			e4:SetLabel(c:GetSequence(),c:GetFieldID())
			-- 注册效果：将同纵列魔陷在场上持续无效的效果注册给发动该卡效果的玩家
			Duel.RegisterEffect(e4,tp)
			-- 再在这个回合中让和这张卡相同纵列的其他的魔法·陷阱卡的效果无效化（在连锁处理时直接使同纵列魔陷发动的效果无效）
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e5:SetCode(EVENT_CHAIN_SOLVING)
			e5:SetOperation(c10045474.disop)
			e5:SetReset(RESET_PHASE+PHASE_END)
			e5:SetLabel(c:GetSequence())
			-- 注册效果：将同纵列魔陷在连锁求解时使其效果无效的持续效果注册给发动该卡效果的玩家
			Duel.RegisterEffect(e5,tp)
			-- 再在这个回合中让和这张卡相同纵列的其他的魔法·陷阱卡的效果无效化（使作为怪兽使用的陷阱卡效果无效）
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_FIELD)
			e6:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e6:SetTarget(c10045474.distg)
			e6:SetReset(RESET_PHASE+PHASE_END)
			e6:SetLabel(c:GetSequence())
			-- 注册效果：将同纵列陷阱怪兽效果无效的效果注册给发动该卡效果的玩家
			Duel.RegisterEffect(e6,tp)
			-- 区域提示：在决斗盘/场上亮起提示，表示当前被该效果无效的魔法·陷阱卡区域
			Duel.Hint(HINT_ZONE,tp,0x1<<(c:GetSequence()+8))
		end
	end
end
-- 过滤函数：判断卡片是否为相同纵列且不是当前卡片自身的魔法·陷阱卡
function c10045474.distg(e,c)
	local seq,fid=e:GetLabel()
	local tp=e:GetHandlerPlayer()
	-- 条件判断：目标卡片是魔法·陷阱卡，且与该卡同一纵列，且不是该卡自身
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.GetColumn(c,tp)==seq and c:GetFieldID()~=fid
end
-- 连锁处理函数：在连锁求解时，直接无效在相同纵列发动的魔法·陷阱卡的效果
function c10045474.disop(e,tp,eg,ep,ev,re,r,rp)
	local tseq=e:GetLabel()
	-- 获取连锁信息：获取当前正在处理的连锁的控制者、发生位置以及位置序号
	local controller,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if loc&LOCATION_SZONE~=0 and seq<=4 and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and ((controller==tp and seq==tseq) or (controller==1-tp and seq==4-tseq)) then
		-- 无效效果：使当前正要处理的连锁效果无效化
		Duel.NegateEffect(ev)
	end
end
-- 手卡发动条件：验证玩家在手卡发动此卡时是否满足没有卡存在的条件
function c10045474.handcon(e)
	-- 条件判断：自己场上没有卡存在时返回真
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end

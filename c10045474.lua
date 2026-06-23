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
-- 效果①的发动效果目标（Target）处理：选择对方场上1只表侧表示且未被无效的效果怪兽作为效果的对象
function c10045474.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 在被指名卡片成为对象时，检查其是否为对方主要怪兽区的表侧表示未无效怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	-- 在发动时点检查对方场上是否存在至少1只表侧表示且未被无效的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送选择要无效的怪兽的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家在对方场上选择1只表侧表示且未被无效的效果怪兽作为效果对象
	Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①的效果处理（Operation）函数：使选择的怪兽效果无效，若这张卡是盖放发动的，则本回合使其相同纵列的其他魔法·陷阱卡效果无效
function c10045474.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使该怪兽相关的连锁效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if not c:IsStatus(STATUS_ACT_FROM_HAND) and c:IsLocation(LOCATION_SZONE) then
			-- 盖放的这张卡发动的场合，再在这个回合中让和这张卡相同纵列的其他的魔法·陷阱卡的效果无效化。
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD)
			e4:SetCode(EFFECT_DISABLE)
			e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
			e4:SetTarget(c10045474.distg)
			e4:SetReset(RESET_PHASE+PHASE_END)
			e4:SetLabel(c:GetSequence(),c:GetFieldID())
			-- 为当前玩家注册“相同纵列的其他魔陷在场上时效果无效”的场地效果
			Duel.RegisterEffect(e4,tp)
			-- 盖放的这张卡发动的场合，再在这个回合中让和这张卡相同纵列的其他的魔法·陷阱卡的效果无效化。
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e5:SetCode(EVENT_CHAIN_SOLVING)
			e5:SetOperation(c10045474.disop)
			e5:SetReset(RESET_PHASE+PHASE_END)
			e5:SetLabel(c:GetSequence())
			-- 注册一个在魔法陷阱卡效果处理时触发的事件监听器，用于无效同纵列中被激活的魔法陷阱效果
			Duel.RegisterEffect(e5,tp)
			-- 盖放的这张卡发动的场合，再在这个回合中让和这张卡相同纵列的其他的魔法·陷阱卡的效果无效化。
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_FIELD)
			e6:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e6:SetTarget(c10045474.distg)
			e6:SetReset(RESET_PHASE+PHASE_END)
			e6:SetLabel(c:GetSequence())
			-- 注册令同纵列怪兽区中的陷阱怪兽效果无效的场地效果
			Duel.RegisterEffect(e6,tp)
			-- 在画面上高亮并提示受到此卡效果影响（无效化）的相同纵列区域
			Duel.Hint(HINT_ZONE,tp,0x1<<(c:GetSequence()+8))
		end
	end
end
-- 无效纵列魔法陷阱效果的过滤目标函数：必须是魔法或陷阱卡，且与本卡相同纵列，并且不是本卡本身
function c10045474.distg(e,c)
	local seq,fid=e:GetLabel()
	local tp=e:GetHandlerPlayer()
	-- 检查目标卡片是否为魔法或陷阱卡，且与本卡位于同一纵列且不是本卡本身
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.GetColumn(c,tp)==seq and c:GetFieldID()~=fid
end
-- 魔法/陷阱在相同纵列发动连锁处理时的无效化操作函数
function c10045474.disop(e,tp,eg,ep,ev,re,r,rp)
	local tseq=e:GetLabel()
	-- 获取当前处理的连锁信息：发动效果的控制器玩家、发生的位置、在该位置的序号
	local controller,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if loc&LOCATION_SZONE~=0 and seq<=4 and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and ((controller==tp and seq==tseq) or (controller==1-tp and seq==4-tseq)) then
		-- 使当前正在处理的连锁效果无效
		Duel.NegateEffect(ev)
	end
end
-- 手卡发动条件函数：自己场上没有卡存在
function c10045474.handcon(e)
	-- 检查自己场上的卡片总数是否为0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end

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
	-- 手卡发动效果：自己场上没有卡存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10045474,0))  --"适用「无限泡影」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c10045474.handcon)
	c:RegisterEffect(e2)
end
-- 效果发动时的目标选择与条件检查
function c10045474.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查作为效果对象的怪兽是否属于对方场上且可被无效
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	-- 检查对方场上是否存在表侧表示可被无效的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择要无效的效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上的1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果发动的实际操作：无效怪兽效果，若盖放发动则额外无效相同纵列魔陷
function c10045474.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 阻断并重置被选怪兽的相关连锁状态
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效化直到回合结束
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽发动的效果无效化直到回合结束
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if not c:IsStatus(STATUS_ACT_FROM_HAND) and c:IsLocation(LOCATION_SZONE) then
			-- 纵列无效效果：使该纵列的其他魔法·陷阱卡在回合结束前效果无效
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD)
			e4:SetCode(EFFECT_DISABLE)
			e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
			e4:SetTarget(c10045474.distg)
			e4:SetReset(RESET_PHASE+PHASE_END)
			e4:SetLabel(c:GetSequence(),c:GetFieldID())
			-- 注册同纵列魔陷无效效果
			Duel.RegisterEffect(e4,tp)
			-- 纵列无效监听：在同纵列其他魔法·陷阱发动效果处理时进行无效
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e5:SetCode(EVENT_CHAIN_SOLVING)
			e5:SetOperation(c10045474.disop)
			e5:SetReset(RESET_PHASE+PHASE_END)
			e5:SetLabel(c:GetSequence())
			-- 注册同纵列连锁无效监听效果
			Duel.RegisterEffect(e5,tp)
			-- 纵列陷阱怪兽无效效果：使同纵列陷阱怪兽效果无效
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_FIELD)
			e6:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e6:SetTarget(c10045474.distg)
			e6:SetReset(RESET_PHASE+PHASE_END)
			e6:SetLabel(c:GetSequence())
			-- 注册对同纵列陷阱怪兽的无效化效果
			Duel.RegisterEffect(e6,tp)
			-- 在场上高亮显示本卡所在的纵列位置
			Duel.Hint(HINT_ZONE,tp,0x1<<(c:GetSequence()+8))
		end
	end
end
-- 同纵列魔陷无效效果的目标过滤器
function c10045474.distg(e,c)
	local seq,fid=e:GetLabel()
	local tp=e:GetHandlerPlayer()
	-- 检查目标卡片是否是同纵列的其他魔法或陷阱卡
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.GetColumn(c,tp)==seq and c:GetFieldID()~=fid
end
-- 同纵列连锁无效效果的实际处理：执行效果无效
function c10045474.disop(e,tp,eg,ep,ev,re,r,rp)
	local tseq=e:GetLabel()
	-- 获取触发连锁效果的卡片的发动位置等信息
	local controller,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if loc&LOCATION_SZONE~=0 and seq<=4 and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and ((controller==tp and seq==tseq) or (controller==1-tp and seq==4-tseq)) then
		-- 使该效果的处理无效化
		Duel.NegateEffect(ev)
	end
end
-- 从手卡发动的条件检查
function c10045474.handcon(e)
	-- 确认自己场上的卡片数量是否为0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end

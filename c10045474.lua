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
-- 效果发动准备：检查是否存在满足条件的对方场上表侧表示怪兽并进行确认，将其设为效果的对象
function c10045474.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 如果是效果处理中途的判定，则检查被选为对象的怪兽是否仍然在场上表侧表示且未被无效
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	-- 检查对方场上是否存在至少1只表侧表示且未被无效的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 在提示框显示“请选择要无效的卡”的系统提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择对方场上1只表侧表示且未被无效的效果怪兽作为效果的对象
	Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果的执行：使作为对象的怪兽效果无效，若此卡是从魔陷区发动，则在本回合内将相同纵列的其它魔陷效果及陷阱怪兽效果无效
function c10045474.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的怪兽卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与目标卡片相关的连锁都无效化，若变里侧则重置
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
			-- 向系统注册此相同纵列魔陷无效的区域效果
			Duel.RegisterEffect(e4,tp)
			-- 盖放的这张卡发动的场合，再在这个回合中让和这张卡相同纵列的其他的魔法·陷阱卡的效果无效化。
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e5:SetCode(EVENT_CHAIN_SOLVING)
			e5:SetOperation(c10045474.disop)
			e5:SetReset(RESET_PHASE+PHASE_END)
			e5:SetLabel(c:GetSequence())
			-- 向系统注册相同纵列的魔陷卡在连锁解决时效果无效的持续效果
			Duel.RegisterEffect(e5,tp)
			-- 盖放的这张卡发动的场合，再在这个回合中让和这张卡相同纵列的其他的魔法·陷阱卡的效果无效化。
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_FIELD)
			e6:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e6:SetTarget(c10045474.distg)
			e6:SetReset(RESET_PHASE+PHASE_END)
			e6:SetLabel(c:GetSequence())
			-- 向系统注册相同纵列陷阱怪兽效果无效的持续效果
			Duel.RegisterEffect(e6,tp)
			-- 向玩家提示当前在相同纵列生效的无效化区域
			Duel.Hint(HINT_ZONE,tp,0x1<<(c:GetSequence()+8))
		end
	end
end
-- 相同纵列卡片过滤：判断卡片是否为同一纵列且非该卡本身的魔法或陷阱卡
function c10045474.distg(e,c)
	local seq,fid=e:GetLabel()
	local tp=e:GetHandlerPlayer()
	-- 返回是否为与这张卡同一纵列且非该卡本身的魔法或陷阱卡
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.GetColumn(c,tp)==seq and c:GetFieldID()~=fid
end
-- 相同纵列连锁无效的处理：获取正在结算的连锁位置，若属于相同纵列的魔陷效果则将其无效
function c10045474.disop(e,tp,eg,ep,ev,re,r,rp)
	local tseq=e:GetLabel()
	-- 获取触发连锁的卡片的控制者、发动位置和所在区域序号
	local controller,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if loc&LOCATION_SZONE~=0 and seq<=4 and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and ((controller==tp and seq==tseq) or (controller==1-tp and seq==4-tseq)) then
		-- 使指定连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
-- 手牌发动条件：自己场上没有任何卡存在
function c10045474.handcon(e)
	-- 返回自己场上在场上存在的卡片数量是否为0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end

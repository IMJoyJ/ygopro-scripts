--無限泡影
-- 效果：
-- 自己场上没有卡存在的场合，这张卡的发动从手卡也能用。
-- ①：以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。盖放的这张卡发动的场合，再在这个回合中让和这张卡相同纵列的其他的魔法·陷阱卡的效果无效化。
function c10045474.initial_effect(c)
	-- 创建效果，设置类别为无效化，类型为激活，属性为卡片对象，编码为自由连锁，提示时机为怪兽正面场上，设置目标函数为c10045474.target，操作函数为c10045474.activate，将效果注册到卡片。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c10045474.target)
	e1:SetOperation(c10045474.activate)
	c:RegisterEffect(e1)
	-- 创建效果，描述为“适用「无限泡影」的效果来发动”，类型为单次触发，编码为陷阱从手牌发动，设置条件为c10045474.handcon，将效果注册到卡片。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10045474,0))  --"适用「无限泡影」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c10045474.handcon)
	c:RegisterEffect(e2)
end
-- 定义目标函数c10045474.target，用于选择无效化对象。该函数首先检查是否正在选择（chkc），如果是则返回目标卡片是否在怪兽区、属于对方玩家且可以被无效化。如果不是选择阶段（chk==0），则返回是否存在满足条件的卡片。最后提示玩家选择要无效化的卡片，并执行选择操作。
function c10045474.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查当前正在选择的卡片是否在怪兽区域，并且是对方控制的，以及是否可以通过aux.NegateMonsterFilter过滤函数进行筛选。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	-- 检查是否存在满足aux.NegateMonsterFilter过滤器的卡片在怪兽区域。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择要无效化的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 执行卡片选择操作，使用aux.NegateMonsterFilter作为过滤器，选择一张位于怪兽区的对方控制的、可以被无效化的卡片。
	Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 定义激活函数c10045474.activate，用于处理效果的实际运作。获取触发这张效果的卡片和目标卡片，检查目标卡片是否表侧表示且与效果相关联并且可以被无效化。如果满足条件，则使目标卡片的连锁无效化，并注册两个单次效果：一个禁用目标怪兽的效果，另一个禁用目标怪兽本身。如果这张卡不是从手牌发动并且在魔法陷阱区，则注册额外的场上效果来禁用同一列的魔法陷阱卡。
function c10045474.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中的第一个对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标卡片相关的连锁无效化，并设置重置条件为回合结束时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 创建单次效果，类型为禁用，用于禁用目标怪兽的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 创建单次效果，类型为禁用效果，用于禁用目标怪兽的效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if not c:IsStatus(STATUS_ACT_FROM_HAND) and c:IsLocation(LOCATION_SZONE) then
			-- 如果这张卡不是从手牌发动并且在魔法陷阱区，则注册额外的场上效果来禁用同一列的魔法陷阱卡。
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD)
			e4:SetCode(EFFECT_DISABLE)
			e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
			e4:SetTarget(c10045474.distg)
			e4:SetReset(RESET_PHASE+PHASE_END)
			e4:SetLabel(c:GetSequence(),c:GetFieldID())
			-- 将效果e4注册到玩家tp。
			Duel.RegisterEffect(e4,tp)
			-- 创建持续性场上效果，用于在连锁解决时检查并无效化特定条件下的魔法陷阱卡。
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e5:SetCode(EVENT_CHAIN_SOLVING)
			e5:SetOperation(c10045474.disop)
			e5:SetReset(RESET_PHASE+PHASE_END)
			e5:SetLabel(c:GetSequence())
			-- 将效果e5注册到玩家tp。
			Duel.RegisterEffect(e5,tp)
			-- 创建单次场上效果，类型为禁用怪兽，目标范围为怪兽区，使用c10045474.distg作为目标函数。
			local e6=Effect.CreateEffect(c)
			e6:SetType(EFFECT_TYPE_FIELD)
			e6:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e6:SetTarget(c10045474.distg)
			e6:SetReset(RESET_PHASE+PHASE_END)
			e6:SetLabel(c:GetSequence())
			-- 将效果e6注册到玩家tp。
			Duel.RegisterEffect(e6,tp)
			-- 向玩家发送区域提示信息，高亮显示同一列的卡片。
			Duel.Hint(HINT_ZONE,tp,0x1<<(c:GetSequence()+8))
		end
	end
end
-- 定义辅助函数c10045474.distg，用于确定目标卡片是否在同一列且不为自身。
function c10045474.distg(e,c)
	local seq,fid=e:GetLabel()
	local tp=e:GetHandlerPlayer()
	-- 检查目标卡片是否为魔法或陷阱卡，并且位于与效果触发者相同的纵列，同时排除自身卡片。
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.GetColumn(c,tp)==seq and c:GetFieldID()~=fid
end
-- 定义辅助函数c10045474.disop，用于在连锁解决时无效化特定条件下的魔法陷阱卡。
function c10045474.disop(e,tp,eg,ep,ev,re,r,rp)
	local tseq=e:GetLabel()
	-- 获取连锁的触发玩家、发生位置和序列号。
	local controller,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if loc&LOCATION_SZONE~=0 and seq<=4 and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and ((controller==tp and seq==tseq) or (controller==1-tp and seq==4-tseq)) then
		-- 使当前连锁效果无效化。
		Duel.NegateEffect(ev)
	end
end
-- 定义辅助函数c10045474.handcon，用于判断是否可以从手牌发动这张卡片。
function c10045474.handcon(e)
	-- 检查场上是否有任何卡片存在。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end

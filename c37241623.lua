--紋章の記録
-- 效果：
-- 对方场上的超量怪兽把那超量素材取除来让效果发动时才能发动。那个发动无效并破坏。
function c37241623.initial_effect(c)
	-- 启用全局标记GLOBALFLAG_DETACH_EVENT，使游戏产生超量素材被取除的事件EVENT_DETACH_MATERIAL，以便后续监听。
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	-- 对方场上的超量怪兽把那超量素材取除来让效果发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c37241623.condition)
	e1:SetTarget(c37241623.target)
	e1:SetOperation(c37241623.activate)
	c:RegisterEffect(e1)
	if not c37241623.global_check then
		c37241623.global_check=true
		c37241623[0]=nil
		-- 对方场上的超量怪兽把那超量素材取除来让效果发动时。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DETACH_MATERIAL)
		ge1:SetOperation(c37241623.checkop)
		-- 将全局监测效果ge1注册到全场，持续监听EVENT_DETACH_MATERIAL事件。
		Duel.RegisterEffect(ge1,0)
	end
end
-- checkop函数：当连锁中存在因代价（REASON_COST）取除超量素材的事件时，记录该连锁的ID，供本卡的发动条件判断。
function c37241623.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁序号。
	local cid=Duel.GetCurrentChain()
	if cid>0 and (r&REASON_COST)>0 then
		-- 将当前连锁的唯一标识CHAININFO_CHAIN_ID保存到c37241623[0]，用于确认该连锁是否为对方超量怪兽取除素材发动。
		c37241623[0]=Duel.GetChainInfo(cid,CHAININFO_CHAIN_ID)
	end
end
-- condition函数：判断是否满足发动条件：对方发动效果、该连锁与记录的取除素材连锁相同、发动效果来自超量怪兽、且该发动可以被无效。
function c37241623.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回判断结果：rp==1-tp（对方玩家发动）、当前连锁ID等于记录的取除素材连锁ID、效果类型为超量、发动可被无效。
	return rp==1-tp and Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==c37241623[0] and re:IsActiveType(TYPE_XYZ) and Duel.IsChainNegatable(ev)
end
-- target函数：发动时声明本卡将进行“无效发动”和“破坏”处理，并根据效果来源卡是否仍关联来决定是否登记破坏对象。
function c37241623.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果包含使发动无效（CATEGORY_NEGATE），对象为当前连锁的发动卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：若效果来源卡仍与效果关联，则设置破坏（CATEGORY_DESTROY）的对象及数量。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- activate函数：效果处理时，无效对方那次发动，并破坏那只超量怪兽。
function c37241623.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效那次发动，且该超量怪兽仍与发动的效果关联（未因无效或其他原因离场）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该超量怪兽以效果原因（REASON_EFFECT）破坏。
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end

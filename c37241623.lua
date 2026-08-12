--紋章の記録
-- 效果：
-- 对方场上的超量怪兽把那超量素材取除来让效果发动时才能发动。那个发动无效并破坏。
function c37241623.initial_effect(c)
	-- 启用全局标记EVENT_DETACH_MATERIAL，用于监听超量素材被去除的事件
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	-- 对方场上的超量怪兽把那超量素材取除来让效果发动时才能发动。
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
		-- 那个发动无效并破坏。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DETACH_MATERIAL)
		ge1:SetOperation(c37241623.checkop)
		-- 将效果注册给全局环境，使该效果在场上的所有卡状态变化时触发
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当超量素材被去除时，记录当前连锁ID到全局变量中
function c37241623.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁序号
	local cid=Duel.GetCurrentChain()
	if cid>0 and (r&REASON_COST)>0 then
		-- 将当前连锁的唯一标识ID保存到全局变量中
		c37241623[0]=Duel.GetChainInfo(cid,CHAININFO_CHAIN_ID)
	end
end
-- 判断是否为对方发动的效果，且该效果为超量怪兽效果，且该连锁可被无效
function c37241623.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方玩家发动的连锁，且该连锁ID与记录的ID一致，且发动效果的卡为超量怪兽类型，且该连锁可被无效
	return rp==1-tp and Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==c37241623[0] and re:IsActiveType(TYPE_XYZ) and Duel.IsChainNegatable(ev)
end
-- 设置连锁处理时的操作信息，包括使发动无效和破坏效果
function c37241623.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁操作信息为破坏发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果的处理逻辑，使发动无效并破坏对应卡
function c37241623.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 先使连锁发动无效，再判断发动的卡是否还在场上
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏发动的卡
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end

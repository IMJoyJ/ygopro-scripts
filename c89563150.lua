--白銀のバリア－シルバーフォース－
-- 效果：
-- 对方把给与伤害的陷阱卡发动时才能发动。那个发动无效，那张卡和对方场上表侧表示存在的魔法·陷阱卡全部破坏。
function c89563150.initial_effect(c)
	-- 对方把给与伤害的陷阱卡发动时才能发动。那个发动无效，那张卡和对方场上表侧表示存在的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c89563150.discon)
	e1:SetTarget(c89563150.distg)
	e1:SetOperation(c89563150.disop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：对方发动了给与伤害的陷阱卡，且该发动可以被无效
function c89563150.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 过滤非对方发动、非卡片发动、非陷阱卡、或该发动无法被无效的情况
	if ep==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_TRAP) or not Duel.IsChainNegatable(ev) then return false end
	-- 获取该连锁中关于“给与伤害”的操作信息
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if ex then return true end
	-- 获取该连锁中关于“回复生命值”的操作信息
	ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
	-- 若为回复效果，且受影响的单方玩家适用“回复变伤害”效果，则视为给与伤害的效果
	return ex and ((cp~=PLAYER_ALL and Duel.IsPlayerAffectedByEffect(cp,EFFECT_REVERSE_RECOVER)) or
		-- 若为回复效果，且受影响的双方玩家中至少有一方适用“回复变伤害”效果，则视为给与伤害的效果
		(cp==PLAYER_ALL and (Duel.IsPlayerAffectedByEffect(0,EFFECT_REVERSE_RECOVER) or Duel.IsPlayerAffectedByEffect(1,EFFECT_REVERSE_RECOVER))))
end
-- 过滤对方场上表侧表示的魔法·陷阱卡
function c89563150.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动的目标选择与操作信息设置
function c89563150.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效该陷阱卡的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 获取对方场上所有表侧表示的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c89563150.dfilter,tp,0,LOCATION_ONFIELD,nil)
	if re:GetHandler():IsRelateToEffect(re) then
		g:Merge(eg)
	end
	-- 设置操作信息：破坏被无效发动的卡以及对方场上表侧表示的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：使发动无效，并破坏相关卡片
function c89563150.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效，若成功则继续处理破坏效果
	if Duel.NegateActivation(ev) then
		-- 获取当前对方场上表侧表示的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(c89563150.dfilter,tp,0,LOCATION_ONFIELD,nil)
		if re:GetHandler():IsRelateToEffect(re) then
			g:Merge(eg)
		end
		-- 将目标卡片全部破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end

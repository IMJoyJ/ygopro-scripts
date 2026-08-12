--サイコ・リアクター
-- 效果：
-- 自己场上有念动力族怪兽表侧表示存在的场合才能发动。自己场上表侧表示存在的念动力族怪兽在这个回合和对方怪兽进行过战斗时，把那只念动力族怪兽和对方怪兽从游戏中除外。
function c3146695.initial_effect(c)
	-- 自己场上有念动力族怪兽表侧表示存在的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c3146695.regcon)
	e1:SetOperation(c3146695.regop)
	c:RegisterEffect(e1)
end
-- 检查怪兽是否为表侧表示且种族为念动力
function c3146695.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 判断自己场上是否存在表侧表示的念动力族怪兽
function c3146695.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的念动力族怪兽组
	return Duel.IsExistingMatchingCard(c3146695.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 将场上所有表侧表示的念动力族怪兽登记flag标记，并注册战斗后除外效果和回合结束时清除标记的效果
function c3146695.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足条件的念动力族怪兽组
	local g=Duel.GetMatchingGroup(c3146695.cfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(3146695,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc=g:GetNext()
	end
	g:KeepAlive()
	-- 当战斗发生时，将参与战斗的念动力族怪兽和对方怪兽除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(3146695,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetTarget(c3146695.target)
	e1:SetOperation(c3146695.operation)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabelObject(g)
	-- 注册战斗后除外效果
	Duel.RegisterEffect(e1,tp)
	-- 回合结束时清除标记
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabelObject(g)
	e2:SetOperation(c3146695.reset)
	-- 注册回合结束清除标记效果
	Duel.RegisterEffect(e2,tp)
end
-- 判断怪兽是否具有flag标记且属于指定怪兽组
function c3146695.filter(c,g)
	return c:GetFlagEffect(3146695)>0 and g:IsContains(c)
end
-- 设置连锁处理时的除外操作信息
function c3146695.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	if chk==0 then return d and g:IsExists(c3146695.filter,1,nil,e:GetLabelObject()) end
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 设置除外操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,rg:GetCount(),0,0)
end
-- 执行除外操作
function c3146695.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 将目标怪兽从游戏中除外
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
-- 清除标记组
function c3146695.reset(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():DeleteGroup()
end

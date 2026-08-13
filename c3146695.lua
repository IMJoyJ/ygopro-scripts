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
-- 筛选表侧表示且种族为念动力族的怪兽。
function c3146695.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 发动条件：己方场上存在至少1只表侧表示念动力族怪兽。
function c3146695.regcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少1张满足cfilter条件的表侧念动力族怪兽。
	return Duel.IsExistingMatchingCard(c3146695.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时的处理：获取己方场上所有表侧念动力族怪兽并打上标记，然后设置除外触发效果和结束阶段清理效果。
function c3146695.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上所有表侧念动力族怪兽并存入集合g。
	local g=Duel.GetMatchingGroup(c3146695.cfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(3146695,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc=g:GetNext()
	end
	g:KeepAlive()
	-- 自己场上表侧表示存在的念动力族怪兽在这个回合和对方怪兽进行过战斗时，把那只念动力族怪兽和对方怪兽从游戏中除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(3146695,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetTarget(c3146695.target)
	e1:SetOperation(c3146695.operation)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabelObject(g)
	-- 将除外触发效果e1注册给当前回合玩家，使战斗后满足条件时能够触发。
	Duel.RegisterEffect(e1,tp)
	-- 这个回合（效果在回合结束时重置）。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabelObject(g)
	e2:SetOperation(c3146695.reset)
	-- 将结束阶段的清理效果e2注册给当前回合玩家，用于删除临时标记集合。
	Duel.RegisterEffect(e2,tp)
end
-- 判断卡片是否带有本回合被指定的念动力族怪兽标记，且属于集合g。
function c3146695.filter(c,g)
	return c:GetFlagEffect(3146695)>0 and g:IsContains(c)
end
-- 触发效果的发动时点判定：战斗双方中存在带标记的己方念动力族怪兽时，将战斗双方作为除外对象并设置操作信息。
function c3146695.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取战斗的对方怪兽（攻击目标）。
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	if chk==0 then return d and g:IsExists(c3146695.filter,1,nil,e:GetLabelObject()) end
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 设置除外操作信息：将战斗双方怪兽作为可能除外的对象，数量为rg中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,rg:GetCount(),0,0)
end
-- 效果处理时，将战斗双方怪兽中仍与本次战斗相关的卡从游戏中除外。
function c3146695.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取战斗的攻击怪兽（处理阶段再次获取）。
	local a=Duel.GetAttacker()
	-- 获取战斗的对方怪兽（处理阶段再次获取）。
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	-- 将筛选出的战斗双方怪兽以表侧表示从游戏中除外，原因记为效果。
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
-- 回合结束时删除临时保存的念动力族怪兽集合g，完成清理。
function c3146695.reset(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():DeleteGroup()
end

--タイム・ボマー
-- 效果：
-- 反转：自己的准备阶段把这张卡作为祭品。全部自己的怪兽破坏，给与对方那个总攻击力一半数值的伤害。
function c90020065.initial_effect(c)
	-- 反转：
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c90020065.flipop)
	c:RegisterEffect(e1)
	-- 自己的准备阶段把这张卡作为祭品。全部自己的怪兽破坏，给与对方那个总攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90020065,1))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c90020065.descon)
	e1:SetCost(c90020065.descost)
	e1:SetTarget(c90020065.destg)
	e1:SetOperation(c90020065.desop)
	c:RegisterEffect(e1)
end
-- 反转时的操作：给自身注册一个表示已反转的标记
function c90020065.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(90020065,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 效果发动条件：自身已反转且当前是自己的回合
function c90020065.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否带有反转标记，且当前回合玩家是自己
	return e:GetHandler():GetFlagEffect(90020065)~=0 and Duel.GetTurnPlayer()==tp
end
-- 效果发动代价：检查并解放自身
function c90020065.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果发动目标：获取自己场上的所有怪兽，并设置破坏与伤害的操作信息
function c90020065.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	-- 设置破坏操作信息，包含自己场上的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置伤害操作信息，对象为对方玩家
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 过滤函数：获取卡片在场上表侧表示时的攻击力，若非表侧表示则返回0
function c90020065.damfilter(c)
	if c:IsPreviousPosition(POS_FACEUP) then
		return c:GetPreviousAttackOnField()
	else return 0 end
end
-- 效果处理：破坏自己场上的所有怪兽，并给与对方被破坏怪兽在场上表侧表示时总攻击力一半数值的伤害
function c90020065.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上的所有怪兽
	local g1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	-- 破坏这些怪兽，若没有怪兽被破坏则结束效果处理
	if Duel.Destroy(g1,REASON_EFFECT)==0 then return end
	-- 获取实际被破坏的卡片组
	local og=Duel.GetOperatedGroup()
	local dam=math.floor(og:GetSum(c90020065.damfilter)/2)
	-- 给与对方玩家计算出的伤害
	Duel.Damage(1-tp,dam,REASON_EFFECT)
end

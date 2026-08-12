--闇の護封剣
-- 效果：
-- 这张卡发动后，第2次的自己准备阶段破坏。
-- ①：作为这张卡的发动时的效果处理，对方场上有表侧表示怪兽存在的场合，那些怪兽全部变成里侧守备表示。
-- ②：只要这张卡在魔法与陷阱区域存在，对方场上的怪兽不能把表示形式变更。
function c12923641.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，对方场上有表侧表示怪兽存在的场合，那些怪兽全部变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c12923641.target)
	e1:SetOperation(c12923641.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，对方场上的怪兽不能把表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2)
end
-- 效果处理时的target函数
function c12923641.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	-- 检索对方场上所有可以变为里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
	-- ①：作为这张卡的发动时的效果处理，对方场上有表侧表示怪兽存在的场合，那些怪兽全部变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c12923641.descon)
	e1:SetOperation(c12923641.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	c:RegisterEffect(e1)
end
-- 效果处理时的activate函数
function c12923641.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索对方场上所有可以变为里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将目标怪兽全部变为里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
-- 判断是否为自己的准备阶段
function c12923641.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段破坏效果的处理函数
function c12923641.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 在第2次准备阶段时将此卡破坏
		Duel.Destroy(c,REASON_RULE)
	end
end

--光の護封剣
-- 效果：
-- 这张卡发动后继续留在场上，用对方回合计算的3回合后的对方结束阶段破坏。
-- ①：作为这张卡的发动时的效果处理，对方场上有里侧表示怪兽存在的场合，那些全部变成表侧表示。
-- ②：只要这张卡在魔法与陷阱区域存在，对方怪兽不能攻击宣言。
function c72302403.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，对方场上有里侧表示怪兽存在的场合，那些全部变成表侧表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c72302403.target)
	e1:SetOperation(c72302403.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，对方怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c72302403.atkcon)
	c:RegisterEffect(e2)
	-- 这张卡发动后继续留在场上
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(e3)
end
-- 卡片发动时的效果处理，初始化回合计数器，获取对方场上里侧表示怪兽并设置改变表示形式的操作信息，同时注册3回合后对方结束阶段破坏自身的效果
function c72302403.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():SetTurnCounter(0)
	-- 获取对方场上的里侧表示怪兽
	local sg=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_MZONE,nil)
	-- 设置改变表示形式的操作信息，涉及卡片为对方场上的里侧表示怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
	-- 用对方回合计算的3回合后的对方结束阶段破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(c72302403.descon)
	e1:SetOperation(c72302403.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	e:GetHandler():RegisterEffect(e1)
	e:GetHandler():RegisterFlagEffect(1082946,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,3)
	c72302403[e:GetHandler()]=e1
end
-- 卡片发动时的效果处理，将对方场上所有里侧表示怪兽全部变成表侧表示
function c72302403.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的里侧表示怪兽
	local sg=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		-- 将获取到的里侧表示怪兽全部变成表侧表示（里侧攻击表示变成表侧攻击表示，里侧守备表示变成表侧守备表示）
		Duel.ChangePosition(sg,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
	end
end
-- 破坏效果的触发条件：当前回合玩家为对方（即对方回合）
function c72302403.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return tp~=Duel.GetTurnPlayer()
end
-- 破坏效果的具体处理：累加回合计数器，当计数器达到3时，通过规则将这张卡破坏并重置标记
function c72302403.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==3 then
		-- 因规则原因破坏这张卡
		Duel.Destroy(c,REASON_RULE)
		c:ResetFlagEffect(1082946)
	end
end
-- 攻击限制效果的适用条件：这张卡必须作为魔法卡存在（即在魔法与陷阱区域表侧表示存在）
function c72302403.atkcon(e)
	return e:GetHandler():GetType()==TYPE_SPELL
end

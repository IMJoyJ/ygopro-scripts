--ヒュプノシスター
-- 效果：
-- ①：双方的灵摆区域的卡数量让这张卡得到以下效果。
-- ●1张以上：这张卡的攻击力·守备力上升800。
-- ●2张以上：这张卡和灵摆召唤的怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
-- ●3张以上：对方场上的怪兽可以攻击的场合，必须向这张卡作出攻击。
-- ●4张：这张卡用战斗或者这张卡的效果破坏怪兽的场合发动。自己从卡组抽1张。
function c22200403.initial_effect(c)
	-- 效果原文：●1张以上：这张卡的攻击力·守备力上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	e1:SetCondition(c22200403.effcon)
	e1:SetLabel(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- 效果原文：●2张以上：这张卡和灵摆召唤的怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22200403,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(c22200403.effcon)
	e3:SetTarget(c22200403.destg)
	e3:SetOperation(c22200403.desop)
	e3:SetLabel(2)
	c:RegisterEffect(e3)
	-- 效果原文：●3张以上：对方场上的怪兽可以攻击的场合，必须向这张卡作出攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_MUST_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(c22200403.effcon)
	e4:SetLabel(3)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e5:SetValue(c22200403.atklimit)
	c:RegisterEffect(e5)
	-- 效果原文：●4张：这张卡用战斗或者这张卡的效果破坏怪兽的场合发动。自己从卡组抽1张。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(22200403,1))  --"抽卡"
	e7:SetCategory(CATEGORY_DRAW)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_BATTLE_DESTROYING)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetCondition(c22200403.drcon1)
	e7:SetTarget(c22200403.drtg)
	e7:SetOperation(c22200403.drop)
	e7:SetLabel(4)
	c:RegisterEffect(e7)
	-- 效果原文：●4张：这张卡用战斗或者这张卡的效果破坏怪兽的场合发动。自己从卡组抽1张。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(22200403,1))  --"抽卡"
	e8:SetCategory(CATEGORY_DRAW)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_DESTROYED)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCondition(c22200403.drcon2)
	e8:SetTarget(c22200403.drtg)
	e8:SetOperation(c22200403.drop)
	e8:SetLabel(4)
	c:RegisterEffect(e8)
end
-- 规则层面：判断灵摆区域的卡数量是否满足当前效果的触发条件
function c22200403.effcon(e)
	-- 规则层面：获取双方灵摆区域的卡数量，并与当前效果标签值比较
	return Duel.GetFieldGroupCount(0,LOCATION_PZONE,LOCATION_PZONE)>=e:GetLabel()
end
-- 规则层面：设置破坏效果的目标为战斗中的灵摆召唤怪兽
function c22200403.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsFaceup() and tc:IsSummonType(SUMMON_TYPE_PENDULUM) end
	-- 规则层面：设置连锁操作信息，指定要破坏的目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 规则层面：执行破坏操作，将目标怪兽破坏
function c22200403.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc:IsRelateToBattle() then
		-- 规则层面：调用破坏函数，以效果原因破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 规则层面：设置必须攻击的条件，仅当攻击对象为自身时触发
function c22200403.atklimit(e,c)
	return c==e:GetHandler()
end
-- 规则层面：判断该卡是否参与了战斗并处于有效状态
function c22200403.drcon1(e,tp,eg,ep,ev,re,r,rp)
	return c22200403.effcon(e)
		and e:GetHandler():IsRelateToBattle()
end
-- 规则层面：设置抽卡效果的目标玩家和抽卡数量
function c22200403.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：设置连锁操作的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 规则层面：设置连锁操作的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 规则层面：设置连锁操作信息，指定要进行抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面：执行抽卡操作，从卡组抽取指定数量的卡
function c22200403.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取连锁信息中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面：调用抽卡函数，以效果原因从卡组抽取指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 规则层面：判断是否因效果破坏且破坏者为自身
function c22200403.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return c22200403.effcon(e)
		and bit.band(r,REASON_EFFECT)~=0 and re:GetHandler()==e:GetHandler()
end

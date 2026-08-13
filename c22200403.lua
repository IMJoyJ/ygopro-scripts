--ヒュプノシスター
-- 效果：
-- ①：双方的灵摆区域的卡数量让这张卡得到以下效果。
-- ●1张以上：这张卡的攻击力·守备力上升800。
-- ●2张以上：这张卡和灵摆召唤的怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
-- ●3张以上：对方场上的怪兽可以攻击的场合，必须向这张卡作出攻击。
-- ●4张：这张卡用战斗或者这张卡的效果破坏怪兽的场合发动。自己从卡组抽1张。
function c22200403.initial_effect(c)
	-- ●1张以上：这张卡的攻击力·守备力上升800。
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
	-- ●2张以上：这张卡和灵摆召唤的怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
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
	-- ●3张以上：对方场上的怪兽可以攻击的场合，必须向这张卡作出攻击。
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
	-- ●4张：这张卡用战斗或者这张卡的效果破坏怪兽的场合发动。自己从卡组抽1张。
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
	-- ●4张：或者这张卡的效果破坏怪兽的场合发动。自己从卡组抽1张。
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
-- 作为各效果的通用适用条件，判断双方灵摆区域的卡总数是否不少于效果Label所代表的档位数，从而决定是否适用对应的效果。
function c22200403.effcon(e)
	-- 获取双方灵摆区域卡的总数，并与e:GetLabel()（效果所需的灵摆区数量档位）比较，满足则返回true。
	return Duel.GetFieldGroupCount(0,LOCATION_PZONE,LOCATION_PZONE)>=e:GetLabel()
end
-- 破坏效果的发动条件检测：取得与这张卡战斗的怪兽，若该怪兽表侧表示且是灵摆召唤的怪兽，则允许发动破坏效果。
function c22200403.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsFaceup() and tc:IsSummonType(SUMMON_TYPE_PENDULUM) end
	-- 设置本次连锁的破坏操作信息，将战斗对象指定为可能被破坏的卡，数量为1，用于连锁判定和联动检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果处理时，若战斗对象仍与此次战斗相关，则将其破坏。
function c22200403.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc:IsRelateToBattle() then
		-- 以效果原因破坏战斗对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判定怪兽是否为“催眠妹妹”自身，用于让EFFECT_MUST_ATTACK_MONSTER只指定攻击这张卡。
function c22200403.atklimit(e,c)
	return c==e:GetHandler()
end
-- 战斗破坏怪兽时的抽卡发动条件：灵摆区数量满足4张以上（effcon），且这张卡仍处于战斗相关状态。
function c22200403.drcon1(e,tp,eg,ep,ev,re,r,rp)
	return c22200403.effcon(e)
		and e:GetHandler():IsRelateToBattle()
end
-- 抽卡效果的目标设定：无条件可发动，将抽卡玩家设为发动者，抽卡数量设为1，并写入抽卡操作信息。
function c22200403.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为发动者tp，表示由该玩家抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息，声明本次连锁涉及抽卡，目标玩家为tp，预计抽取1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果处理：从连锁信息中取得对象玩家和抽卡数量，然后执行抽卡。
function c22200403.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家p和对象参数d（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 效果破坏怪兽时的抽卡发动条件：灵摆区数量满足4张以上，且破坏原因包含效果，并且该效果是由这张卡自身发动的。
function c22200403.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return c22200403.effcon(e)
		and bit.band(r,REASON_EFFECT)~=0 and re:GetHandler()==e:GetHandler()
end

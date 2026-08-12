--CNo.88 ギミック・パペット－ディザスター・レオ
-- 效果：
-- 9星怪兽×4
-- 这张卡用以「No.88 机关傀儡-命运狮子」为对象的「升阶魔法」魔法卡的效果才能特殊召唤。自己结束阶段，对方基本分是2000以下而这张卡没有超量素材的场合，自己决斗胜利。
-- ①：场上的这张卡不会成为效果的对象。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。给与对方1000伤害。
function c6165656.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用以「No.88 机关傀儡-命运狮子」为对象的「升阶魔法」魔法卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c6165656.splimit)
	c:RegisterEffect(e1)
	-- ①：场上的这张卡不会成为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。给与对方1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(6165656,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCost(c6165656.cost)
	e3:SetTarget(c6165656.target)
	e3:SetOperation(c6165656.operation)
	c:RegisterEffect(e3)
	-- 自己结束阶段，对方基本分是2000以下而这张卡没有超量素材的场合，自己决斗胜利。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_ADJUST)
	e4:SetOperation(c6165656.winop)
	c:RegisterEffect(e4)
end
-- 设置该怪兽的「No.」数值为88
aux.xyz_number[6165656]=88
-- 特殊召唤限制：必须是由以「No.88 机关傀儡-命运狮子」为对象的「升阶魔法」魔法卡的效果才能特殊召唤
function c6165656.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x95) and se:GetHandler():IsType(TYPE_SPELL)
		and se:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end
-- 发动代价：取除这张卡的1个超量素材
function c6165656.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 伤害效果的发动准备：设置对方玩家为目标并预设造成1000点伤害
function c6165656.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置对方玩家为效果处理的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的参数为1000（伤害数值）
	Duel.SetTargetParam(1000)
	-- 设置连锁的操作信息为：给与对方玩家1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 伤害效果的处理：给与对方玩家1000点伤害
function c6165656.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 决斗胜利效果的处理：在满足条件时判定自己决斗胜利
function c6165656.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_DISASTER_LEO=0x18
	-- 判断当前是否为自己的结束阶段
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_END
		-- 判断对方基本分是否在2000以下，且这张卡没有超量素材
		and Duel.GetLP(1-tp)<=2000 and e:GetHandler():GetOverlayCount()==0 then
		-- 判定自己因「混沌No.88 机关傀儡-灾厄狮子」的效果决斗胜利
		Duel.Win(tp,WIN_REASON_DISASTER_LEO)
	end
end

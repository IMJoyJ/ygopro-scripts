--LL－アセンブリー・ナイチンゲール
-- 效果：
-- 1星怪兽×2只以上
-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
-- ②：这张卡可以直接攻击，持有超量素材的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
-- ③：1回合1次，把这张卡1个超量素材取除才能发动。直到回合结束时，自己场上的「抒情歌鸲」怪兽不会被战斗·效果破坏，自己受到的战斗伤害变成0。这个效果在对方回合也能发动。
function c48608796.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续，要求至少2只1星怪兽作为素材
	aux.AddXyzProcedure(c,nil,1,2,nil,nil,99)
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c48608796.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡可以直接攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)
	-- ②：持有超量素材的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(c48608796.raval)
	c:RegisterEffect(e3)
	-- ③：1回合1次，把这张卡1个超量素材取除才能发动。直到回合结束时，自己场上的「抒情歌鸲」怪兽不会被战斗·效果破坏，自己受到的战斗伤害变成0。这个效果在对方回合也能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(48608796,0))  --"自己的「抒情歌鸲」怪兽不会被破坏"
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START)
	e4:SetCountLimit(1)
	e4:SetCost(c48608796.indcost)
	e4:SetOperation(c48608796.indop)
	c:RegisterEffect(e4)
end
-- 计算攻击力增加值，为超量素材数量乘以200
function c48608796.atkval(e,c)
	return c:GetOverlayCount()*200
end
-- 计算额外攻击次数，为超量素材数量减1（最小为0）
function c48608796.raval(e,c)
	local oc=e:GetHandler():GetOverlayCount()
	return math.max(0,oc-1)
end
-- 支付效果代价，从场上取除1个超量素材
function c48608796.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动效果，使己方场上的抒情歌鸲怪兽不会被战斗和效果破坏，并且受到的战斗伤害变为0
function c48608796.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 创建一个使己方场上的抒情歌鸲怪兽不会被战斗破坏的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果目标为持有抒情歌鸲卡名的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf7))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到游戏中
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 将效果复制并修改为使己方场上的抒情歌鸲怪兽不会被效果破坏
	Duel.RegisterEffect(e2,tp)
	-- 创建一个使自己受到的战斗伤害变为0的效果
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetValue(1)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到游戏中
	Duel.RegisterEffect(e3,tp)
end

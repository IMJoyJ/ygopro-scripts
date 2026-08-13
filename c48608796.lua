--LL－アセンブリー・ナイチンゲール
-- 效果：
-- 1星怪兽×2只以上
-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
-- ②：这张卡可以直接攻击，持有超量素材的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
-- ③：1回合1次，把这张卡1个超量素材取除才能发动。直到回合结束时，自己场上的「抒情歌鸲」怪兽不会被战斗·效果破坏，自己受到的战斗伤害变成0。这个效果在对方回合也能发动。
function c48608796.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加XYZ召唤手续：用任意1星怪兽2只以上作为超量素材进行XYZ召唤，最大素材数为99张。
	aux.AddXyzProcedure(c,nil,1,2,nil,nil,99)
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c48608796.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e2)
	-- 持有超量素材的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
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
-- 攻击力上升的数值计算：此卡每有1个超量素材，攻击力上升200。
function c48608796.atkval(e,c)
	return c:GetOverlayCount()*200
end
-- 额外攻击次数计算：以当前超量素材数减1作为额外攻击次数，至少为0（配合通常攻击正好等于超量素材数量的总攻击次数）。
function c48608796.raval(e,c)
	local oc=e:GetHandler():GetOverlayCount()
	return math.max(0,oc-1)
end
-- 发动代价的检测与支付：若为代价确认（chk==0），检查此卡能否取除1个超量素材作为代价；若为实际支付，则取除1个超量素材。
function c48608796.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理：直到结束阶段，给自己场上所有「抒情歌鸲」怪兽附加不会被战斗或效果破坏的守护，并使自己受到的战斗伤害变成0。
function c48608796.indop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 直到回合结束时，自己场上的「抒情歌鸲」怪兽不会被战斗·效果破坏，自己受到的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 目标筛选：使效果只作用于持有「抒情歌鸲」系列字段（0xf7）的怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf7))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不会被战斗破坏”的场地效果注册到决斗中，持续到结束阶段，保护自己场上符合条件的「抒情歌鸲」怪兽。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 将同一效果的副本改为“不会被效果破坏”后注册，持续到结束阶段。
	Duel.RegisterEffect(e2,tp)
	-- 自己受到的战斗伤害变成0。
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetValue(1)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将“自己受到的战斗伤害变成0”的玩家对象效果注册到决斗中，持续到结束阶段。
	Duel.RegisterEffect(e3,tp)
end

--開運ミラクルストーン
-- 效果：
-- ①：「开运奇迹石」在自己场上只能有1张表侧表示存在。
-- ②：自己场上的魔法师族怪兽的攻击力·守备力上升自己场上的「占卜魔女」怪兽种类×500。
-- ③：1回合1次，自己的「占卜魔女」怪兽进行战斗的攻击宣言时才能发动。自己从卡组抽1张。
function c31461282.initial_effect(c)
	c:SetUniqueOnField(1,0,31461282)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 效果原文内容：②：自己场上的魔法师族怪兽的攻击力·守备力上升自己场上的「占卜魔女」怪兽种类×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 规则层面操作：设置效果目标为场上所有魔法师族怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
	e1:SetValue(c31461282.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- 效果原文内容：③：1回合1次，自己的「占卜魔女」怪兽进行战斗的攻击宣言时才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31461282,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(c31461282.drcon)
	e3:SetTarget(c31461282.drtg)
	e3:SetOperation(c31461282.drop)
	c:RegisterEffect(e3)
end
-- 规则层面操作：判断目标怪兽是否为表侧表示且为「占卜魔女」系列。
function c31461282.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12e)
end
-- 规则层面操作：计算场上「占卜魔女」怪兽数量并乘以500作为攻击力提升值。
function c31461282.atkval(e,c)
	-- 规则层面操作：获取场上符合条件的「占卜魔女」怪兽组。
	local g=Duel.GetMatchingGroup(c31461282.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)*500
end
-- 规则层面操作：判断攻击怪兽或防守怪兽是否为「占卜魔女」系列。
function c31461282.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取此次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 规则层面操作：获取此次战斗的防守怪兽。
	local d=Duel.GetAttackTarget()
	return (a:IsControler(tp) and a:IsSetCard(0x12e)) or (d and d:IsControler(tp) and d:IsFaceup() and d:IsSetCard(0x12e))
end
-- 规则层面操作：设置抽卡效果的目标玩家和抽卡数量。
function c31461282.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查玩家是否可以抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 规则层面操作：设置连锁处理的目标玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 规则层面操作：设置连锁处理的目标参数为抽卡数量1。
	Duel.SetTargetParam(1)
	-- 规则层面操作：设置连锁操作信息为抽卡效果。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面操作：执行抽卡效果。
function c31461282.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取连锁处理的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面操作：让目标玩家从卡组抽指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end

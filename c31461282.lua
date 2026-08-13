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
	-- ②：自己场上的魔法师族怪兽的攻击力上升自己场上的「占卜魔女」怪兽种类×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该永续效果的影响对象为魔法师族怪兽（我方场上的魔法师族怪兽）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
	e1:SetValue(c31461282.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己的「占卜魔女」怪兽进行战斗的攻击宣言时才能发动。自己从卡组抽1张。
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
-- 定义筛选函数：卡牌须为表侧表示且属于「占卜魔女」系列（0x12e）。
function c31461282.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12e)
end
-- 定义攻击力提升数值的计算函数：将我方场上满足过滤条件的「占卜魔女」怪兽按不同卡名计数，种数×500。
function c31461282.atkval(e,c)
	-- 获取我方场上所有表侧表示的「占卜魔女」怪兽（用于统计种类数）。
	local g=Duel.GetMatchingGroup(c31461282.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)*500
end
-- 定义③效果的发动条件：攻击宣言时，攻击怪兽是我方控制的「占卜魔女」怪兽，或被攻击怪兽是我方控制的表侧表示「占卜魔女」怪兽。
function c31461282.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击宣言的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取攻击宣言的被攻击怪兽（若为直接攻击则为nil）。
	local d=Duel.GetAttackTarget()
	return (a:IsControler(tp) and a:IsSetCard(0x12e)) or (d and d:IsControler(tp) and d:IsFaceup() and d:IsSetCard(0x12e))
end
-- 定义③效果的发动时目标处理：检查可抽1张卡，并将抽卡玩家与张数存入连锁信息。
function c31461282.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性判定时，若为确认能否发动，则返回玩家tp是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设为tp，表示抽卡者。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，表示抽卡张数。
	Duel.SetTargetParam(1)
	-- 设置操作信息：该效果属于抽卡分类，不取对象，由tp抽1张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义③效果处理时的操作：取出连锁中记录的对象玩家与张数并实际抽卡。
function c31461282.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家（抽卡者）和对象参数（抽卡张数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽d张卡，完成抽卡。
	Duel.Draw(p,d,REASON_EFFECT)
end

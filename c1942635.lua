--王の報酬
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有衍生物存在，对方不能选择「王战」效果怪兽作为攻击对象。
-- ②：「王战」效果怪兽被战斗破坏的场合发动。对方从卡组抽1张。
function c1942635.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有衍生物存在，对方不能选择「王战」效果怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	-- 判断场上是否存在衍生物作为此效果的发动条件
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(c1942635.atkval)
	c:RegisterEffect(e2)
	-- ②：「王战」效果怪兽被战斗破坏的场合发动。对方从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1942635,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,1942635)
	e3:SetCondition(c1942635.drcon)
	e3:SetTarget(c1942635.drtg)
	e3:SetOperation(c1942635.drop)
	c:RegisterEffect(e3)
end
-- 判断目标怪兽是否为「王战」效果怪兽
function c1942635.atkval(e,c)
	return c:IsFaceup() and c:IsSetCard(0x134) and c:IsType(TYPE_EFFECT)
end
-- 用于筛选被战斗破坏且原本为效果怪兽的「王战」怪兽
function c1942635.cfilter(c)
	return bit.band(c:GetPreviousTypeOnField(),TYPE_EFFECT)~=0 and c:IsPreviousSetCard(0x134)
end
-- 判断被战斗破坏的怪兽中是否存在「王战」效果怪兽
function c1942635.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1942635.cfilter,1,nil)
end
-- 设置对方抽卡的效果处理信息
function c1942635.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息为对方抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
-- 执行对方抽卡的操作
function c1942635.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end

--憑依覚醒
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的怪兽的攻击力上升自己场上的怪兽的属性种类×300。
-- ②：自己场上的「灵使」怪兽以及「凭依装着」怪兽不会被效果破坏。
-- ③：自己场上有原本攻击力是1850的魔法师族怪兽召唤·特殊召唤的场合发动。自己抽1张。
function c62256492.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的怪兽的攻击力上升自己场上的怪兽的属性种类×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(c62256492.atkval)
	c:RegisterEffect(e2)
	-- ②：自己场上的「灵使」怪兽以及「凭依装着」怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c62256492.target)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：自己场上有原本攻击力是1850的魔法师族怪兽召唤·特殊召唤的场合发动。自己抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,62256492)
	e4:SetCondition(c62256492.drcon)
	e4:SetTarget(c62256492.drtg)
	e4:SetOperation(c62256492.drop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 过滤场上表侧表示且具有有效属性的怪兽
function c62256492.atkfilter(c)
	return c:IsFaceup() and c:GetAttribute()~=0
end
-- 计算并返回自己场上怪兽攻击力上升的数值（属性种类数×300）
function c62256492.atkval(e,c)
	-- 获取自己场上所有表侧表示且具有有效属性的怪兽
	local g=Duel.GetMatchingGroup(c62256492.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)
	-- 计算怪兽的不同属性数量并乘以300作为攻击力上升值
	return aux.GetAttributeCount(g)*300
end
-- 过滤属于「灵使」或「凭依装着」系列名卡片的怪兽
function c62256492.target(e,c)
	return c:IsSetCard(0xbf,0x10c0)
end
-- 过滤自己场上表侧表示、原本攻击力为1850的魔法师族怪兽
function c62256492.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsRace(RACE_SPELLCASTER) and c:GetBaseAttack()==1850
end
-- 检查本次召唤·特殊召唤的怪兽中是否存在满足条件的原本攻击力1850的魔法师族怪兽
function c62256492.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c62256492.cfilter,1,nil,tp)
end
-- 抽卡效果的启动与目标设置，设置抽卡玩家为自己、抽卡数量为1张，并声明抽卡操作信息
function c62256492.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 向系统注册当前连锁的操作信息为“玩家tp抽1张卡”
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的执行函数，获取目标玩家和参数并执行抽卡
function c62256492.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡张数参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end

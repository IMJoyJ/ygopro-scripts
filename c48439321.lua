--マドルチェ・ワルツ
-- 效果：
-- 自己场上的名字带有「魔偶甜点」的怪兽进行战斗的伤害计算后，给与对方基本分300分伤害。
function c48439321.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的名字带有「魔偶甜点」的怪兽进行战斗的伤害计算后，给与对方基本分300分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48439321,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c48439321.damcon)
	e2:SetTarget(c48439321.damtg)
	e2:SetOperation(c48439321.damop)
	c:RegisterEffect(e2)
end
-- 定义辅助判断函数：检查怪兽c是否存在、控制者是否为tp，且属于「魔偶甜点」（0x71）字段。
function c48439321.check(c,tp)
	return c and c:IsControler(tp) and c:IsSetCard(0x71)
end
-- 伤害计算后效果的发动条件函数：若攻击怪兽或攻击对象怪兽中存在我方场上的「魔偶甜点」怪兽，则条件满足。
function c48439321.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件判断：攻击方或攻击目标中任意一方是我方场上的「魔偶甜点」怪兽即可。
	return c48439321.check(Duel.GetAttacker(),tp) or c48439321.check(Duel.GetAttackTarget(),tp)
end
-- 效果发动时的目标设定函数：无对象选择条件时直接允许发动；设定伤害对象为对方玩家、伤害数值为300，并登记伤害效果的操作信息。
function c48439321.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为对方玩家（1-tp），即伤害承受方。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设为300，即本次给予的伤害数值。
	Duel.SetTargetParam(300)
	-- 登记本次连锁的操作信息：效果分类为伤害效果，目标为对方玩家，伤害数值为300，因不取对象所以对象卡组设为nil，数量为0。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 效果处理时的操作函数：读取连锁中记录的目标玩家和伤害数值，并执行伤害。
function c48439321.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得目标玩家（CHAININFO_TARGET_PLAYER）和目标参数（CHAININFO_TARGET_PARAM），分别保存到p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害（REASON_EFFECT）为原因，对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end

--マドルチェ・ワルツ
-- 效果：
-- 自己场上的名字带有「魔偶甜点」的怪兽进行战斗的伤害计算后，给与对方基本分300分伤害。
function c48439321.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发必发效果，当自己场上的名字带有「魔偶甜点」的怪兽进行战斗的伤害计算后发动
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
-- 检查目标怪兽是否为控制者且名字带有「魔偶甜点」
function c48439321.check(c,tp)
	return c and c:IsControler(tp) and c:IsSetCard(0x71)
end
-- 判断攻击怪兽或防守怪兽是否为控制者且名字带有「魔偶甜点」
function c48439321.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击怪兽或防守怪兽满足条件时触发效果
	return c48439321.check(Duel.GetAttacker(),tp) or c48439321.check(Duel.GetAttackTarget(),tp)
end
-- 设置效果的处理目标为对方玩家，伤害值为300
function c48439321.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁处理的目标玩家设为对方
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁处理的目标参数设为300
	Duel.SetTargetParam(300)
	-- 设置当前连锁的操作信息为造成300点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 执行效果处理，对对方玩家造成300点伤害
function c48439321.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end

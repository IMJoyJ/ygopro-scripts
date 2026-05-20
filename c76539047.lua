--ポイズン・ファング
-- 效果：
-- 兽族怪兽每次给与对方战斗伤害时，给与对方基本分500分的伤害。
function c76539047.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 兽族怪兽每次给与对方战斗伤害时，给与对方基本分500分的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76539047,0))  --"LP伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c76539047.damcon)
	e2:SetTarget(c76539047.damtg)
	e2:SetOperation(c76539047.damop)
	c:RegisterEffect(e2)
end
-- 确认受到战斗伤害的是对方玩家，且造成伤害的怪兽是兽族怪兽
function c76539047.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():IsRace(RACE_BEAST)
end
-- 设置效果的目标玩家为对方，目标参数为500，并注册伤害操作信息
function c76539047.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数设置为500
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息为给与对方500分伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 获取设定的目标玩家和伤害值，并执行伤害效果
function c76539047.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end

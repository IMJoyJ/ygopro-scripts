--ギャラクシー・ウェーブ
-- 效果：
-- 每次自己超量召唤成功，给与对方基本分500分伤害。
function c77098449.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次自己超量召唤成功，给与对方基本分500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77098449,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c77098449.condition)
	e2:SetTarget(c77098449.target)
	e2:SetOperation(c77098449.operation)
	c:RegisterEffect(e2)
end
-- 判断特殊召唤成功的怪兽是否为自己超量召唤的怪兽
function c77098449.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsSummonType(SUMMON_TYPE_XYZ) and eg:GetFirst():IsControler(tp)
end
-- 设置伤害效果的目标玩家、伤害数值并注册操作信息
function c77098449.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的目标玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的目标参数（伤害值）设置为500
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息为：给与对方玩家500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,500)
end
-- 效果处理：若此卡仍在场，则获取目标玩家与伤害值并给与伤害
function c77098449.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 获取当前连锁中设定的目标玩家和伤害数值
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 给与目标玩家对应的效果伤害
		Duel.Damage(p,d,REASON_EFFECT)
	end
end

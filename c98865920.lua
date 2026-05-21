--アチャチャアーチャー
-- 效果：
-- 这张卡召唤·反转召唤成功时，给与对方基本分500分伤害。
function c98865920.initial_effect(c)
	-- 这张卡召唤成功时，给与对方基本分500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98865920,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c98865920.target)
	e1:SetOperation(c98865920.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 效果发动的目标确认与设置函数
function c98865920.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害的数值为500
	Duel.SetTargetParam(500)
	-- 设置操作信息为给与对方500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理的执行函数
function c98865920.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end

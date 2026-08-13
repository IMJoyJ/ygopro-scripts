--盗人ゴブリン
-- 效果：
-- ①：给与对方500伤害。自己回复500基本分。
function c45311864.initial_effect(c)
	-- ①：给与对方500伤害。自己回复500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DAMAGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c45311864.target)
	e1:SetOperation(c45311864.operation)
	c:RegisterEffect(e1)
end
-- 发动时点处理：无发动条件限制，只要处于自由时点即可发动；同时预设置回复与伤害的操作信息。
function c45311864.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 预设置效果处理时自己要回复500基本分的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
	-- 预设置效果处理时给对方造成500伤害的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理：依次执行给对方伤害、自己回复，并触发伤害/回复后的时点。
function c45311864.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因给与对方玩家（1-tp）500点伤害。
	Duel.Damage(1-tp,500,REASON_EFFECT,true)
	-- 以效果原因使自己（tp）回复500点基本分。
	Duel.Recover(tp,500,REASON_EFFECT,true)
	-- 完成伤害/回复的分解处理后，触发相关时点。
	Duel.RDComplete()
end

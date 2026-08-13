--デスカウンター
-- 效果：
-- 进行直接攻击并对玩家造成战斗伤害的怪兽被破坏。
function c39131963.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 进行直接攻击并对玩家造成战斗伤害的怪兽被破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39131963,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c39131963.condition)
	e2:SetTarget(c39131963.target)
	e2:SetOperation(c39131963.operation)
	c:RegisterEffect(e2)
end
-- 该效果为诱发必发效果，需满足直接攻击并造成战斗伤害的条件才可发动。
function c39131963.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击对象是否不存在（即为直接攻击）。
	return Duel.GetAttackTarget()==nil
end
-- 效果发动时的目标处理：无条件通过，并将造成伤害的怪兽组设为对象，登记破坏操作信息。
function c39131963.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将造成战斗伤害的怪兽组设为当前连锁的对象，使其与效果建立关联。
	Duel.SetTargetCard(eg)
	-- 设置操作信息：本次效果将破坏eg中的1只怪兽，分类为破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 处理效果：取出之前登记的怪兽，若仍与效果有关联则将其破坏。
function c39131963.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将那只怪兽破坏并送入墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

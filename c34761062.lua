--業火の重騎士
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡向特殊召唤的怪兽攻击的伤害步骤开始时才能发动。那只怪兽除外。
function c34761062.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ●这张卡向特殊召唤的怪兽攻击的伤害步骤开始时才能发动。那只怪兽除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34761062,0))  --"除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetCondition(c34761062.descon)
	e4:SetTarget(c34761062.destg)
	e4:SetOperation(c34761062.desop)
	c:RegisterEffect(e4)
end
-- 判断是否满足效果发动条件：卡片处于再召唤状态且为攻击怪兽，且战斗对象是特殊召唤的怪兽并且可以除外
function c34761062.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判断当前攻击怪兽是否为该卡，且该卡处于再召唤状态
	return c:IsDualState() and Duel.GetAttacker()==c
		and bc and bc:IsSummonType(SUMMON_TYPE_SPECIAL) and bc:IsAbleToRemove()
end
-- 设置效果发动时的操作信息，指定将要除外的怪兽
function c34761062.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息中要除外的怪兽为目标
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler():GetBattleTarget(),1,0,0)
end
-- 执行效果操作：将战斗中攻击的特殊召唤怪兽除外
function c34761062.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 将目标怪兽以正面表示形式除外，原因来自效果
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end

--業火の重騎士
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡向特殊召唤的怪兽攻击的伤害步骤开始时才能发动。那只怪兽除外。
function c34761062.initial_effect(c)
	-- 为卡片c赋予二重怪兽属性，使其在场上·墓地当作通常怪兽使用，并可进行再召唤。
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
-- 发动条件判定函数：此卡处于再召唤状态，且作为攻击者向特殊召唤的怪兽攻击，并且该怪兽可被除外时，效果才满足发动条件。
function c34761062.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 判定此卡处于再召唤状态（当作效果怪兽使用），且本次战斗的攻击者为此卡。
	return c:IsDualState() and Duel.GetAttacker()==c
		and bc and bc:IsSummonType(SUMMON_TYPE_SPECIAL) and bc:IsAbleToRemove()
end
-- 发动时的目标处理函数：因为是效果处理时才确定除外对象，所以发动时不需要选择目标，直接允许发动；并将战斗对象登记为效果处理时的除外卡片。
function c34761062.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息：效果类别为除外，目标为当前战斗对象，数量为1，用于后续的连锁响应与效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler():GetBattleTarget(),1,0,0)
end
-- 效果处理函数：取得此卡的战斗对象，若该怪兽仍与本次战斗关联，则将其除外。
function c34761062.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 将战斗对象以表侧表示从游戏中除外。处理原因是效果，单位为正面表示。
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
end

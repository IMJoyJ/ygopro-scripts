--転生炎獣ヴァイオレットキマイラ
-- 效果：
-- 「转生炎兽」怪兽＋连接怪兽
-- ①：这张卡融合召唤的场合才能发动。这张卡的攻击力直到回合结束时上升作为这张卡的融合素材的怪兽的原本攻击力合计数值的一半。
-- ②：这张卡和持有和原本攻击力不同攻击力的怪兽进行战斗的伤害计算时才能发动1次。这张卡的攻击力只在那次伤害计算时变成2倍。
-- ③：和用「转生炎兽 堇色奇美拉」为素材作融合召唤的这张卡进行战斗的怪兽的攻击力只在伤害计算时变成0。
function c37261776.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材必须包含1只「转生炎兽」怪兽和1只连接怪兽，二者各1只即可进行融合召唤。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x119),aux.FilterBoolFunction(Card.IsFusionType,TYPE_LINK),true)
	-- ①：这张卡融合召唤的场合才能发动。这张卡的攻击力直到回合结束时上升作为这张卡的融合素材的怪兽的原本攻击力合计数值的一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37261776,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c37261776.atkcon1)
	e1:SetOperation(c37261776.atkop1)
	c:RegisterEffect(e1)
	-- ②：这张卡和持有和原本攻击力不同攻击力的怪兽进行战斗的伤害计算时才能发动1次。这张卡的攻击力只在那次伤害计算时变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37261776,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c37261776.atkcon2)
	e2:SetCost(c37261776.atkcost2)
	e2:SetOperation(c37261776.atkop2)
	c:RegisterEffect(e2)
	-- ③：和用「转生炎兽 堇色奇美拉」为素材作融合召唤的这张卡进行战斗的怪兽的攻击力只在伤害计算时变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c37261776.regcon)
	e3:SetOperation(c37261776.regop)
	c:RegisterEffect(e3)
	-- 用「转生炎兽 堇色奇美拉」为素材作融合召唤的这张卡（③中的条件部分）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c37261776.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件：这张卡是以融合召唤方式成功特殊召唤的场合才满足。
function c37261776.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①处理：取得这张卡的融合素材，计算全部素材怪兽原本攻击力之和，取其一半（向上取整）作为攻击力上升值，让这张卡的攻击力直到结束阶段上升该数值。
function c37261776.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local g=c:GetMaterial()
	local atk=g:GetSum(Card.GetBaseAttack)
	-- 这张卡的攻击力直到回合结束时上升作为这张卡的融合素材的怪兽的原本攻击力合计数值的一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(math.ceil(atk/2))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 效果②的发动条件：这张卡的战斗对象存在，且该战斗对象的当前攻击力与其原本攻击力不同。
function c37261776.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc~=nil and bc:GetAttack()~=bc:GetBaseAttack()
end
-- 效果②的1回合1次限制：通过检查/设置flag来防止同一次伤害计算阶段中重复发动；标志在伤害计算阶段结束时重置。
function c37261776.atkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(37261776)==0 end
	c:RegisterFlagEffect(37261776,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 效果②处理：若这张卡表侧表示且仍在场上，将这张卡的当前攻击力乘以2，以最终攻击力设定的方式覆盖，持续到伤害计算阶段结束。
function c37261776.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=c:GetAttack()*2
		-- 这张卡的攻击力只在那次伤害计算时变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+RESET_DISABLE+PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
	end
end
-- ③的注册触发条件：这张卡是融合召唤成功，且素材中使用了「转生炎兽 堇色奇美拉」（e:GetLabel()==1）时才允许注册③的场地效果。
function c37261776.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()==1
end
-- ③的注册操作：给这张卡注册一个持续效果，在伤害计算阶段，将其战斗对象的攻击力强制设为0，直到这张卡离场等标准重置条件发生。
function c37261776.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ③：和用「转生炎兽 堇色奇美拉」为素材作融合召唤的这张卡进行战斗的怪兽的攻击力只在伤害计算时变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(c37261776.atkcon3)
	e1:SetTarget(c37261776.atktg3)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 素材检查：检查融合召唤的素材中是否有「转生炎兽 堇色奇美拉」（卡号37261776），有则把e3的Label设为1，否则设为0，用于控制③是否适用。
function c37261776.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsFusionCode,1,nil,37261776) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- ③的场地效果的条件：当前处于伤害计算阶段，并且这张卡存在战斗对象。
function c37261776.atkcon3(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为伤害计算阶段且这张卡有战斗对象时，③的场地效果对战斗对象适用。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and e:GetHandler():GetBattleTarget()
end
-- ③的场地效果的适用对象筛选：只对这张卡的战斗对象生效。
function c37261776.atktg3(e,c)
	return c==e:GetHandler():GetBattleTarget()
end

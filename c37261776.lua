--転生炎獣ヴァイオレットキマイラ
-- 效果：
-- 「转生炎兽」怪兽＋连接怪兽
-- ①：这张卡融合召唤的场合才能发动。这张卡的攻击力直到回合结束时上升作为这张卡的融合素材的怪兽的原本攻击力合计数值的一半。
-- ②：这张卡和持有和原本攻击力不同攻击力的怪兽进行战斗的伤害计算时才能发动1次。这张卡的攻击力只在那次伤害计算时变成2倍。
-- ③：和用「转生炎兽 堇色奇美拉」为素材作融合召唤的这张卡进行战斗的怪兽的攻击力只在伤害计算时变成0。
function c37261776.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，要求融合素材为「转生炎兽」卡组怪兽与连接怪兽各1只
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
	-- 检查融合素材中是否包含「转生炎兽 堇色奇美拉」，若包含则标记为1，否则为0
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c37261776.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 判断此卡是否为融合召唤 summoned
function c37261776.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 若此卡为融合召唤，则计算融合素材的原本攻击力总和，并将其一半向上取整作为攻击力提升值
function c37261776.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local g=c:GetMaterial()
	local atk=g:GetSum(Card.GetBaseAttack)
	-- 将此卡的攻击力提升指定数值，直到回合结束
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(math.ceil(atk/2))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 判断战斗对手的攻击力是否与原本攻击力不同
function c37261776.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc~=nil and bc:GetAttack()~=bc:GetBaseAttack()
end
-- 判断此卡是否已使用过该效果（通过标记判断）
function c37261776.atkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(37261776)==0 end
	c:RegisterFlagEffect(37261776,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 若满足条件，则将此卡的攻击力翻倍
function c37261776.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=c:GetAttack()*2
		-- 将此卡的攻击力设置为指定值，仅在伤害计算时生效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+RESET_DISABLE+PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
	end
end
-- 判断此卡是否为融合召唤且融合素材中包含「转生炎兽 堇色奇美拉」
function c37261776.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()==1
end
-- 注册一个持续效果，使战斗对手的攻击力在伤害计算时变为0
function c37261776.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置一个影响全场怪兽的持续效果，使战斗对手的攻击力在伤害计算时变为0
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
-- 检查融合素材中是否包含「转生炎兽 堇色奇美拉」，并设置标记
function c37261776.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsFusionCode,1,nil,37261776) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断当前阶段是否为伤害计算阶段且此卡有战斗对手
function c37261776.atkcon3(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为伤害计算阶段且此卡有战斗对手
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and e:GetHandler():GetBattleTarget()
end
-- 目标为当前战斗对手
function c37261776.atktg3(e,c)
	return c==e:GetHandler():GetBattleTarget()
end

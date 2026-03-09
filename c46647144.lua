--星遺物－『星槍』
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：包含连接怪兽的怪兽之间进行战斗的伤害计算时，把这张卡从手卡丢弃才能发动。那只进行战斗的对方怪兽的攻击力下降3000。
-- ②：只要这张卡在怪兽区域存在，对方不能向其他的「星遗物」怪兽攻击。
-- ③：从额外卡组有怪兽特殊召唤的场合发动。在双方场上把「星遗物衍生物」（机械族·暗·1星·攻/守0）各1只守备表示特殊召唤。
function c46647144.initial_effect(c)
	-- ①：包含连接怪兽的怪兽之间进行战斗的伤害计算时，把这张卡从手卡丢弃才能发动。那只进行战斗的对方怪兽的攻击力下降3000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46647144,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,46647144)
	e1:SetCondition(c46647144.atkcon)
	e1:SetCost(c46647144.atkcost)
	e1:SetOperation(c46647144.atkop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方不能向其他的「星遗物」怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c46647144.atktg)
	c:RegisterEffect(e2)
	-- ③：从额外卡组有怪兽特殊召唤的场合发动。在双方场上把「星遗物衍生物」（机械族·暗·1星·攻/守0）各1只守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46647144,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,46647145)
	e3:SetCondition(c46647144.tkcon)
	e3:SetTarget(c46647144.tktg)
	e3:SetOperation(c46647144.tkop)
	c:RegisterEffect(e3)
end
-- 判断是否满足效果①的发动条件，即战斗中至少有一只连接怪兽参与攻击或被攻击。
function c46647144.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗中的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取此次战斗中的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	e:SetLabelObject(d)
	local g=Group.FromCards(a,d)
	return a and d and a:IsRelateToBattle() and d:IsRelateToBattle() and g:IsExists(Card.IsType,1,nil,TYPE_LINK)
end
-- 设置效果①的发动代价为将此卡从手牌丢弃。
function c46647144.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡从手牌丢入墓地作为发动代价。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 执行效果①的处理，使对方怪兽攻击力下降3000。
function c46647144.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsRelateToBattle() then
		-- 使对方怪兽攻击力下降3000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 设定效果②的目标为对方场上所有「星遗物」怪兽（不包括自身）。
function c46647144.atktg(e,c)
	return c:IsFaceup() and c:IsSetCard(0xfe) and c~=e:GetHandler()
end
-- 用于筛选发动特殊召唤的怪兽是否来自额外卡组。
function c46647144.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 判断是否有怪兽从额外卡组特殊召唤成功。
function c46647144.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c46647144.cfilter,1,nil,tp)
end
-- 设置效果③的处理信息，准备召唤2只衍生物。
function c46647144.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果③的处理信息，准备召唤2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置效果③的处理信息，准备特殊召唤2只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 检查是否满足效果③的发动条件，包括是否有足够的召唤空间和召唤权限。
function c46647144.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有足够的召唤空间。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查对方场上是否有足够的召唤空间。
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0
		-- 检查己方是否可以特殊召唤衍生物。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,46647145,0xfe,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE)
		-- 检查对方是否可以特殊召唤衍生物。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,46647145,0xfe,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 创建一只「星遗物衍生物」。
	local token1=Duel.CreateToken(tp,46647145)
	-- 创建另一只「星遗物衍生物」。
	local token2=Duel.CreateToken(tp,46647145)
	-- 将第一只衍生物以守备表示特殊召唤到己方场上。
	Duel.SpecialSummonStep(token1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	-- 将第二只衍生物以守备表示特殊召唤到对方场上。
	Duel.SpecialSummonStep(token2,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	-- 完成所有衍生物的特殊召唤流程。
	Duel.SpecialSummonComplete()
end

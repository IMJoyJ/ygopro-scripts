--ハイパーサイコガンナー／バスター
-- 效果：
-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。这张卡进行战斗的场合，伤害步骤结束时给与对方基本分对方怪兽的守备力数值的伤害，自己基本分回复那只怪兽的攻击力的数值。此外，场上存在的这张卡被破坏时，可以把自己墓地存在的1只「超念力枪手」特殊召唤。
function c37169670.initial_effect(c)
	-- 记录该卡具有「爆裂模式」的效果
	aux.AddCodeList(c,80280737)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过「爆裂模式」的效果特殊召唤
	e1:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的场合，伤害步骤结束时给与对方基本分对方怪兽的守备力数值的伤害，自己基本分回复那只怪兽的攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37169670,0))  --"伤害和回复"
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c37169670.damcon)
	e2:SetTarget(c37169670.damtg)
	e2:SetOperation(c37169670.damop)
	c:RegisterEffect(e2)
	-- 此外，场上存在的这张卡被破坏时，可以把自己墓地存在的1只「超念力枪手」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37169670,1))  --"特殊召唤「超念力枪手」"
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c37169670.spcon)
	e3:SetTarget(c37169670.sptg)
	e3:SetOperation(c37169670.spop)
	c:RegisterEffect(e3)
end
c37169670.assault_name=95526884
-- 判断该卡是否参与了战斗且攻击对象存在
function c37169670.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该卡是否参与了战斗且攻击对象存在
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetAttackTarget()~=nil
end
-- 设置伤害和回复效果的处理目标
function c37169670.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前战斗中的攻击对象
	local d=Duel.GetAttackTarget()
	-- 若攻击对象是自身，则获取攻击者
	if d==c then d=Duel.GetAttacker() end
	-- 设置对对方造成伤害的数值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,d:GetDefense())
	-- 设置对自己回复的数值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,d:GetAttack())
end
-- 执行伤害和回复效果
function c37169670.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取伤害效果的处理信息
	local ex1,a1,b1,p1,d1=Duel.GetOperationInfo(0,CATEGORY_DAMAGE)
	-- 获取回复效果的处理信息
	local ex2,a2,b2,p2,d2=Duel.GetOperationInfo(0,CATEGORY_RECOVER)
	-- 对对方造成伤害
	Duel.Damage(1-tp,d1,REASON_EFFECT,true)
	-- 对自己回复生命值
	Duel.Recover(tp,d2,REASON_EFFECT,true)
	-- 完成伤害和回复的处理时点
	Duel.RDComplete()
end
-- 判断该卡是否从场上被破坏
function c37169670.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选墓地中的「超念力枪手」卡片
function c37169670.spfilter(c,e,tp)
	return c:IsCode(95526884) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否可以发动特殊召唤效果
function c37169670.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37169670.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地中是否存在符合条件的「超念力枪手」
		and Duel.IsExistingTarget(c37169670.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的「超念力枪手」作为目标
	local g=Duel.SelectTarget(tp,c37169670.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤效果
function c37169670.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的特殊召唤目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

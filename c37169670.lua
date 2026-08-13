--ハイパーサイコガンナー／バスター
-- 效果：
-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。这张卡进行战斗的场合，伤害步骤结束时给与对方基本分对方怪兽的守备力数值的伤害，自己基本分回复那只怪兽的攻击力的数值。此外，场上存在的这张卡被破坏时，可以把自己墓地存在的1只「超念力枪手」特殊召唤。
function c37169670.initial_effect(c)
	-- 将「爆裂模式」的卡号80280737登记到本卡的代码列表中，用于记录本卡召唤条件中提到的关联卡名。
	aux.AddCodeList(c,80280737)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制判定函数：只有通过「爆裂模式」的效果或爆裂体特殊召唤方式才能特殊召唤本卡。
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
-- 伤害/回复效果的诱发条件：伤害步骤结束时，本卡与战斗相关（仍在场上或已处于战斗破坏状态）且存在攻击对象。
function c37169670.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判定：本卡已处于战斗伤害步骤的结束阶段且存在战斗对象（非直接攻击）。
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetAttackTarget()~=nil
end
-- 伤害/回复效果的发动目标阶段：取对方怪兽的守备力与攻击力，分别设置伤害与回复的操作信息。
function c37169670.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取与本卡战斗的对方怪兽（攻击目标）。
	local d=Duel.GetAttackTarget()
	-- 如果本卡是被攻击方，则将战斗对象改为攻击方怪兽，以保证获得对方怪兽的攻守数值。
	if d==c then d=Duel.GetAttacker() end
	-- 设置给对方造成‘对方怪兽的守备力数值’伤害的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,d:GetDefense())
	-- 设置自己回复‘那只怪兽的攻击力数值’的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,d:GetAttack())
end
-- 效果处理：从操作信息中读取伤害/回复数值，并对对方造成伤害、自己回复，然后完成时点处理。
function c37169670.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出之前设置的伤害数值d1。
	local ex1,a1,b1,p1,d1=Duel.GetOperationInfo(0,CATEGORY_DAMAGE)
	-- 取出之前设置的回复数值d2。
	local ex2,a2,b2,p2,d2=Duel.GetOperationInfo(0,CATEGORY_RECOVER)
	-- 对对方玩家造成d1点伤害（效果伤害）。
	Duel.Damage(1-tp,d1,REASON_EFFECT,true)
	-- 为自己回复d2点LP（效果回复）。
	Duel.Recover(tp,d2,REASON_EFFECT,true)
	-- 完成伤害/回复的分段处理，触发相关时点。
	Duel.RDComplete()
end
-- 场上存在的此卡被破坏并送去墓地时，该效果可以发动；判定其破坏前所在位置为场上。
function c37169670.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选可特殊召唤的对象：卡名必须为「超念力枪手」（95526884），且当前可以被特殊召唤。
function c37169670.spfilter(c,e,tp)
	return c:IsCode(95526884) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动目标阶段：检查空位与墓地对象，若可发动则选择1只符合条件的超念力枪手作为对象并设置特召信息。
function c37169670.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37169670.spfilter(chkc,e,tp) end
	-- 发动条件：自己场上主要怪兽区域存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件：自己墓地存在至少1张符合条件的「超念力枪手」可供选择。
		and Duel.IsExistingTarget(c37169670.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1张符合条件的「超念力枪手」，并将其设为效果的对象。
	local g=Duel.SelectTarget(tp,c37169670.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤操作信息，表示效果处理时将把选中的对象特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若选择的对象仍与效果关联，则将其特殊召唤到自己场上。
function c37169670.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出本次效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到自己场上（不限制召唤方式）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

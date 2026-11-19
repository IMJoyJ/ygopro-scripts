--ジャイアント・タコーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡守备表示特殊召唤，那只对方怪兽的攻击对象转移为这张卡进行伤害计算。
-- ②：以「巨型章玉米」以外的自己场上1只植物族怪兽为对象才能发动。那只怪兽和这张卡的攻击力变成那2只的原本攻击力合计数值。
local s,id,o=GetID()
-- 初始化卡片效果：注册对方攻击宣言时从手卡特召并转移攻击进行伤害计算的①效果，以及与自己场上植物族怪兽合计原本攻击力的②效果，各限制1回合1次。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：对方怪兽的攻击宣言时才能发动。这张卡从手卡守备表示特殊召唤，那只对方怪兽的攻击对象转移为这张卡进行伤害计算。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：以「巨型章玉米」以外的自己场上1只植物族怪兽为对象才能发动。那只怪兽和这张卡的攻击力变成那2只的原本攻击力合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力变化"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：检查当前攻击宣言的怪兽控制者是否为对方。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前攻击怪兽的控制者是否不等于自己（即为对方怪兽攻击）。
	return Duel.GetAttacker():GetControler()~=tp
end
-- ①效果的目标处理函数（可行性检测部分）：检查自己怪兽区是否有空位且手卡的这张卡能表侧守备表示特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动可行性检测：检查自己怪兽区域是否至少有1个可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：预计将手卡中的这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的效果处理函数：将手卡中的这张卡表侧守备表示特殊召唤，若攻击怪兽仍可攻击且不受本效果影响则让其与这张卡进行伤害计算。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次攻击宣言的对方怪兽。
	local a=Duel.GetAttacker()
	-- 若这张卡特召成功，且攻击怪兽仍可攻击并不免疫此效果，则准备转移攻击进行伤害计算。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 and a:IsAttackable() and not a:IsImmuneToEffect(e) then
		-- 让对方攻击怪兽与特殊召唤出场的这张卡直接进行战斗伤害计算。
		Duel.CalculateDamage(a,c)
	end
end
-- 过滤函数：判断怪兽是否为表侧表示的「巨型章玉米」以外的植物族怪兽，且与这张卡的原本攻击力之和大于0。
function s.atkfilter(c,ac)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and not c:IsCode(id) and c~=ac and c:GetBaseAttack()+ac:GetBaseAttack()>0
end
-- ②效果的对象选择与目标处理函数：选取「巨型章玉米」以外自己场上1只符合条件的植物族怪兽作为对象。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc~=c and chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc,c) end
	-- 发动可行性检测：检查自己场上是否存在至少1只符合条件的其他植物族怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,c,c) end
	-- 向自己发送选择提示，提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只「巨型章玉米」以外的植物族怪兽作为对象。
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,c,c)
end
-- ②效果的效果处理函数：若这张卡与对象怪兽均表侧存在且与效果有联系，则将两者的攻击力都设定为它们原本攻击力的合计数值。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁指定的对象植物族怪兽卡。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=c:GetBaseAttack()+tc:GetBaseAttack()
		-- 那只怪兽和这张卡的攻击力变成那2只的原本攻击力合计数值。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
		-- 那只怪兽和这张卡的攻击力变成那2只的原本攻击力合计数值。
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end

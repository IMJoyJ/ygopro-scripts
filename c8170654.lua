--ジャイアント・タコーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡守备表示特殊召唤，那只对方怪兽的攻击对象转移为这张卡进行伤害计算。
-- ②：以「巨型章玉米」以外的自己场上1只植物族怪兽为对象才能发动。那只怪兽和这张卡的攻击力变成那2只的原本攻击力合计数值。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手卡特召并转移攻击对象）和②效果（与场上其他植物族怪兽合计原本攻击力）。
function s.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。这张卡从手卡守备表示特殊召唤，那只对方怪兽的攻击对象转移为这张卡进行伤害计算。
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
	-- ②：以「巨型章玉米」以外的自己场上1只植物族怪兽为对象才能发动。那只怪兽和这张卡的攻击力变成那2只的原本攻击力合计数值。
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
-- 效果①的发动条件：对方怪兽进行攻击宣言时。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击怪兽的控制者是否为对方。
	return Duel.GetAttacker():GetControler()~=tp
end
-- 效果①的发动准备与合法性检测：检查自身是否能从手卡守备表示特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁处理中的操作信息为特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：将这张卡特殊召唤，并强制与对方攻击怪兽进行伤害计算。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前进行攻击宣言的对方怪兽。
	local a=Duel.GetAttacker()
	-- 检查自身是否成功守备表示特殊召唤，且对方怪兽仍可攻击、未对该效果免疫。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 and a:IsAttackable() and not a:IsImmuneToEffect(e) then
		-- 强制使对方攻击怪兽与这张卡进行伤害计算（转移攻击对象）。
		Duel.CalculateDamage(a,c)
	end
end
-- 过滤条件：自己场上表侧表示的、「巨型章玉米」以外的植物族怪兽，且两者的原本攻击力合计大于0。
function s.atkfilter(c,ac)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and not c:IsCode(id) and c~=ac and c:GetBaseAttack()+ac:GetBaseAttack()>0
end
-- 效果②的发动准备与对象选择：选择自己场上1只满足条件的植物族怪兽。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc~=c and chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
	-- 检查自己场上是否存在除自身以外的、满足条件的植物族怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,c,c) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择并锁定1只自己场上的植物族怪兽作为效果对象。
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,c,c)
end
-- 效果②的效果处理：计算两只怪兽的原本攻击力合计数值，并将两者的攻击力都变成该合计数值。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果②选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=c:GetBaseAttack()+tc:GetBaseAttack()
		-- 这张卡的攻击力变成那2只的原本攻击力合计数值。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
		-- 那只怪兽的攻击力变成那2只的原本攻击力合计数值。
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end

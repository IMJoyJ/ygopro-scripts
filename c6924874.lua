--ハーピィズペット仔竜
-- 效果：
-- 这张卡追加自己场上存在的除「鹰身女妖的宠物仔龙」以外的名字带有「鹰身」的怪兽的数量的效果。
-- ●1只：只要这张卡在场上表侧表示存在，对方不能选择自己场上存在的除「鹰身女妖的宠物仔龙」以外的名字带有「鹰身」的怪兽作为攻击对象。
-- ●2只：这张卡的原本攻击力·守备力变成2倍。
-- ●3只：1回合1次，可以把对方场上的1张卡破坏。
function c6924874.initial_effect(c)
	-- ●1只：只要这张卡在场上表侧表示存在，对方不能选择自己场上存在的除「鹰身女妖的宠物仔龙」以外的名字带有「鹰身」的怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c6924874.atlimit)
	c:RegisterEffect(e1)
	-- ●2只：这张卡的原本攻击力·守备力变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetCondition(c6924874.adcon)
	e2:SetValue(c6924874.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_BASE_DEFENSE)
	e3:SetValue(c6924874.defval)
	c:RegisterEffect(e3)
	-- ●3只：1回合1次，可以把对方场上的1张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(6924874,0))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(c6924874.descon)
	e4:SetTarget(c6924874.destg)
	e4:SetOperation(c6924874.desop)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示存在的除「鹰身女妖的宠物仔龙」以外的「鹰身」怪兽
function c6924874.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x64) and not c:IsCode(6924874)
end
-- 攻击限制：不能选择自己场上表侧表示存在的除「鹰身女妖的宠物仔龙」以外的「鹰身」怪兽作为攻击对象
function c6924874.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x64) and not c:IsCode(6924874)
end
-- 原本攻守翻倍效果的适用条件：自己场上存在2只以上除「鹰身女妖的宠物仔龙」以外的「鹰身」怪兽
function c6924874.adcon(e)
	-- 检查自己场上是否存在至少2只除「鹰身女妖的宠物仔龙」以外的表侧表示「鹰身」怪兽
	return Duel.IsExistingMatchingCard(c6924874.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil)
end
-- 原本攻击力数值变为原本数值的2倍
function c6924874.atkval(e,c)
	return c:GetBaseAttack()*2
end
-- 原本守备力数值变为原本数值的2倍
function c6924874.defval(e,c)
	return c:GetBaseDefense()*2
end
-- 破坏效果的发动条件：自己场上存在3只以上除「鹰身女妖的宠物仔龙」以外的表侧表示「鹰身」怪兽
function c6924874.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少3只除「鹰身女妖的宠物仔龙」以外的表侧表示「鹰身」怪兽
	return Duel.IsExistingMatchingCard(c6924874.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,3,nil)
end
-- 破坏效果的发动准备（选择要破坏的卡并设置操作信息）
function c6924874.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 在效果发动阶段，检查对方场上是否存在至少1张可以作为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 在屏幕上显示提示信息，要求玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理的操作信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的实际处理（破坏选中的卡）
function c6924874.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

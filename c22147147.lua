--旋風剣
-- 效果：
-- 名字带有「命运英雄」的怪兽才能装备。装备怪兽进行攻击的场合，那个伤害步骤结束时把场上1张魔法或者陷阱卡破坏。
function c22147147.initial_effect(c)
	-- 名字带有「命运英雄」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c22147147.target)
	e1:SetOperation(c22147147.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽进行攻击的场合，那个伤害步骤结束时把场上1张魔法或者陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c22147147.eqlimit)
	c:RegisterEffect(e2)
	-- 效果作用
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22147147,0))  --"魔陷破坏"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c22147147.descon)
	e3:SetTarget(c22147147.destg)
	e3:SetOperation(c22147147.desop)
	c:RegisterEffect(e3)
end
-- 限制只能装备到名字带有「命运英雄」的怪兽身上
function c22147147.eqlimit(e,c)
	return c:IsSetCard(0xc008)
end
-- 判断目标是否为名字带有「命运英雄」且表侧表示的怪兽
function c22147147.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc008)
end
-- 选择装备对象，要求是名字带有「命运英雄」且表侧表示的怪兽
function c22147147.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c22147147.filter(chkc) end
	-- 判断是否存在名字带有「命运英雄」且表侧表示的怪兽作为装备对象
	if chk==0 then return Duel.IsExistingTarget(c22147147.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择名字带有「命运英雄」且表侧表示的怪兽作为装备对象
	Duel.SelectTarget(tp,c22147147.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给选中的怪兽
function c22147147.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断是否为装备怪兽进行攻击的伤害步骤结束时
function c22147147.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽是否为装备卡的装备对象
	return Duel.GetAttacker()==e:GetHandler():GetEquipTarget()
end
-- 判断目标是否为魔法或陷阱卡
function c22147147.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 选择场上1张魔法或陷阱卡作为破坏对象
function c22147147.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c22147147.desfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的魔法或陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法或陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c22147147.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏操作，将选中的魔法或陷阱卡破坏
function c22147147.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标魔法或陷阱卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

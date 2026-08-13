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
	-- 名字带有「命运英雄」的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c22147147.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽进行攻击的场合，那个伤害步骤结束时把场上1张魔法或者陷阱卡破坏。
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
-- 检查目标怪兽是否为名字带有「命运英雄」的怪兽，只有满足条件的怪兽才能被这张卡装备。
function c22147147.eqlimit(e,c)
	return c:IsSetCard(0xc008)
end
-- 过滤出表侧表示且名字带有「命运英雄」的怪兽，作为可装备对象。
function c22147147.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc008)
end
-- 装备魔法发动时的目标选择处理：从场上选择1只符合条件的怪兽作为装备对象，并设置装备操作信息。
function c22147147.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c22147147.filter(chkc) end
	-- 发动时检查场上是否存在至少1只表侧表示且名字带有「命运英雄」的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c22147147.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，告知玩家‘请选择要装备的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方怪兽区域选择1只表侧表示且名字带有「命运英雄」的怪兽作为装备对象。
	Duel.SelectTarget(tp,c22147147.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前操作为装备效果，指定装备对象为这张装备魔法卡本身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若装备卡和目标怪兽仍与效果关联且目标怪兽表侧表示，则将这张卡装备给目标怪兽。
function c22147147.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备魔法卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 破坏效果的发动条件：当前进行攻击的怪兽正是这张装备卡的装备对象。
function c22147147.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前攻击怪兽是否为这张装备卡的装备对象。
	return Duel.GetAttacker()==e:GetHandler():GetEquipTarget()
end
-- 过滤场上的魔法或陷阱卡，作为可被破坏的对象。
function c22147147.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的目标选择：选择场上1张魔法或陷阱卡，并设置破坏操作信息。
function c22147147.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c22147147.desfilter(chkc) end
	if chk==0 then return true end
	-- 弹出选择提示，告知玩家‘请选择要破坏的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张魔法或陷阱卡作为破坏对象。
	local g=Duel.SelectTarget(tp,c22147147.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前操作为破坏效果，破坏对象为所选卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，若破坏对象仍与效果关联，则将其破坏。
function c22147147.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的破坏对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--ヴァイロン・ディシグマ
-- 效果：
-- 4星怪兽×3
-- 1回合1次，可以把这张卡1个超量素材取除，选择对方场上表侧攻击表示存在的1只效果怪兽当作装备卡使用给这张卡装备。这张卡和与这个效果装备的怪兽卡相同属性的怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。
function c39987164.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用满足条件的4星怪兽3只进行叠放
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- 1回合1次，可以把这张卡1个超量素材取除，选择对方场上表侧攻击表示存在的1只效果怪兽当作装备卡使用给这张卡装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39987164,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c39987164.eqcost)
	e1:SetTarget(c39987164.eqtg)
	e1:SetOperation(c39987164.eqop)
	c:RegisterEffect(e1)
	-- 这张卡和与这个效果装备的怪兽卡相同属性的怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39987164,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c39987164.descon)
	e2:SetTarget(c39987164.destg)
	e2:SetOperation(c39987164.desop)
	c:RegisterEffect(e2)
end
-- 支付1个超量素材作为费用
function c39987164.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选对方场上表侧攻击表示存在的效果怪兽
function c39987164.filter(c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsType(TYPE_EFFECT) and c:IsAbleToChangeControler()
end
-- 设置效果目标，选择对方场上表侧攻击表示存在的1只效果怪兽
function c39987164.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c39987164.filter(chkc) end
	-- 判断玩家场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断对方场上是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c39987164.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c39987164.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 设置装备对象限制，只能装备给该卡
function c39987164.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 执行装备操作，将目标怪兽装备给自身
function c39987164.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsAttackPos() and tc:IsRelateToEffect(e) then
		-- 尝试将目标怪兽装备给自身，若失败则返回
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(39987164,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 为装备怪兽设置装备对象限制效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c39987164.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 筛选已装备且属性匹配的怪兽
function c39987164.desfilter(c,att)
	return c:GetFlagEffect(39987164)~=0 and c:IsAttribute(att)
end
-- 判断战斗开始时攻击怪兽的属性是否与装备怪兽属性一致
function c39987164.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前攻击的怪兽
	local dt=Duel.GetAttacker()
	-- 若攻击怪兽为自身，则获取攻击目标怪兽
	if dt==c then dt=Duel.GetAttackTarget() end
	if not dt or dt:IsFacedown() then return false end
	e:SetLabelObject(dt)
	local att=dt:GetAttribute()
	return c:GetEquipGroup():IsExists(c39987164.desfilter,1,nil,att)
end
-- 设置破坏效果的目标信息
function c39987164.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 执行破坏操作，将目标怪兽破坏
function c39987164.desop(e,tp,eg,ep,ev,re,r,rp)
	local dt=e:GetLabelObject()
	if dt:IsRelateToBattle() then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(dt,REASON_EFFECT)
	end
end

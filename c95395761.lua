--甲虫装機 アーマイゼ
-- 效果：
-- 1回合1次，可以从自己的手卡·墓地把1只名字带有「甲虫装机」的怪兽当作装备卡使用给这张卡装备。这张卡当作装备卡使用而装备中的场合，装备怪兽的等级上升3星，攻击力·守备力上升这张卡的各自数值。装备怪兽被破坏的场合，可以作为代替把这张卡破坏。
function c95395761.initial_effect(c)
	-- 1回合1次，可以从自己的手卡·墓地把1只名字带有「甲虫装机」的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(95395761,0))  --"装备"
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c95395761.eqtg)
	e1:SetOperation(c95395761.eqop)
	c:RegisterEffect(e1)
	-- 攻击力·守备力上升这张卡的各自数值
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(200)
	c:RegisterEffect(e2)
	-- 攻击力·守备力上升这张卡的各自数值
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(600)
	c:RegisterEffect(e3)
	-- 装备怪兽的等级上升3星
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_LEVEL)
	e4:SetValue(3)
	c:RegisterEffect(e4)
	-- 装备怪兽被破坏的场合，可以作为代替把这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetTarget(c95395761.reptg)
	e5:SetOperation(c95395761.repop)
	c:RegisterEffect(e5)
end
-- 过滤条件：手卡·墓地中名字带有「甲虫装机」的怪兽
function c95395761.filter(c)
	return c:IsSetCard(0x56) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 装备效果的发动准备：检查魔陷区是否有空位，以及手卡·墓地是否存在可装备的「甲虫装机」怪兽
function c95395761.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，判断自己魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 在发动检查阶段，判断自己的手卡或墓地是否存在至少1只满足过滤条件的「甲虫装机」怪兽
		and Duel.IsExistingMatchingCard(c95395761.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 设置效果处理信息：涉及从墓地移出卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 装备效果的执行：将手卡·墓地的一只「甲虫装机」怪兽作为装备卡装备给此卡，并添加装备限制
function c95395761.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若魔陷区已无空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从手卡或墓地选择1张满足条件的「甲虫装机」怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c95395761.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽作为装备卡装备给当前卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c) then return end
		-- 当作装备卡使用给这张卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c95395761.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制函数：限制该装备卡只能装备给当前效果的发动者（即这张卡）
function c95395761.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 代替破坏效果的发动准备：检查自身是否可以被破坏，且装备怪兽不是因为其他代替效果而被破坏
function c95395761.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and not c:GetEquipTarget():IsReason(REASON_REPLACE) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的执行：破坏自身以代替装备怪兽的破坏
function c95395761.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏自身（作为代替破坏的实际动作）
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end

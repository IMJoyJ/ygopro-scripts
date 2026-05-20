--甲虫装機 リュシオル
-- 效果：
-- 1回合1次，可以从自己的手卡·墓地把1只名字带有「甲虫装机」的怪兽当作装备卡使用给这张卡装备。这张卡被名字带有「甲虫装机」的卡装备的场合，可以把对方场上盖放的卡全部确认。此外，这张卡当作装备卡使用而装备中的场合，装备怪兽的等级上升1星，攻击力·守备力上升这张卡的各自数值。
function c66066482.initial_effect(c)
	-- 1回合1次，可以从自己的手卡·墓地把1只名字带有「甲虫装机」的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66066482,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c66066482.eqtg)
	e1:SetOperation(c66066482.eqop)
	c:RegisterEffect(e1)
	-- 此外，这张卡当作装备卡使用而装备中的场合，装备怪兽的等级上升1星
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 攻击力……上升这张卡的各自数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(100)
	c:RegisterEffect(e3)
	-- ……守备力上升这张卡的各自数值。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetValue(100)
	c:RegisterEffect(e4)
	-- 这张卡被名字带有「甲虫装机」的卡装备的场合，可以把对方场上盖放的卡全部确认。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(66066482,1))  --"确认盖卡"
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_EQUIP)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCondition(c66066482.cfcon)
	e5:SetTarget(c66066482.cftg)
	e5:SetOperation(c66066482.cfop)
	c:RegisterEffect(e5)
end
-- 过滤手卡·墓地中满足条件的「甲虫装机」怪兽
function c66066482.filter(c)
	return c:IsSetCard(0x56) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 装备效果的发动准备与可行性检查
function c66066482.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查手卡或墓地是否存在可以装备的「甲虫装机」怪兽
		and Duel.IsExistingMatchingCard(c66066482.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：涉及卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 装备效果的执行：选择并装备怪兽，并添加装备限制
function c66066482.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次检查魔陷区是否有空位，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从手卡或墓地选择1只「甲虫装机」怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c66066482.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽作为装备卡装备给这张卡，若失败则返回
		if not Duel.Equip(tp,tc,c) then return end
		-- 当作装备卡使用给这张卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c66066482.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制：只有在这张卡作为装备卡且未被无效时才持续装备
function c66066482.eqlimit(e,c)
	return e:GetOwner()==c and not c:IsDisabled()
end
-- 过滤出装备在这张卡上的「甲虫装机」卡片
function c66066482.eqfilter(c,ec)
	return c:GetEquipTarget()==ec and c:IsSetCard(0x56)
end
-- 触发条件：检查是否有「甲虫装机」卡片装备到这张卡上
function c66066482.cfcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c66066482.eqfilter,1,nil,e:GetHandler())
end
-- 确认盖卡效果的发动准备与可行性检查
function c66066482.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在盖放的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
end
-- 确认盖卡效果的执行：获取对方场上所有盖放的卡并给玩家确认
function c66066482.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有盖放的卡
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 给玩家确认这些盖放的卡
		Duel.ConfirmCards(tp,g)
	end
end

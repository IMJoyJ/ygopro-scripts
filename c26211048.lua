--甲虫装機 エクサスタッグ
-- 效果：
-- 昆虫族5星怪兽×2
-- 1回合1次，可以把这张卡1个超量素材取除，选择对方的场上·墓地1只怪兽当作装备卡使用给这张卡装备。这张卡的攻击力·守备力上升这个效果装备的怪兽的各自一半数值。
function c26211048.initial_effect(c)
	-- 添加XYZ召唤手续，要求使用满足昆虫族条件的等级为5的怪兽叠放2只以上
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_INSECT),5,2)
	c:EnableReviveLimit()
	-- 1回合1次，可以把这张卡1个超量素材取除，选择对方的场上·墓地1只怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26211048,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c26211048.eqcost)
	e1:SetTarget(c26211048.eqtg)
	e1:SetOperation(c26211048.eqop)
	c:RegisterEffect(e1)
end
-- 支付1个超量素材作为cost
function c26211048.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选目标怪兽的条件：在场上或墓地且不是禁止状态
function c26211048.eqfilter(c)
	return c:IsLocation(LOCATION_MZONE) or c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 设置效果目标，选择对方场上或墓地的1只怪兽作为装备对象
function c26211048.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and chkc:IsControler(1-tp) and c26211048.eqfilter(chkc) end
	-- 判断场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断对方场上或墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c26211048.eqfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 优先从场上选择目标，若无法满足则从墓地选择
	local g=aux.SelectTargetFromFieldFirst(tp,c26211048.eqfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息，记录将要离开墓地的卡
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 执行装备效果，将目标怪兽装备给自身并设置装备限制
function c26211048.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not tc:IsType(TYPE_MONSTER) then return end
	-- 将目标怪兽装备给自身
	if not Duel.Equip(tp,tc,c,false) then return end
	-- 设置装备对象限制，只能装备给自身
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c26211048.eqlimit)
	tc:RegisterEffect(e1)
	if tc:IsFaceup() then
		local atk=math.ceil(tc:GetTextAttack()/2)
		if atk<0 then atk=0 end
		-- 装备怪兽的攻击力上升其一半数值
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		local def=math.ceil(tc:GetTextDefense()/2)
		if def<0 then def=0 end
		-- 装备怪兽的守备力上升其一半数值
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(def)
		tc:RegisterEffect(e3)
	end
end
-- 装备对象限制函数，只能装备给自身
function c26211048.eqlimit(e,c)
	return e:GetOwner()==c
end

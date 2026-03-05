--焔聖騎士－オジエ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「焰圣骑士-奥吉尔」以外的1只战士族·炎属性怪兽或者1张「圣剑」卡送去墓地。
-- ②：这张卡在墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
-- ③：这张卡的装备怪兽不会被效果破坏。
function c21351206.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「焰圣骑士-奥吉尔」以外的1只战士族·炎属性怪兽或者1张「圣剑」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21351206,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,21351206)
	e1:SetTarget(c21351206.tgtg)
	e1:SetOperation(c21351206.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,21351207)
	e3:SetTarget(c21351206.eqtg)
	e3:SetOperation(c21351206.eqop)
	c:RegisterEffect(e3)
	-- ③：这张卡的装备怪兽不会被效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于筛选满足条件的怪兽或卡牌，条件为：战士族且炎属性，或圣剑卡，且不是自身，且能送去墓地。
function c21351206.tgfilter(c)
	return ((c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)) or c:IsSetCard(0x207a)) and not c:IsCode(21351206)
		and c:IsAbleToGrave()
end
-- 效果处理时的判断函数，检查是否满足发动条件，即在卡组中是否存在满足条件的卡牌。
function c21351206.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在卡组中是否存在满足条件的卡牌。
	if chk==0 then return Duel.IsExistingMatchingCard(c21351206.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示将要处理送去墓地的效果。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，提示玩家选择要送去墓地的卡牌，并执行送去墓地的操作。
function c21351206.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择满足条件的卡牌。
	local g=Duel.SelectMatchingCard(tp,c21351206.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡牌送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选满足条件的场上怪兽，条件为：表侧表示且战士族。
function c21351206.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 效果处理时的判断函数，检查是否满足发动条件，即场上是否存在满足条件的怪兽且装备区有空位。
function c21351206.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21351206.eqfilter(chkc) end
	-- 检查装备区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在满足条件的怪兽。
		and Duel.IsExistingTarget(c21351206.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上满足条件的怪兽作为装备对象。
	Duel.SelectTarget(tp,c21351206.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示将要处理装备的效果。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置效果处理信息，表示将要处理离开墓地的效果。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行装备操作并设置装备限制。
function c21351206.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToEffect(e) then
		-- 尝试将装备卡装备给目标怪兽，若失败则返回。
		if not Duel.Equip(tp,c,tc) then return end
		-- 创建装备限制效果，确保该装备卡只能装备给特定怪兽。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(c21351206.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 装备限制效果的判断函数，确保只能装备给指定的怪兽。
function c21351206.eqlimit(e,c)
	return c==e:GetLabelObject()
end

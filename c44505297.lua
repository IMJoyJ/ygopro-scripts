--甲虫装機 エクサビートル
-- 效果：
-- 6星怪兽×2
-- 这张卡超量召唤成功时，可以选择自己或者对方的墓地1只怪兽当作装备卡使用给这张卡装备。这张卡的攻击力·守备力上升这个效果装备的怪兽的各自一半数值。此外，1回合1次，可以把这张卡1个超量素材取除，选择自己以及对方场上表侧表示存在的卡各1张送去墓地。
function c44505297.initial_effect(c)
	-- 为这张卡添加超量召唤手续：需要2只等级6的怪兽作为素材叠放。
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- 这张卡超量召唤成功时，可以选择自己或者对方的墓地1只怪兽当作装备卡使用给这张卡装备。这张卡的攻击力·守备力上升这个效果装备的怪兽的各自一半数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44505297,0))  --"装备"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c44505297.eqcon)
	e1:SetTarget(c44505297.eqtg)
	e1:SetOperation(c44505297.eqop)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，可以把这张卡1个超量素材取除，选择自己以及对方场上表侧表示存在的卡各1张送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44505297,1))  --"送去墓地"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetCost(c44505297.tgcost)
	e2:SetTarget(c44505297.tgtg)
	e2:SetOperation(c44505297.tgop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：这张卡是以超量召唤方式成功特殊召唤的场合。
function c44505297.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 筛选可用装备对象：墓地中的怪兽且未被禁止作为装备卡使用。
function c44505297.eqfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 取对象效果的目标条件：自己魔陷区有空位，且在双方墓地存在至少1只满足条件的怪兽。
function c44505297.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c44505297.eqfilter(chkc) end
	-- 目标选择检查：自己魔陷区是否有可用于装备的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 且双方墓地中存在可选择的装备怪兽。
		and Duel.IsExistingTarget(c44505297.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 弹出选择提示，让玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方墓地选择1只怪兽作为装备对象，并登记为效果对象。
	local g=Duel.SelectTarget(tp,c44505297.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 登记操作信息：本次处理包含让卡离开墓地的类别（CATEGORY_LEAVE_GRAVE），数量1。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理：将目标怪兽装备给此卡；赋予该装备卡‘只能装备给此卡’的限制，并根据其攻击力和守备力的一半提升此卡攻击力和守备力。
function c44505297.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出效果处理时锁定的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 尝试将目标怪兽作为装备卡装备给此卡（保持原表示形式），如果装备失败则效果处理终止。
	if not Duel.Equip(tp,tc,c,false) then return end
	-- “当作装备卡使用给这张卡装备”的装备限制设定。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c44505297.eqlimit)
	tc:RegisterEffect(e1)
	local atk=math.ceil(tc:GetTextAttack()/2)
	if atk<0 then atk=0 end
	-- 对应效果原文“这张卡的攻击力·守备力上升这个效果装备的怪兽的各自一半数值”中的攻击力上升部分。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(atk)
	tc:RegisterEffect(e2)
	local def=math.ceil(tc:GetTextDefense()/2)
	if def<0 then def=0 end
	-- 对应效果原文“这张卡的攻击力·守备力上升这个效果装备的怪兽的各自一半数值”中的守备力上升部分。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	e3:SetValue(def)
	tc:RegisterEffect(e3)
end
-- 装备限制判定：只有当效果持有者（此卡）是装备对象时才允许装备。
function c44505297.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 发动代价：从此卡取除1个超量素材（作为COST）。
function c44505297.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 取对象效果的目标条件：自己场上和对方场上各存在至少1张表侧表示的卡。
function c44505297.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 确认自己场上存在表侧表示卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil)
		-- 并且对方场上也存在表侧表示卡可作为对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，让玩家选择自己场上要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上的1张表侧表示卡并设为效果对象。
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 再次弹出选择提示，让玩家选择对方场上要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上的1张表侧表示卡并设为效果对象。
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 登记操作信息：本次效果将使2张卡送去墓地（CATEGORY_TOGRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,2,0,0)
end
-- 过滤条件：对象卡仍表侧表示且与该效果保持关联，才能被这次效果送去墓地。
function c44505297.tgfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 效果处理：获取所有对象卡，过滤出仍符合条件的卡，然后将其全部送去墓地。
function c44505297.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出本效果的对象卡集合。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(c44505297.tgfilter,nil,e)
	if tg:GetCount()>0 then
		-- 将过滤后的对象卡以效果原因送去墓地。
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end

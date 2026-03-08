--甲虫装機 エクサビートル
-- 效果：
-- 6星怪兽×2
-- 这张卡超量召唤成功时，可以选择自己或者对方的墓地1只怪兽当作装备卡使用给这张卡装备。这张卡的攻击力·守备力上升这个效果装备的怪兽的各自一半数值。此外，1回合1次，可以把这张卡1个超量素材取除，选择自己以及对方场上表侧表示存在的卡各1张送去墓地。
function c44505297.initial_effect(c)
	-- 为卡片添加超量召唤手续，使用等级为6、数量为2的怪兽进行超量召唤
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- 这张卡超量召唤成功时，可以选择自己或者对方的墓地1只怪兽当作装备卡使用给这张卡装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44505297,0))  --"装备"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c44505297.eqcon)
	e1:SetTarget(c44505297.eqtg)
	e1:SetOperation(c44505297.eqop)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，可以把这张卡1个超量素材取除，选择自己以及对方场上表侧表示存在的卡各1张送去墓地
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
-- 效果发动时，判断此卡是否为超量召唤成功
function c44505297.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 装备卡筛选函数，筛选墓地中的怪兽卡且未被禁止
function c44505297.eqfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 设置装备效果的发动条件，判断是否满足装备条件
function c44505297.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c44505297.eqfilter(chkc) end
	-- 判断玩家场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断玩家墓地中是否存在满足条件的怪兽卡
		and Duel.IsExistingTarget(c44505297.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 向玩家发送提示信息，提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的墓地怪兽作为装备卡
	local g=Duel.SelectTarget(tp,c44505297.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置装备效果的操作信息，记录将要装备的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 装备效果的处理函数，执行装备、设置攻击力和守备力提升效果
function c44505297.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备效果的目标卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 尝试将目标卡作为装备卡装备给此卡
	if not Duel.Equip(tp,tc,c,false) then return end
	-- 设置装备对象限制，确保只能装备给此卡
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c44505297.eqlimit)
	tc:RegisterEffect(e1)
	local atk=math.ceil(tc:GetTextAttack()/2)
	if atk<0 then atk=0 end
	-- 设置装备卡的攻击力提升效果，提升值为装备卡攻击力的一半
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(atk)
	tc:RegisterEffect(e2)
	local def=math.ceil(tc:GetTextDefense()/2)
	if def<0 then def=0 end
	-- 设置装备卡的守备力提升效果，提升值为装备卡守备力的一半
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	e3:SetValue(def)
	tc:RegisterEffect(e3)
end
-- 装备对象限制的判断函数，确保只能装备给此卡
function c44505297.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 设置送去墓地效果的费用，消耗1个超量素材
function c44505297.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置送去墓地效果的发动条件，判断是否满足选择目标条件
function c44505297.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断自己场上是否存在表侧表示的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil)
		-- 判断对方场上是否存在表侧表示的卡
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上的1张表侧表示的卡
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 向玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上的1张表侧表示的卡
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置送去墓地效果的操作信息，记录将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,2,0,0)
end
-- 送去墓地效果的过滤函数，筛选满足条件的卡
function c44505297.tgfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 送去墓地效果的处理函数，将符合条件的卡送去墓地
function c44505297.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(c44505297.tgfilter,nil,e)
	if tg:GetCount()>0 then
		-- 将目标卡组送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end

--No.66 覇鍵甲虫マスター・キー・ビートル
-- 效果：
-- 暗属性4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以这张卡以外的自己场上1张卡为对象才能发动。这张卡得到以下效果。
-- ●只要这张卡在怪兽区域存在，作为对象的卡不会被效果破坏。
-- ●这张卡被战斗·效果破坏的场合，可以作为代替把作为对象的1张自己的卡送去墓地。
function c76067258.initial_effect(c)
	-- 添加超量召唤手续：暗属性4星怪兽×2。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以这张卡以外的自己场上1张卡为对象才能发动。这张卡得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76067258,0))  --"破坏耐性"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c76067258.cost)
	e1:SetTarget(c76067258.target)
	e1:SetOperation(c76067258.operation)
	c:RegisterEffect(e1)
	-- ●只要这张卡在怪兽区域存在，作为对象的卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TARGET)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ●这张卡被战斗·效果破坏的场合，可以作为代替把作为对象的1张自己的卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c76067258.reptg)
	c:RegisterEffect(e3)
end
-- 设置该卡片的「No.」编号为66。
aux.xyz_number[76067258]=66
-- 效果①的代价：检查并取除这张卡的1个超量素材。
function c76067258.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：过滤出未被当前卡片作为效果对象的卡片。
function c76067258.filter(c,ec)
	return not ec:IsHasCardTarget(c)
end
-- 效果①的靶向：检查并选择自己场上1张除自身以外且未被当前卡片作为对象的卡作为效果对象。
function c76067258.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c and c76067258.filter(chkc,c) end
	-- 检查场上是否存在除自身以外且未被当前卡片作为对象的自己场上的卡。
	if chk==0 then return Duel.IsExistingTarget(c76067258.filter,tp,LOCATION_ONFIELD,0,1,c,c) end
	-- 提示玩家选择作为效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择1张符合条件的卡作为效果对象。
	Duel.SelectTarget(tp,c76067258.filter,tp,LOCATION_ONFIELD,0,1,1,c,c)
end
-- 效果①的操作：将选择的卡作为当前卡片的效果对象，并为该卡注册标识。
function c76067258.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的第一个效果对象。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		tc:RegisterFlagEffect(76067258,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
-- 过滤函数：过滤出属于自己且带有该卡效果标识的卡。
function c76067258.repfilter(c,tp)
	return c:IsControler(tp) and c:GetFlagEffect(76067258)~=0
end
-- 代替破坏效果的靶向：检查是否存在可代替送去墓地的对象卡，且自身因战斗或效果将被破坏。
function c76067258.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetCardTarget():IsExists(c76067258.repfilter,1,nil,tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) end
	-- 询问玩家是否发动代替破坏的效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=c:GetCardTarget():FilterSelect(tp,c76067258.repfilter,1,1,nil,tp)
		-- 将选中的代替卡因效果送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
		return true
	else return false end
end

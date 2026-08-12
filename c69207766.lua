--甲虫装機 ホーネット
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只「甲虫装机」怪兽当作装备卡使用给这张卡装备。
-- ②：把这张卡当作装备卡使用来装备的怪兽的等级上升3星，攻击力·守备力上升这张卡的各自数值。
-- ③：把给怪兽装备的这张卡送去墓地，以场上1张卡为对象才能发动。那张卡破坏。
function c69207766.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只「甲虫装机」怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(69207766,0))  --"装备"
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c69207766.eqtg)
	e1:SetOperation(c69207766.eqop)
	c:RegisterEffect(e1)
	-- 攻击力·守备力上升这张卡的各自数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 攻击力·守备力上升这张卡的各自数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(200)
	c:RegisterEffect(e3)
	-- 等级上升3星
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_LEVEL)
	e4:SetValue(3)
	c:RegisterEffect(e4)
	-- ③：把给怪兽装备的这张卡送去墓地，以场上1张卡为对象才能发动。那张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(69207766,1))  --"场上1张卡破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCost(c69207766.descost)
	e5:SetTarget(c69207766.destg)
	e5:SetOperation(c69207766.desop)
	c:RegisterEffect(e5)
end
-- 过滤条件：手卡·墓地中可以作为装备卡装备的「甲虫装机」怪兽
function c69207766.filter(c)
	return c:IsSetCard(0x56) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- ①号效果的发动准备与合法性检测
function c69207766.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检测手卡或墓地是否存在满足过滤条件的「甲虫装机」怪兽
		and Duel.IsExistingMatchingCard(c69207766.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：涉及将手卡或墓地的卡移出原本位置
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- ①号效果的处理：将手卡·墓地的「甲虫装机」怪兽装备给自身
function c69207766.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若魔法与陷阱区域没有空位，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家从手卡或墓地选择1张满足过滤条件且不受「王家长眠之谷」影响的「甲虫装机」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c69207766.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽作为装备卡装备给自身，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c) then return end
		-- 当作装备卡使用给这张卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c69207766.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制：该装备卡只能装备给当前这张卡
function c69207766.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ③号效果的cost：将自身送去墓地
function c69207766.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将作为装备卡的自身送去墓地作为发动的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ③号效果的发动准备与取对象
function c69207766.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return e:GetHandler():GetEquipTarget()
		-- 检测场上是否存在除自身以外的卡作为破坏对象
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③号效果的处理：破坏选中的卡
function c69207766.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--対壊獣用決戦兵器スーパーメカドゴラン
-- 效果：
-- 这张卡不能通常召唤。对方场上有「坏兽」怪兽存在的场合可以特殊召唤。
-- ①：「坏兽」怪兽在自己场上只能有1只表侧表示存在。
-- ②：1回合1次，把自己·对方场上2个坏兽指示物取除才能发动。从自己的手卡·墓地选1只「坏兽」怪兽当作装备卡使用给这张卡装备。
-- ③：这张卡的攻击力上升这张卡的效果装备的「坏兽」怪兽的原本攻击力数值。
function c84769941.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置「坏兽」怪兽在自己场上只能有1只表侧表示存在。
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0xd3),LOCATION_MZONE)
	-- 这张卡不能通常召唤。对方场上有「坏兽」怪兽存在的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c84769941.spcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把自己·对方场上2个坏兽指示物取除才能发动。从自己的手卡·墓地选1只「坏兽」怪兽当作装备卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84769941,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c84769941.eqcost)
	e2:SetTarget(c84769941.eqtg)
	e2:SetOperation(c84769941.eqop)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击力上升这张卡的效果装备的「坏兽」怪兽的原本攻击力数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c84769941.atkval)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「坏兽」怪兽。
function c84769941.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd3)
end
-- 特殊召唤规则的条件：自己场上有可用的怪兽区域，且对方场上有「坏兽」怪兽存在。
function c84769941.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在表侧表示的「坏兽」怪兽。
		and Duel.IsExistingMatchingCard(c84769941.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 装备效果的代价：从自己或对方场上移去2个坏兽指示物。
function c84769941.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能从双方场上移去2个坏兽指示物作为发动代价。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x37,2,REASON_COST) end
	-- 从双方场上移去2个坏兽指示物。
	Duel.RemoveCounter(tp,1,1,0x37,2,REASON_COST)
end
-- 过滤条件：手卡或墓地的「坏兽」怪兽，且不能是不能放置在魔陷区的卡。
function c84769941.eqfilter(c)
	return c:IsSetCard(0xd3) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 装备效果的发动条件：自己场上有可用的魔法与陷阱区域，且手卡或墓地有可装备的「坏兽」怪兽。
function c84769941.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔法与陷阱区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己的手卡或墓地是否存在可以装备的「坏兽」怪兽。
		and Duel.IsExistingMatchingCard(c84769941.eqfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：涉及从墓地移出卡片。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 装备效果的处理：从自己的手卡或墓地选1只「坏兽」怪兽作为装备卡装备给这张卡，并设置装备限制。
function c84769941.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查魔法与陷阱区域是否已满，若满则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家从手卡或不受「王家长眠之谷」影响的墓地中选择1只「坏兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c84769941.eqfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽作为装备卡装备给这张卡，若装备失败则结束处理。
		if not Duel.Equip(tp,tc,c) then return end
		tc:RegisterFlagEffect(84769941,RESET_EVENT+RESETS_STANDARD,0,0)
		-- 当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c84769941.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制：该装备卡只能装备给当前效果的发动者。
function c84769941.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤条件：由这张卡的效果装备的、且攻击力大于等于0的「坏兽」怪兽。
function c84769941.atkfilter(c)
	return c:IsSetCard(0xd3) and c:GetAttack()>=0 and c:GetFlagEffect(84769941)~=0
end
-- 计算攻击力上升值：计算所有由这张卡的效果装备的「坏兽」怪兽的原本攻击力合计。
function c84769941.atkval(e,c)
	local g=e:GetHandler():GetEquipGroup():Filter(c84769941.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end

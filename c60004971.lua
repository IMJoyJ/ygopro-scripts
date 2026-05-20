--ドラグニティの神槍
-- 效果：
-- 「龙骑兵团」怪兽才能装备。这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽攻击力上升自身的等级×100，不受陷阱卡的效果影响。
-- ②：自己主要阶段才能发动。从卡组把1只龙族「龙骑兵团」调整当作装备魔法卡使用给这张卡的装备怪兽装备。
function c60004971.initial_effect(c)
	-- 「龙骑兵团」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c60004971.target)
	e1:SetOperation(c60004971.operation)
	c:RegisterEffect(e1)
	-- 「龙骑兵团」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c60004971.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽攻击力上升自身的等级×100
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c60004971.atkval)
	c:RegisterEffect(e3)
	-- 不受陷阱卡的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(c60004971.efilter)
	c:RegisterEffect(e4)
	-- ②：自己主要阶段才能发动。从卡组把1只龙族「龙骑兵团」调整当作装备魔法卡使用给这张卡的装备怪兽装备。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,60004971)
	e5:SetTarget(c60004971.eqtg)
	e5:SetOperation(c60004971.eqop)
	c:RegisterEffect(e5)
end
-- 限定只能装备给「龙骑兵团」怪兽
function c60004971.eqlimit(e,c)
	return c:IsSetCard(0x29)
end
-- 过滤条件：场上表侧表示的「龙骑兵团」怪兽
function c60004971.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x29)
end
-- 装备魔法卡发动时的效果目标选择与处理
function c60004971.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c60004971.filter(chkc) end
	-- 检查场上是否存在可以装备的表侧表示「龙骑兵团」怪兽
	if chk==0 then return Duel.IsExistingTarget(c60004971.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示的「龙骑兵团」怪兽作为装备对象
	Duel.SelectTarget(tp,c60004971.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为将这张卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动后的效果处理（将自身装备给目标怪兽）
function c60004971.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的选择对象（要装备的怪兽）
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 攻击力上升数值的计算函数（装备怪兽的等级×100）
function c60004971.atkval(e,c)
	return c:GetLevel()*100
end
-- 免疫效果的过滤函数（仅免疫陷阱卡的效果）
function c60004971.efilter(e,re)
	return re:IsActiveType(TYPE_TRAP)
end
-- 过滤条件：卡组中可以装备的龙族「龙骑兵团」调整怪兽
function c60004971.eqfilter(c)
	return c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_TUNER) and not c:IsForbidden()
end
-- 效果②的发动准备与可行性检查
function c60004971.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在满足条件的龙族「龙骑兵团」调整怪兽
		and Duel.IsExistingMatchingCard(c60004971.eqfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组装备1张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（从卡组选择怪兽装备）
function c60004971.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 若魔法与陷阱区域没有空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if c:IsRelateToEffect(e) and ec:IsFaceup() then
		-- 提示玩家选择要装备的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从卡组选择1只满足条件的龙族「龙骑兵团」调整怪兽
		local g=Duel.SelectMatchingCard(tp,c60004971.eqfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		-- 将选择的怪兽作为装备卡装备给这张卡的装备怪兽，若失败则结束
		if not tc or not Duel.Equip(tp,tc,ec) then return end
		-- 当作装备魔法卡使用给这张卡的装备怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c60004971.eqlimit2)
		e1:SetLabelObject(ec)
		tc:RegisterEffect(e1)
	end
end
-- 限定该卡只能装备给当前的装备怪兽
function c60004971.eqlimit2(e,c)
	return c==e:GetLabelObject()
end

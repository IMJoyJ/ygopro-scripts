--エクシーズ・ユニット
-- 效果：
-- 超量怪兽才能装备。装备怪兽的攻击力上升装备怪兽的阶级×200的数值。此外，自己场上的装备怪兽把超量素材取除来让效果发动的场合，这张卡可以当作取除的超量素材中的1个使用。
function c13032689.initial_effect(c)
	-- 装备怪兽的攻击力上升装备怪兽的阶级×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c13032689.target)
	e1:SetOperation(c13032689.operation)
	c:RegisterEffect(e1)
	-- 此外，自己场上的装备怪兽把超量素材取除来让效果发动的场合，这张卡可以当作取除的超量素材中的1个使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c13032689.atkval)
	c:RegisterEffect(e2)
	-- 超量怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c13032689.eqlimit)
	c:RegisterEffect(e3)
	-- 是否要使用「超量组件」的效果？
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(13032689,0))  --"是否要使用「超量组件」的效果？"
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c13032689.rcon)
	e4:SetOperation(c13032689.rop)
	c:RegisterEffect(e4)
end
-- 设置装备对象为超量怪兽
function c13032689.eqlimit(e,c)
	return c:IsType(TYPE_XYZ)
end
-- 筛选场上正面表示的超量怪兽
function c13032689.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 设置效果目标为场上正面表示的超量怪兽
function c13032689.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c13032689.filter(chkc) end
	-- 判断是否满足装备目标条件
	if chk==0 then return Duel.IsExistingTarget(c13032689.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择装备目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择场上正面表示的超量怪兽作为装备目标
	Duel.SelectTarget(tp,c13032689.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c13032689.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算装备怪兽攻击力提升值
function c13032689.atkval(e,c)
	return c:GetRank()*200
end
-- 判断是否满足代替去除超量素材条件
function c13032689.rcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and ep==e:GetOwnerPlayer() and e:GetHandler():GetEquipTarget()==re:GetHandler() and re:GetHandler():GetOverlayCount()>=ev-1
end
-- 执行代替去除超量素材的操作
function c13032689.rop(e,tp,eg,ep,ev,re,r,rp)
	-- 将装备卡送入墓地作为代替去除的超量素材
	return Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

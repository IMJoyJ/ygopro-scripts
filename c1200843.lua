--八汰鏡
-- 效果：
-- 灵魂怪兽才能装备。装备怪兽在结束阶段时回到手卡效果可以不发动。装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。
function c1200843.initial_effect(c)
	-- 灵魂怪兽才能装备。装备怪兽在结束阶段时回到手卡效果可以不发动。装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c1200843.target)
	e1:SetOperation(c1200843.operation)
	c:RegisterEffect(e1)
	-- 灵魂怪兽才能装备。装备怪兽在结束阶段时回到手卡效果可以不发动。装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SPIRIT_MAYNOT_RETURN)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)
	-- 灵魂怪兽才能装备。装备怪兽在结束阶段时回到手卡效果可以不发动。装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c1200843.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e4:SetValue(c1200843.desval)
	c:RegisterEffect(e4)
end
c1200843.has_text_type=TYPE_SPIRIT
-- 限制装备对象必须是灵魂怪兽的判定函数
function c1200843.eqlimit(e,c)
	return c:IsType(TYPE_SPIRIT)
end
-- 筛选满足装备条件的目标怪兽：必须是表侧表示且为灵魂怪兽
function c1200843.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPIRIT)
end
-- 发动时选择装备对象的目标函数：检查并选择场上1只表侧表示的灵魂怪兽作为装备对象
function c1200843.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1200843.filter(chkc) end
	-- 检查是否存在满足条件（表侧表示且为灵魂怪兽）的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c1200843.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从玩家主怪兽区选择1只满足条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c1200843.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 装备操作函数：在效果适用时将八汰镜装备给所选目标怪兽
function c1200843.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果所选择的第一个目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将八汰镜装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判断破坏原因是否为战斗破坏，若是则触发代替破坏效果
function c1200843.desval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end

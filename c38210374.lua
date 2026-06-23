--バク団
-- 效果：
-- 自己的主要阶段时，手卡或者自己场上的这只怪兽可以当作装备卡使用给对方场上1只超量怪兽装备。用这个效果把这张卡装备的怪兽没有超量素材的场合，那只怪兽破坏。此外，这张卡当作装备卡使用而装备中的场合，每次对方的准备阶段把装备怪兽1个超量素材取除。
function c38210374.initial_effect(c)
	-- 自己主要阶段时，手卡或者自己场上的这只怪兽可以当作装备卡使用给对方场上1只超量怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38210374,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c38210374.eqtg)
	e1:SetOperation(c38210374.eqop)
	c:RegisterEffect(e1)
	-- 此外，这张卡当作装备卡使用而装备中的场合，每次对方的准备阶段把装备怪兽1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38210374,1))  --"取除素材"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c38210374.rmcon)
	e2:SetTarget(c38210374.rmtg)
	e2:SetOperation(c38210374.rmop)
	c:RegisterEffect(e2)
end
-- 筛选场上正面表示的超量怪兽
function c38210374.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 设定装备怪兽的选取条件为对方场上的正面表示的超量怪兽
function c38210374.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c38210374.filter(chkc) end
	-- 判断自己魔法陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断自己场上是否存在正面表示的超量怪兽
		and Duel.IsExistingTarget(c38210374.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上的1只超量怪兽作为装备对象
	Duel.SelectTarget(tp,c38210374.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备卡的处理流程
function c38210374.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取选择的装备对象
	local tc=Duel.GetFirstTarget()
	-- 判断是否满足装备条件（如魔法陷阱区是否为空、装备对象是否正面表示、是否在效果处理范围内）
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 若不满足条件则将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 装备对象限制效果，只能装备给超量怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c38210374.eqlimit)
	c:RegisterEffect(e1)
	-- 装备怪兽无超量素材时装备卡破坏效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c38210374.descon)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备对象限制条件：只能装备给超量怪兽
function c38210374.eqlimit(e,c)
	return c:IsType(TYPE_XYZ)
end
-- 装备怪兽无超量素材时装备卡破坏条件
function c38210374.descon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:GetOverlayCount()==0
end
-- 准备阶段触发条件：当前回合玩家不是装备卡持有者
function c38210374.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是装备卡持有者
	return Duel.GetTurnPlayer()~=tp
end
-- 准备阶段取除超量素材的处理条件
function c38210374.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ec=e:GetHandler():GetEquipTarget()
		return ec and ec:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
	end
end
-- 准备阶段取除超量素材的处理流程
function c38210374.rmop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local ec=e:GetHandler():GetEquipTarget()
	if ec then
		ec:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end

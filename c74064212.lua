--ヴァイロン・プリズム
-- 效果：
-- 这张卡从怪兽卡区域上送去墓地的场合，可以支付500基本分，把这张卡当作装备卡使用给自己场上表侧表示存在的1只怪兽装备。这张卡的装备怪兽进行战斗的场合，装备怪兽的攻击力在伤害步骤内上升1000。
function c74064212.initial_effect(c)
	-- 这张卡从怪兽卡区域上送去墓地的场合，可以支付500基本分，把这张卡当作装备卡使用给自己场上表侧表示存在的1只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74064212,0))  --"当成装备卡装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c74064212.eqcon)
	e1:SetCost(c74064212.eqcost)
	e1:SetTarget(c74064212.eqtg)
	e1:SetOperation(c74064212.eqop)
	c:RegisterEffect(e1)
	-- 这张卡的装备怪兽进行战斗的场合，装备怪兽的攻击力在伤害步骤内上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c74064212.atkcon)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
end
-- 判断发动条件：检查这张卡是否从怪兽区域送去墓地
function c74064212.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE)
end
-- 判断并支付发动代价：检查并扣除500点基本分
function c74064212.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查玩家是否能够支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分作为发动代价
	Duel.PayLPCost(tp,500)
end
-- 效果的目标选择：检查魔法与陷阱区域是否有空位，并选择自己场上1只表侧表示的怪兽作为效果对象
function c74064212.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 在效果发动准备阶段，检查自己场上的魔法与陷阱区域是否有空余的格子
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且检查自己场上是否存在可以作为对象的表侧表示怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择自己场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息：此效果包含将墓地中的卡移出墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡装备给目标怪兽，并添加装备对象限制
function c74064212.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的第一个效果对象（即要装备的怪兽）
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 把这张卡当作装备卡使用给自己场上表侧表示存在的1只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c74064212.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 装备限制：限制这张卡只能装备给自身持有者场上的怪兽
function c74064212.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp)
end
-- 攻击力上升效果的发动条件：装备怪兽进行战斗，且当前处于伤害步骤内
function c74064212.atkcon(e)
	-- 获取当前的阶段（用于后续判断是否处于伤害步骤）
	local ph=Duel.GetCurrentPhase()
	local ec=e:GetHandler():GetEquipTarget()
	return ec and (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and ec:IsRelateToBattle()
end

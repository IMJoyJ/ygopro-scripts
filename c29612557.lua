--サイクロン・ブーメラン
-- 效果：
-- 「元素英雄 荒野侠」才能装备。装备怪兽攻击力上升500。装备怪兽被其他卡的效果破坏送去墓地时，场上的魔法·陷阱卡全部破坏。给与对方基本分破坏的魔法·陷阱卡数量×100的伤害。
function c29612557.initial_effect(c)
	-- 为卡片添加系列编码0x3008，用于判断是否为元素英雄系列怪兽
	aux.AddSetNameMonsterList(c,0x3008)
	-- 「元素英雄 荒野侠」才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c29612557.target)
	e1:SetOperation(c29612557.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c29612557.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽被其他卡的效果破坏送去墓地时，场上的魔法·陷阱卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	-- 给与对方基本分破坏的魔法·陷阱卡数量×100的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29612557,0))  --"破坏并伤害"
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c29612557.descon)
	e4:SetTarget(c29612557.destg)
	e4:SetOperation(c29612557.desop)
	c:RegisterEffect(e4)
end
-- 限制只能装备到「元素英雄 荒野侠」怪兽上
function c29612557.eqlimit(e,c)
	return c:IsCode(86188410)
end
-- 用于筛选场上正面表示的「元素英雄 荒野侠」怪兽
function c29612557.filter(c)
	return c:IsFaceup() and c:IsCode(86188410)
end
-- 设置装备效果的目标选择逻辑
function c29612557.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c29612557.filter(chkc) end
	-- 检查场上是否存在符合条件的装备目标
	if chk==0 then return Duel.IsExistingTarget(c29612557.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择装备目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c29612557.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c29612557.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的装备目标
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断装备卡是否因失去装备对象而离场且原装备怪兽在墓地
function c29612557.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetPreviousEquipTarget()
	return e:GetHandler():IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_GRAVE)
		and bit.band(ec:GetReason(),0x41)==0x41
end
-- 用于筛选场上的魔法·陷阱卡
function c29612557.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置破坏并伤害效果的连锁操作信息
function c29612557.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c29612557.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置破坏效果的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置伤害效果的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*100)
end
-- 执行破坏并伤害效果
function c29612557.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c29612557.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将所有魔法·陷阱卡破坏
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 对对方造成破坏卡数量×100的伤害
	Duel.Damage(1-tp,ct*100,REASON_EFFECT)
end

--ハイドロプレッシャーカノン
-- 效果：
-- 3星以下的水属性怪兽才能装备。装备怪兽战斗破坏对方怪兽的场合，对方手卡随机1张送去墓地。
function c12174035.initial_effect(c)
	-- 装备怪兽战斗破坏对方怪兽的场合，对方手卡随机1张送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c12174035.target)
	e1:SetOperation(c12174035.operation)
	c:RegisterEffect(e1)
	-- 3星以下的水属性怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c12174035.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽战斗破坏对方怪兽的场合，对方手卡随机1张送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12174035,0))  --"送墓"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c12174035.hdcon)
	e3:SetTarget(c12174035.hdtg)
	e3:SetOperation(c12174035.hdop)
	c:RegisterEffect(e3)
end
-- 检查装备对象是否满足3星以下且为水属性
function c12174035.eqlimit(e,c)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 筛选满足3星以下且为水属性的怪兽
function c12174035.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 选择装备目标，即满足条件的怪兽
function c12174035.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c12174035.filter(chkc) end
	-- 判断是否满足选择装备目标的条件
	if chk==0 then return Duel.IsExistingTarget(c12174035.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择满足条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c12174035.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡的发动处理
function c12174035.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判断是否满足触发条件
function c12174035.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()==e:GetHandler():GetEquipTarget() and eg:GetFirst():IsStatus(STATUS_OPPO_BATTLE)
end
-- 设置发动效果的处理信息
function c12174035.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将对方手牌送去墓地的效果信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
-- 发动效果的处理
function c12174035.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌区的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	-- 将随机选择的一张对方手牌送去墓地
	Duel.SendtoGrave(sg,REASON_EFFECT)
end

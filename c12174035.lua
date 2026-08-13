--ハイドロプレッシャーカノン
-- 效果：
-- 3星以下的水属性怪兽才能装备。装备怪兽战斗破坏对方怪兽的场合，对方手卡随机1张送去墓地。
function c12174035.initial_effect(c)
	-- 3星以下的水属性怪兽才能装备。
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
-- 检测装备对象是否为等级3以下且水属性的怪兽，满足条件才允许装备。
function c12174035.eqlimit(e,c)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 筛选可用于装备选择的对象：场上表侧表示、等级3以下且水属性的怪兽。
function c12174035.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 装备魔法发动时的目标选择与操作信息设定：从双方场上选择符合条件的怪兽作为装备对象，并登记装备效果。
function c12174035.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c12174035.filter(chkc) end
	-- 发动时检查场上是否存在至少1只符合条件的水属性等级3以下怪兽。
	if chk==0 then return Duel.IsExistingTarget(c12174035.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示操作玩家从符合条件的怪兽中选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选定1只场上符合条件的表侧表示怪兽作为装备目标。
	Duel.SelectTarget(tp,c12174035.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 记录本次操作信息为装备效果，处理时将把此卡装备给所选对象。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时确认此卡和对象仍关联且对象表侧表示，则将水压加农炮装备给目标怪兽。
function c12174035.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将水压加农炮作为装备卡装备到目标怪兽上。
		Duel.Equip(tp,c,tc)
	end
end
-- 触发条件判定：战斗破坏怪兽的是此装备卡的装备对象怪兽，且该装备怪兽进行的是与对方怪兽的战斗。
function c12174035.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()==e:GetHandler():GetEquipTarget() and eg:GetFirst():IsStatus(STATUS_OPPO_BATTLE)
end
-- 触发效果发动时总是允许，并登记将对方手卡送去墓地的操作信息。
function c12174035.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：预定将对方1张手卡以效果原因送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND)
end
-- 效果处理：随机选择对方1张手卡，并将其送去墓地。
function c12174035.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方当前所有手卡组成的集合。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(tp,1)
	-- 将随机选出的手卡以效果原因送入墓地。
	Duel.SendtoGrave(sg,REASON_EFFECT)
end

--剣の煌き
-- 效果：
-- 名字带有「X-剑士」的怪兽才能装备。装备怪兽战斗破坏对方怪兽的场合，可以把对方场上存在的1张卡破坏。此外，可以把自己场上存在的1只怪兽解放，自己墓地存在的这张卡回到卡组最上面。
function c48447192.initial_effect(c)
	-- 名字带有「X-剑士」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c48447192.target)
	e1:SetOperation(c48447192.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽战斗破坏对方怪兽的场合，可以把对方场上存在的1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(48447192,0))  --"对方场上存在的1张卡破坏"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c48447192.descon)
	e2:SetTarget(c48447192.destg)
	e2:SetOperation(c48447192.desop)
	c:RegisterEffect(e2)
	-- 名字带有「X-剑士」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c48447192.eqlimit)
	c:RegisterEffect(e3)
	-- 此外，可以把自己场上存在的1只怪兽解放，自己墓地存在的这张卡回到卡组最上面。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetDescription(aux.Stringid(48447192,1))  --"回到卡组最上面"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(c48447192.retcost)
	e4:SetTarget(c48447192.rettg)
	e4:SetOperation(c48447192.retop)
	c:RegisterEffect(e4)
end
-- 定义此装备卡只能装备给名字带有「X-剑士」的怪兽。
function c48447192.eqlimit(e,c)
	return c:IsSetCard(0x100d)
end
-- 过滤条件：卡片须为表侧表示且名字带有「X-剑士」。
function c48447192.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x100d)
end
-- 装备魔法发动时的取对象处理：选择场上1只表侧表示的名字带有「X-剑士」的怪兽作为装备对象，并设定将这张卡装备的操作信息。
function c48447192.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c48447192.filter(chkc) end
	-- 检查场上是否存在至少1只表侧表示且名字带有「X-剑士」的怪兽可供选择为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c48447192.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只符合条件的表侧表示「X-剑士」怪兽作为装备对象。
	Duel.SelectTarget(tp,c48447192.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，声明将这张卡装备给选择的对象。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法的效果处理：若这张卡和对象怪兽仍与效果关联且对象怪兽表侧表示，则将此卡装备给对象怪兽。
function c48447192.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备魔法发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- 判定条件：这张卡的装备怪兽是否包含在本次战斗破坏的怪兽之中。
function c48447192.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and eg:IsContains(ec)
end
-- 破坏效果的目标处理：选择对方场上1张卡作为破坏对象，并设定破坏的操作信息。
function c48447192.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1张可作为破坏对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为破坏对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，声明将破坏选择的对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果处理：若对象仍与效果关联，则将其破坏。
function c48447192.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取破坏效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 解放代价处理：检查并选择自己场上1只怪兽解放作为发动墓地效果的代价。
function c48447192.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,aux.TRUE,1,nil) end
	-- 选择自己场上1只怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,1,nil)
	-- 解放选择的怪兽，作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 墓地效果的发动目标处理：确认墓地中的这张卡可以回到卡组，并设定回卡组的操作信息。
function c48447192.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置操作信息，声明将这张卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 回卡组效果处理：将墓地的这张卡回到持有者卡组最上面。
function c48447192.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡送到持有者卡组最顶端。
		Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end

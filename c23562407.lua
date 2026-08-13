--聖剣カリバーン
-- 效果：
-- 战士族怪兽才能装备。装备怪兽的攻击力上升500。此外，1回合1次，自己可以回复500基本分。场上表侧表示存在的这张卡被破坏送去墓地的场合，可以选择自己场上1只名字带有「圣骑士」的战士族怪兽把这张卡装备。「圣剑 石中剑」的这个效果1回合只能使用1次。此外，「圣剑 石中剑」在自己场上只能有1张表侧表示存在。
function c23562407.initial_effect(c)
	c:SetUniqueOnField(1,0,23562407)
	-- 战士族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c23562407.target)
	e1:SetOperation(c23562407.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 战士族怪兽才能装备。此外，「圣剑 石中剑」在自己场上只能有1张表侧表示存在。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c23562407.eqlimit)
	c:RegisterEffect(e3)
	-- 此外，1回合1次，自己可以回复500基本分。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(23562407,0))  --"回复LP"
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c23562407.lptg)
	e4:SetOperation(c23562407.lpop)
	c:RegisterEffect(e4)
	-- 场上表侧表示存在的这张卡被破坏送去墓地的场合，可以选择自己场上1只名字带有「圣骑士」的战士族怪兽把这张卡装备。「圣剑 石中剑」的这个效果1回合只能使用1次。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(23562407,1))  --"装备"
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,23562407)
	e5:SetCondition(c23562407.eqcon)
	e5:SetTarget(c23562407.eqtg)
	e5:SetOperation(c23562407.operation2)
	c:RegisterEffect(e5)
end
-- 判断怪兽是否满足战士族种族条件，作为此卡能否装备的限制条件。
function c23562407.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 过滤条件：场上表侧表示的战士族怪兽，用于选择装备对象。
function c23562407.eqfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 装备魔法发动时的取对象处理：选择场上1只表侧表示的战士族怪兽作为装备对象，并设置装备操作信息。
function c23562407.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c23562407.eqfilter1(chkc) end
	-- 发动时判定场上是否存在至少1只表侧表示的战士族怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c23562407.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，让玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择场上1只表侧表示的战士族怪兽，并将该怪兽设为这张卡的效果对象。
	Duel.SelectTarget(tp,c23562407.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息：装备效果，目标是这张卡自身，预计处理1张。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡和对象怪兽仍与效果相关且对象表侧表示，且场上同名卡唯一限制满足，则将这张卡装备给对象怪兽。
function c23562407.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这张卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:CheckUniqueOnField(tp) then
		-- 将这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- 回复基本分效果发动前的处理：无条件可通过，设置回复玩家为自己、回复数值为500。
function c23562407.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复基本分的玩家为当前效果发动者自己。
	Duel.SetTargetPlayer(tp)
	-- 设置回复基本分的数值为500。
	Duel.SetTargetParam(500)
	-- 设置连锁的操作信息：该效果为回复基本分效果，预计回复玩家tp的500基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果处理时，从连锁信息中取出目标玩家和回复数值，执行基本分回复。
function c23562407.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标玩家和回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家回复对应数值的基本分，回复原因为效果。
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 该效果触发条件：这张卡在场上表侧表示存在时被破坏并送去墓地，且此时满足场上同名卡唯一限制。
function c23562407.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY) and c:CheckUniqueOnField(tp)
end
-- 过滤条件：表侧表示、卡名属于「圣骑士」系列的战士族怪兽，用于选择重新装备对象。
function c23562407.eqfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsRace(RACE_WARRIOR)
end
-- 破坏后被送去墓地时的效果目标处理：判定此卡仍与效果相关、自己魔陷区有空位，并选择自己场上1只表侧表示的「圣骑士」战士族怪兽作为新装备对象。
function c23562407.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c23562407.eqfilter2(chkc) end
	-- 判定此卡与当前效果仍关联，且自己魔陷区有空位可以装备。
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己场上是否存在至少1只表侧表示的「圣骑士」战士族怪兽作为装备对象。
		and Duel.IsExistingTarget(c23562407.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，让玩家选择要装备的「圣骑士」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择自己场上1只表侧表示的「圣骑士」战士族怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,c23562407.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁的操作信息：装备效果，目标是这张卡自身，预计处理1张。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置连锁的操作信息：这张卡将离开墓地，用于标记卡片的移动。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果处理时，若此卡及对象怪兽仍与效果相关、对象是本方场上表侧表示的「圣骑士」战士族怪兽且满足装备限制和场上唯一限制，则将此卡从墓地装备给对象怪兽。
function c23562407.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()
		and tc:IsControler(tp) and tc:IsSetCard(0x107a) and c23562407.eqlimit(nil,tc) and c:CheckUniqueOnField(tp) then
		-- 将这张卡从墓地装备给对象怪兽。
		Duel.Equip(tp,c,tc)
	end
end

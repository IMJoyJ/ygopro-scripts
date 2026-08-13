--白銀の翼
-- 效果：
-- 8星以上的龙族同调怪兽才能装备。装备怪兽1回合最多2次不会被战斗破坏。装备怪兽被卡的效果破坏的场合，可以作为代替把这张卡破坏。
function c25231813.initial_effect(c)
	-- 8星以上的龙族同调怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c25231813.target)
	e1:SetOperation(c25231813.operation)
	c:RegisterEffect(e1)
	-- 8星以上的龙族同调怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c25231813.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽1回合最多2次不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetCountLimit(2)
	e3:SetValue(c25231813.indval)
	c:RegisterEffect(e3)
	-- 装备怪兽被卡的效果破坏的场合，可以作为代替把这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(c25231813.reptg2)
	e4:SetOperation(c25231813.repop2)
	c:RegisterEffect(e4)
end
-- 判定装备对象是否满足等级8以上、龙族、同调怪兽这三个条件，用于设定这张卡的装备限制。
function c25231813.eqlimit(e,c)
	return c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
-- 筛选场上表侧表示且等级8以上、龙族、同调怪兽，作为发动装备效果时选择目标的过滤条件。
function c25231813.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
-- 装备魔法发动时的目标选择流程：检查存在合法装备目标、提示玩家选择、选择1只符合条件的怪兽并设置操作信息。
function c25231813.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c25231813.filter(chkc) end
	-- 发动时判定场上是否存在至少1只符合条件的怪兽（表侧表示、等级8以上、龙族、同调）可供选择。
	if chk==0 then return Duel.IsExistingTarget(c25231813.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的提示信息，引导其选择装备对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从符合条件的怪兽中选择1只作为装备对象，并将该怪兽登记为当前效果的对象。
	Duel.SelectTarget(tp,c25231813.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息，宣告将进行装备操作，操作对象为这张装备魔法卡本身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，确认这张装备卡和目标怪兽仍然与效果关联且目标仍表侧表示，然后将这张卡装备给目标怪兽。
function c25231813.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的目标怪兽（装备对象）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备给目标怪兽，完成装备动作。
		Duel.Equip(tp,c,tc)
	end
end
-- 当破坏原因为战斗破坏时返回真，使装备怪兽获得一回合最多2次的战斗破坏抗性。
function c25231813.indval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 代替破坏的触发判定：装备怪兽将要被效果破坏且不是被代替破坏，同时这张装备卡本身可被破坏且尚未确认破坏时，条件成立。
function c25231813.reptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetEquipTarget():IsReason(REASON_EFFECT) and not c:GetEquipTarget():IsReason(REASON_REPLACE)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动这张装备卡的代替破坏效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏的处理：先取消装备卡的确认破坏状态，然后将这张装备卡破坏。
function c25231813.repop2(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果破坏并带有代替破坏原因将这张装备卡破坏，从而代替装备怪兽被破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end

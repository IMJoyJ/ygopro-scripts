--聖剣クラレント
-- 效果：
-- 战士族怪兽才能装备。这个卡名的③的效果1回合只能使用1次。
-- ①：「圣剑 克拉伦特」在自己场上只能有1张表侧表示存在。
-- ②：1回合1次，支付500基本分才能发动。这个回合，装备怪兽可以直接攻击。
-- ③：场上的表侧表示的这张卡被破坏送去墓地的场合，以自己场上1只战士族「圣骑士」怪兽为对象才能发动。那只自己的战士族「圣骑士」怪兽把这张卡装备。
function c41359411.initial_effect(c)
	c:SetUniqueOnField(1,0,41359411)
	-- 战士族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c41359411.target)
	e1:SetOperation(c41359411.operation)
	c:RegisterEffect(e1)
	-- 战士族怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c41359411.eqlimit)
	c:RegisterEffect(e2)
	-- ②：1回合1次，支付500基本分才能发动。这个回合，装备怪兽可以直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41359411,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c41359411.dircon)
	e3:SetCost(c41359411.dircost)
	e3:SetOperation(c41359411.dirop)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：场上的表侧表示的这张卡被破坏送去墓地的场合，以自己场上1只战士族「圣骑士」怪兽为对象才能发动。那只自己的战士族「圣骑士」怪兽把这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41359411,1))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,41359411)
	e4:SetCondition(c41359411.eqcon)
	e4:SetTarget(c41359411.eqtg)
	e4:SetOperation(c41359411.operation2)
	c:RegisterEffect(e4)
end
-- 装备对象限制函数：判断候选怪兽是否为战士族，只有战士族怪兽才能装备这张卡。
function c41359411.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 装备发动时的对象过滤条件：选择表侧表示的战士族怪兽作为装备对象。
function c41359411.eqfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 装备卡发动（激活）时进行目标选择：若处于效果处理中则返回对象合法性的检查，否则选择场上1只表侧表示战士族怪兽作为装备对象。
function c41359411.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c41359411.eqfilter1(chkc) end
	-- 发动合法性检查：场上是否存在至少1只表侧表示的战士族怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c41359411.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作者显示选择提示消息“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示战士族怪兽作为这张装备卡的对象，并记录为当前连锁的对象。
	Duel.SelectTarget(tp,c41359411.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果处理将进行装备（CATEGORY_EQUIP），要装备的卡是这张装备卡自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法的发动处理：若这张装备卡和对象怪兽仍关联且对象表侧表示，且这张卡满足一意性限制，则将其装备给对象怪兽。
function c41359411.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中记录的第一张（唯一一张）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:CheckUniqueOnField(tp) then
		-- 把这张装备卡装备给选中的战士族怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- ②效果的发动条件：当前回合玩家能够进入战斗阶段时才允许发动该效果。
function c41359411.dircon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否满足可进入战斗阶段的条件（作为②效果是否可发动的判定）。
	return Duel.IsAbleToEnterBP()
end
-- ②效果的发动代价：检查并支付500基本分。
function c41359411.dircost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：回合玩家是否能支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分，作为②效果的发动代价。
	Duel.PayLPCost(tp,500)
end
-- ②效果处理：为该装备卡自身注册一个装备效果，使其装备怪兽获得直接攻击能力，持续到结束阶段。
function c41359411.dirop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，装备怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- ③效果的发动条件：这张卡从场上以表侧表示被破坏送去墓地，且自己场上不存在同名表侧表示的「圣剑 克拉伦特」（满足一意性）。
function c41359411.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY) and c:CheckUniqueOnField(tp)
end
-- ③效果的对象过滤条件：选择自己场上的表侧表示、战士族且属于「圣骑士」（0x107a）的怪兽作为装备对象。
function c41359411.eqfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsRace(RACE_WARRIOR)
end
-- ③效果的目标选择：若指定对象则验证其位置和种族/系列；否则检查这张卡是否仍与效果关联、魔陷区是否有空位，以及是否存在符合条件的对象。
function c41359411.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c41359411.eqfilter2(chkc) end
	-- 发动条件判定：这张装备卡仍与效果关联（未被除外等），且自己魔陷区有空格可以装备这张卡。
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件判定：自己场上是否存在至少1只符合条件的战士族「圣骑士」怪兽可以作为对象。
		and Duel.IsExistingTarget(c41359411.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作者显示选择提示消息“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只符合条件的战士族「圣骑士」怪兽作为装备对象，并记录为当前连锁的对象。
	Duel.SelectTarget(tp,c41359411.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次处理将进行装备（CATEGORY_EQUIP），要装备的卡是这张装备卡自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置操作信息：本次处理会使这张装备卡离开墓地（CATEGORY_LEAVE_GRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ③效果处理：若对象怪兽仍关联、表侧表示、由自己控制且满足战士族「圣骑士」条件，同时这张卡仍满足一意性，则将该装备卡装备给对象怪兽。
function c41359411.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中记录的第一张（唯一一张）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()
		and tc:IsControler(tp) and tc:IsSetCard(0x107a) and c41359411.eqlimit(nil,tc) and c:CheckUniqueOnField(tp) then
		-- 把这张装备卡装备给选中的战士族「圣骑士」怪兽。
		Duel.Equip(tp,c,tc)
	end
end

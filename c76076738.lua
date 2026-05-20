--闇竜族の爪
-- 效果：
-- 暗属性怪兽才能装备。这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽的攻击力上升600，不会被对方的效果破坏。
-- ②：装备怪兽被战斗破坏送去墓地让这张卡被送去墓地的场合才能发动。那只怪兽在自己场上特殊召唤，把这张卡装备。这个效果装备的这张卡从场上离开的场合除外。
function c76076738.initial_effect(c)
	-- 暗属性怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c76076738.target)
	e1:SetOperation(c76076738.activate)
	c:RegisterEffect(e1)
	-- 暗属性怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c76076738.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力上升600
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(600)
	c:RegisterEffect(e3)
	-- 不会被对方的效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被对方的效果破坏
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	-- ②：装备怪兽被战斗破坏送去墓地让这张卡被送去墓地的场合才能发动。那只怪兽在自己场上特殊召唤，把这张卡装备。这个效果装备的这张卡从场上离开的场合除外。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,76076738)
	e5:SetCondition(c76076738.spcon)
	e5:SetTarget(c76076738.sptg)
	e5:SetOperation(c76076738.spop)
	c:RegisterEffect(e5)
end
-- 装备限制过滤：必须是暗属性怪兽
function c76076738.eqlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
-- 过滤场上表侧表示的暗属性怪兽
function c76076738.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 装备魔法卡发动时的效果处理，选择装备对象
function c76076738.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c76076738.filter(chkc) end
	-- 检查场上是否存在可选的装备对象
	if chk==0 then return Duel.IsExistingTarget(c76076738.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只暗属性怪兽作为装备对象
	Duel.SelectTarget(tp,c76076738.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动后的效果处理，将这张卡装备给目标怪兽
function c76076738.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判定是否满足装备怪兽被战斗破坏送去墓地且这张卡送去墓地的条件
function c76076738.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_BATTLE) and ec:IsPreviousControler(tp)
end
-- 效果②发动时的对象选择与合法性检查
function c76076738.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	-- 检查自己场上是否有怪兽区域的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否有魔法与陷阱区域的空位
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and ec and ec:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将之前装备的怪兽设为效果处理的对象
	Duel.SetTargetCard(ec)
	-- 设置操作信息为特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,ec,1,0,0)
	-- 设置操作信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	-- 设置操作信息为这张卡从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 效果②发动后的效果处理，特殊召唤怪兽并装备此卡，且设置离场除外
function c76076738.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetHandler():GetPreviousEquipTarget()
	-- 检查怪兽和此卡是否仍与效果相关，并尝试将怪兽以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) and c:IsRelateToEffect(e) then
		-- 将这张卡重新装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c76076738.eqlim)
		c:RegisterEffect(e1)
		-- 这个效果装备的这张卡从场上离开的场合除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
-- 装备限制：此卡只能装备给由其效果特殊召唤的该怪兽
function c76076738.eqlim(e,c)
	return e:GetOwner()==c
end

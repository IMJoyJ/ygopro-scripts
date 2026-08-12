--ライジング・オブ・ファイア
-- 效果：
-- 这个卡名在规则上也当作「转生炎兽」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合，以自己墓地1只炎属性怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。装备怪兽的攻击力上升500。这张卡从场上离开时那只怪兽破坏。
-- ②：这张卡被对方的效果破坏的场合才能发动。选场上1只怪兽除外。
function c66947913.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，以自己墓地1只炎属性怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,66947913)
	e1:SetCondition(c66947913.condition)
	e1:SetTarget(c66947913.target)
	e1:SetOperation(c66947913.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c66947913.checkop)
	c:RegisterEffect(e2)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c66947913.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 装备怪兽的攻击力上升500。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(500)
	c:RegisterEffect(e4)
	-- ②：这张卡被对方的效果破坏的场合才能发动。选场上1只怪兽除外。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,66947914)
	e5:SetCondition(c66947913.rmcon)
	e5:SetTarget(c66947913.rmtg)
	e5:SetOperation(c66947913.rmop)
	c:RegisterEffect(e5)
end
-- 判定效果①的发动条件：自己场上没有怪兽存在
function c66947913.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤条件：墓地中可以特殊召唤的炎属性怪兽
function c66947913.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查怪兽区域空位、墓地是否存在合法的炎属性怪兽，并选择对象）
function c66947913.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c66947913.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的炎属性怪兽
		and Duel.IsExistingTarget(c66947913.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只炎属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66947913.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息：包含特殊召唤选定怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置连锁信息：包含将这张卡作为装备卡装备的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果①的处理（特殊召唤目标怪兽，并将这张卡装备给该怪兽，同时添加装备限制）
function c66947913.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 尝试将目标怪兽以表侧表示特殊召唤（分解步骤）
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 将这张卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c66947913.eqlimit)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
-- 装备限制：只能装备给该效果的发动者（即这张卡）
function c66947913.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 离场前检查：如果这张卡在离场时效果已被无效，则标记为不触发后续的破坏效果
function c66947913.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 离场时处理：若未被无效，则破坏装备的怪兽
function c66947913.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果破坏装备的怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判定效果②的发动条件：这张卡被对方的效果破坏
function c66947913.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
end
-- 效果②的发动准备（检查场上是否有可除外的怪兽，并设置除外操作信息）
function c66947913.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查双方场上是否存在至少1只可以被除外的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上所有可以被除外的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁信息：包含除外场上1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果②的处理（选场上1只怪兽除外）
function c66947913.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择双方场上1只可以被除外的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 选中卡片时在场上显示选择动画
		Duel.HintSelection(g)
		-- 将选中的怪兽表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

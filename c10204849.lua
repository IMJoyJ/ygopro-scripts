--フルール・ド・フルーレ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：以自己墓地1只2星以下的怪兽为对象才能把这张卡发动。那只怪兽效果无效特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
-- ②：装备怪兽的攻击力上升700。
-- ③：这张卡从魔法与陷阱区域送去墓地的场合才能发动。选自己场上1只同调怪兽把这张卡装备。
function c10204849.initial_effect(c)
	-- ①：以自己墓地1只2星以下的怪兽为对象才能把这张卡发动。那只怪兽效果无效特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,10204849+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c10204849.target)
	e1:SetOperation(c10204849.operation)
	c:RegisterEffect(e1)
	-- ②：装备怪兽的攻击力上升700。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(700)
	c:RegisterEffect(e3)
	-- ③：这张卡从魔法与陷阱区域送去墓地的场合才能发动。选自己场上1只同调怪兽把这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,10204849)
	e4:SetCondition(c10204849.eqcon)
	e4:SetTarget(c10204849.eqtg)
	e4:SetOperation(c10204849.eqop)
	c:RegisterEffect(e4)
end
-- 定义过滤器函数，用于筛选墓地中等级≤2且可以被特殊召唤的怪兽
function c10204849.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果的目标选择函数，设置发卡时的检测和处理逻辑
function c10204849.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10204849.filter(chkc,e,tp) end
	-- 检测玩家主要怪兽区是否有可用的位置用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测玩家墓地是否存在满足条件的怪兽（等级≤2，可被特殊召唤）
		and Duel.IsExistingTarget(c10204849.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择要特殊召唤的怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 让玩家从墓地中选择1只满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c10204849.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤操作信息，公告将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置装备操作信息，公告将把此卡装备到怪兽身上
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 定义效果处理函数，执行特殊召唤和装备的具体操作
function c10204849.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家在发动效果时选择的怪兽作为目标
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 执行特殊召唤步骤，将目标怪兽以表侧攻击表示特殊召唤
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽效果无效特殊召唤（创建无效化效果）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		-- 将这张卡装备到被特殊召唤的怪兽上
		Duel.Equip(tp,c,tc)
		-- 设置装备限制，确保此卡只能装备给指定的怪兽
		local e3=Effect.CreateEffect(tc)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(c10204849.eqlimit)
		c:RegisterEffect(e3)
		-- 记录装备卡在离场时的状态，用于后续判断是否破坏装备怪兽
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetCode(EVENT_LEAVE_FIELD_P)
		e4:SetOperation(c10204849.checkop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e4)
		-- 当装备卡从场上离开时，破坏装备的怪兽
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e5:SetCode(EVENT_LEAVE_FIELD)
		e5:SetOperation(c10204849.desop)
		e5:SetReset(RESET_EVENT+RESET_OVERLAY+RESET_TOFIELD)
		e5:SetLabelObject(e4)
		c:RegisterEffect(e5)
	end
	-- 完成特殊召唤流程，结束特殊召唤处理
	Duel.SpecialSummonComplete()
end
-- 定义装备限制函数，用于判断怪兽是否可以装备此卡
function c10204849.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 检查操作函数，用于在离场时判断装备卡是否被无效化
function c10204849.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 破坏操作函数，当装备卡离场且未被无效时破坏装备怪兽
function c10204849.desop(e,tp,eg,ep,ev,re,r,rp)
	e:Reset()
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetEquipTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果破坏装备的怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 定义条件函数，判断此卡是否从魔法陷阱区送去墓地
function c10204849.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 定义过滤器函数，用于筛选场上的表侧表示同调怪兽
function c10204849.eqfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 定义装备目标选择函数，处理③效果的发动条件检测
function c10204849.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检测玩家魔法陷阱区是否有可用的位置用于装备
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检测场上是否存在表侧表示的同调怪兽
		and Duel.IsExistingMatchingCard(c10204849.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置装备操作信息，公告将进行装备处理
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置离开墓地操作信息，公告此卡从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 定义装备操作函数，执行将卡装备给同调怪兽的处理
function c10204849.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 向玩家显示选择要装备的同调怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 让玩家选择场上1只表侧表示的同调怪兽
	local g=Duel.SelectMatchingCard(tp,c10204849.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and tc:IsFaceup() and c:CheckUniqueOnField(tp) then
		-- 将这张卡装备到玩家选择的同调怪兽上
		Duel.Equip(tp,c,tc)
		-- 设置装备限制，确保此卡只能装备给指定的同调怪兽
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c10204849.eqlimit)
		c:RegisterEffect(e1)
	end
end

--トリックスター・マジカローラ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「淘气仙星」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
-- ②：1回合1次，装备怪兽用战斗·效果给与对方伤害的场合才能发动。从手卡把1只「淘气仙星」怪兽特殊召唤。
function c22159429.initial_effect(c)
	-- ①：以自己墓地1只「淘气仙星」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22159429+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c22159429.target)
	e1:SetOperation(c22159429.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c22159429.checkop)
	c:RegisterEffect(e2)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c22159429.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ②：1回合1次，装备怪兽用战斗·效果给与对方伤害的场合才能发动。从手卡把1只「淘气仙星」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(22159429,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCondition(c22159429.spcon)
	e4:SetTarget(c22159429.sptg)
	e4:SetOperation(c22159429.spop)
	c:RegisterEffect(e4)
end
-- 检查目标是否为「淘气仙星」怪兽且能被特殊召唤，用于筛选①的墓地对象。
function c22159429.spfilter(c,e,tp)
	return c:IsSetCard(0xfb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时指定对象：确认选择的是自己墓地符合条件的「淘气仙星」怪兽，并检查发动条件是否满足。
function c22159429.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22159429.spfilter(chkc,e,tp) end
	-- 效果发动时检查自己场上是否有空余的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认墓地存在至少1只符合条件的「淘气仙星」怪兽可选择。
		and Duel.IsExistingTarget(c22159429.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地的符合条件的「淘气仙星」怪兽中选择1只作为效果对象。
	local g=Duel.SelectTarget(tp,c22159429.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将选中的怪兽进行特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：这张卡将作为装备卡装备给对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将对象怪兽特殊召唤，把这张卡装备给它，并给装备怪兽设置只能装备这张卡的限制。
function c22159429.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 以表侧表示将对象怪兽特殊召唤到自己场上。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 将这张卡作为装备卡装备到该怪兽身上。
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c22159429.eqlimit)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤处理，结算此特殊召唤步骤。
	Duel.SpecialSummonComplete()
end
-- 定义装备限制：只有这张卡本身才能装备给该怪兽，防止装备到其他卡。
function c22159429.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 在卡片离场前检测其是否处于无效化状态，并记录标记，供离场破坏效果判定使用。
function c22159429.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 当装备卡离场时，若此前未被无效化，则破坏其装备的怪兽。
function c22159429.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果原因破坏装备怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判定是否满足效果②发动条件：装备怪兽对对方造成战斗或效果伤害。
function c22159429.spcon(e,tp,eg,ep,ev,re,r,rp)
	local cet=e:GetHandler():GetEquipTarget()
	return ep~=tp and ((eg and eg:GetFirst() == cet) or (re and re:GetHandler() == cet))
end
-- 检查手牌中的卡是否为「淘气仙星」怪兽且能被特殊召唤，用于②的手牌特殊召唤筛选。
function c22159429.spfilter2(c,e,tp)
	return c:IsSetCard(0xfb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动时检查：自己场上有空位且手牌存在可特殊召唤的「淘气仙星」怪兽。
function c22159429.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并确认手牌中存在至少1只可特殊召唤的「淘气仙星」怪兽。
		and Duel.IsExistingMatchingCard(c22159429.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手牌特殊召唤1只「淘气仙星」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②处理：从手牌选择1只「淘气仙星」怪兽特殊召唤。
function c22159429.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时若没有空余怪兽区域则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家从手牌选择要特殊召唤的「淘气仙星」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只符合条件的「淘气仙星」怪兽。
	local g=Duel.SelectMatchingCard(tp,c22159429.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

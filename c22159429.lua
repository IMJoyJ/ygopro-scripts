--トリックスター・マジカローラ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「淘气仙星」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
-- ②：1回合1次，装备怪兽用战斗·效果给与对方伤害的场合才能发动。从手卡把1只「淘气仙星」怪兽特殊召唤。
function c22159429.initial_effect(c)
	-- ①：以自己墓地1只「淘气仙星」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22159429+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c22159429.target)
	e1:SetOperation(c22159429.operation)
	c:RegisterEffect(e1)
	-- ①：以自己墓地1只「淘气仙星」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c22159429.checkop)
	c:RegisterEffect(e2)
	-- ①：以自己墓地1只「淘气仙星」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
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
-- 过滤函数，用于判断墓地中的「淘气仙星」怪兽是否可以被特殊召唤
function c22159429.spfilter(c,e,tp)
	return c:IsSetCard(0xfb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足①效果的发动条件，即是否能选择墓地中的「淘气仙星」怪兽作为对象
function c22159429.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22159429.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否在墓地中存在满足条件的「淘气仙星」怪兽
		and Duel.IsExistingTarget(c22159429.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的「淘气仙星」怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c22159429.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息，表示将装备一张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行①效果的处理，将选中的怪兽特殊召唤并装备给它
function c22159429.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 尝试将目标怪兽特殊召唤
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- ①：以自己墓地1只「淘气仙星」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c22159429.eqlimit)
		c:RegisterEffect(e1)
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
-- 装备限制效果，确保只有装备卡能装备给该怪兽
function c22159429.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 检查装备卡是否被无效
function c22159429.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 当装备卡离开场上时，若未被无效则破坏装备的怪兽
function c22159429.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将装备的怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否满足②效果的发动条件，即装备怪兽是否对对方造成伤害
function c22159429.spcon(e,tp,eg,ep,ev,re,r,rp)
	local cet=e:GetHandler():GetEquipTarget()
	return ep~=tp and ((eg and eg:GetFirst() == cet) or (re and re:GetHandler() == cet))
end
-- 过滤函数，用于判断手卡中的「淘气仙星」怪兽是否可以被特殊召唤
function c22159429.spfilter2(c,e,tp)
	return c:IsSetCard(0xfb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足②效果的发动条件，即是否能在手卡中找到满足条件的怪兽
function c22159429.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否在手卡中存在满足条件的「淘气仙星」怪兽
		and Duel.IsExistingMatchingCard(c22159429.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤一只手卡中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行②效果的处理，从手卡特殊召唤一只「淘气仙星」怪兽
function c22159429.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的位置进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手卡中的「淘气仙星」怪兽作为特殊召唤对象
	local g=Duel.SelectMatchingCard(tp,c22159429.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

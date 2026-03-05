--ガーディアン・デスサイス
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
-- ①：「守护者·艾托斯」被战斗·效果破坏送去自己墓地的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤成功时才能发动。从卡组把1张「死神的大镰-断魂」给这张卡装备。
-- ③：只要这张卡在怪兽区域存在，自己不能召唤·特殊召唤。
-- ④：这张卡从场上送去墓地的场合发动。把1张手卡送去墓地，这张卡从墓地特殊召唤。
function c18175965.initial_effect(c)
	-- 记录该卡具有「守护者·艾托斯」和「死神的大镰-断魂」的卡片代码
	aux.AddCodeList(c,34022290,81954378)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己不能召唤怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e3)
	-- 「守护者·艾托斯」被战斗·效果破坏送去自己墓地的场合才能发动。这张卡从手卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(18175965,0))  --"特殊召唤"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetRange(LOCATION_HAND)
	e4:SetCondition(c18175965.spcon)
	e4:SetTarget(c18175965.sptg)
	e4:SetOperation(c18175965.spop)
	c:RegisterEffect(e4)
	-- 这张卡特殊召唤成功时才能发动。从卡组把1张「死神的大镰-断魂」给这张卡装备。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(18175965,1))  --"装备"
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetTarget(c18175965.eqtg)
	e5:SetOperation(c18175965.eqop)
	c:RegisterEffect(e5)
	-- 只要这张卡在怪兽区域存在，自己不能召唤·特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_CANNOT_SUMMON)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,0)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e7)
	-- 这张卡从场上送去墓地的场合发动。把1张手卡送去墓地，这张卡从墓地特殊召唤。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(18175965,2))  --"特殊召唤"
	e8:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_TO_GRAVE)
	e8:SetCondition(c18175965.spcon2)
	e8:SetTarget(c18175965.sptg2)
	e8:SetOperation(c18175965.spop2)
	c:RegisterEffect(e8)
end
-- 用于判断被破坏的卡是否为「守护者·艾托斯」且为战斗或效果破坏
function c18175965.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsCode(34022290)
end
-- 判断是否满足特殊召唤条件，即是否有「守护者·艾托斯」被破坏
function c18175965.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c18175965.cfilter,1,nil,tp)
end
-- 判断是否满足特殊召唤的条件，即是否有足够的怪兽区域和该卡是否可以特殊召唤
function c18175965.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 设置操作信息，表示将要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，若成功则完成程序
function c18175965.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作
	if Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 用于判断卡组中是否存在可装备的「死神的大镰-断魂」
function c18175965.filter(c,ec)
	return c:IsCode(81954378) and c:CheckEquipTarget(ec)
end
-- 判断是否满足装备条件，即是否有足够的装备区域和卡组中是否存在可装备的卡
function c18175965.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断卡组中是否存在可装备的「死神的大镰-断魂」
		and Duel.IsExistingMatchingCard(c18175965.filter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
end
-- 执行装备操作，选择并装备「死神的大镰-断魂」
function c18175965.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足装备条件，即是否有足够的装备区域、该卡是否正面表示且是否与效果相关
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一张可装备的「死神的大镰-断魂」
	local g=Duel.SelectMatchingCard(tp,c18175965.filter,tp,LOCATION_DECK,0,1,1,nil,c)
	if g:GetCount()>0 then
		-- 将选中的卡装备给该卡
		Duel.Equip(tp,g:GetFirst(),c)
	end
end
-- 判断该卡是否从场上送去墓地
function c18175965.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 设置操作信息，表示将要丢弃手卡并特殊召唤该卡
function c18175965.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息，表示将要丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,tp,1)
end
-- 执行墓地发动效果，丢弃1张手卡并特殊召唤该卡
function c18175965.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否成功丢弃1张手卡
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT)==0 then return end
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作，以特殊召唤方式将该卡从墓地召唤
		Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	end
end

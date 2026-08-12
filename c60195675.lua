--無限起動コロッサルマウンテン
-- 效果：
-- 7星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。这张卡的攻击力上升1000。
-- ②：这张卡战斗破坏对方怪兽时才能发动。那只怪兽在这张卡下面重叠作为超量素材。
-- ③：这张卡在墓地存在的场合，把自己场上1只机械族连接怪兽解放才能发动。这张卡守备表示特殊召唤。
function c60195675.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置XYZ召唤手续：等级7怪兽2只
	aux.AddXyzProcedure(c,nil,7,2)
	-- ①：把这张卡1个超量素材取除才能发动。这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(60195675,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,60195675)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c60195675.atkcost)
	e1:SetOperation(c60195675.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。那只怪兽在这张卡下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60195675,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c60195675.xyzcon)
	e2:SetTarget(c60195675.xyztg)
	e2:SetOperation(c60195675.xyzop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的场合，把自己场上1只机械族连接怪兽解放才能发动。这张卡守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(60195675,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,60195676)
	e3:SetCost(c60195675.spcost)
	e3:SetTarget(c60195675.sptg)
	e3:SetOperation(c60195675.spop)
	c:RegisterEffect(e3)
end
-- 效果①的Cost：检查并取除这张卡的1个超量素材
function c60195675.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的效果处理：使这张卡的攻击力上升1000
function c60195675.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：这张卡战斗破坏怪兽，且该怪兽可以作为超量素材
function c60195675.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if not c:IsRelateToBattle() then return false end
	e:SetLabelObject(tc)
	return tc and tc:IsType(TYPE_MONSTER) and tc:IsReason(REASON_BATTLE) and tc:IsCanOverlay()
		and (tc:IsLocation(LOCATION_GRAVE) or tc:IsFaceup() and tc:IsLocation(LOCATION_EXTRA+LOCATION_REMOVED))
end
-- 效果②的Target：检查自身是否为XYZ怪兽，并将被破坏的怪兽设为效果处理对象
function c60195675.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
	local tc=e:GetLabelObject()
	-- 将被战斗破坏的怪兽设为效果处理对象
	Duel.SetTargetCard(tc)
	-- 设置操作信息：涉及墓地卡片移动
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
-- 效果②的效果处理：将被破坏的怪兽重叠在这张卡下面作为超量素材
function c60195675.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取被战斗破坏的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanOverlay() then
		-- 将目标怪兽重叠在这张卡下面作为超量素材
		Duel.Overlay(c,tc)
	end
end
-- 过滤条件：自己场上的机械族连接怪兽，且解放后能空出怪兽区域
function c60195675.cfilter(c,tp)
	-- 检查卡片是否为机械族连接怪兽，且解放该卡后是否有可用的怪兽区域
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_MACHINE) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果③的Cost：解放自己场上1只机械族连接怪兽
function c60195675.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可解放的满足条件的机械族连接怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c60195675.cfilter,1,nil,tp) end
	-- 选择自己场上1只满足条件的机械族连接怪兽
	local g=Duel.SelectReleaseGroup(tp,c60195675.cfilter,1,1,nil,tp)
	-- 解放选中的怪兽作为Cost
	Duel.Release(g,REASON_COST)
end
-- 效果③的Target：检查自身是否能守备表示特殊召唤，并设置特殊召唤的操作信息
function c60195675.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理：将这张卡守备表示特殊召唤
function c60195675.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡守备表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

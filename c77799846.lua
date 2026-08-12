--廃品眼の太鼓竜
-- 效果：
-- 机械族8星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力直到下次的对方的结束阶段时上升1000。持有超量素材的这张卡被破坏的场合，可以通过把自己墓地1只名字带有「超级防卫机器人」的怪兽从游戏中除外，这张卡从墓地特殊召唤。那之后，可以选自己墓地1只名字带有「超级防卫机器人」的怪兽在这张卡下面重叠作为超量素材。
function c77799846.initial_effect(c)
	-- 设置XYZ召唤手续：机械族8星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),8,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力直到下次的对方的结束阶段时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(77799846,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c77799846.cost)
	e1:SetOperation(c77799846.operation)
	c:RegisterEffect(e1)
	-- 持有超量素材的这张卡被破坏的场合，可以通过把自己墓地1只名字带有「超级防卫机器人」的怪兽从游戏中除外，这张卡从墓地特殊召唤。那之后，可以选自己墓地1只名字带有「超级防卫机器人」的怪兽在这张卡下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77799846,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c77799846.spcon)
	e2:SetCost(c77799846.spcost)
	e2:SetTarget(c77799846.sptg)
	e2:SetOperation(c77799846.spop)
	c:RegisterEffect(e2)
end
-- 攻击力上升效果的Cost：检查并取除这张卡的1个超量素材
function c77799846.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 攻击力上升效果的处理：若这张卡在场上表侧表示存在，则使其攻击力上升1000点，直到下次对方的结束阶段
function c77799846.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到下次的对方的结束阶段时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
-- 特殊召唤效果的发动条件：这张卡被破坏送去墓地，且在场上时持有超量素材
function c77799846.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetPreviousOverlayCountOnField()>0
end
-- 过滤墓地中可以作为Cost除外的「超级防卫机器人」怪兽
function c77799846.rfilter(c)
	return c:IsSetCard(0x85) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤效果的Cost：将自己墓地1只「超级防卫机器人」怪兽除外
function c77799846.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以除外的「超级防卫机器人」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c77799846.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1只满足条件的「超级防卫机器人」怪兽
	local g=Duel.SelectMatchingCard(tp,c77799846.rfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤效果的Target：检查自身是否仍在墓地、怪兽区域是否有空位，并设置特殊召唤的操作信息
function c77799846.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查这张卡是否与效果相关联，且自己场上是否有可用的怪兽区域空格
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤墓地中可以作为超量素材重叠的「超级防卫机器人」怪兽
function c77799846.mfilter(c)
	return c:IsSetCard(0x85) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 特殊召唤效果的处理：将这张卡特殊召唤，之后可以选自己墓地1只「超级防卫机器人」怪兽重叠作为超量素材
function c77799846.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与效果相关联，则将其以表侧表示特殊召唤，并判断是否特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取自己墓地中不受「王家长眠之谷」影响且满足条件的「超级防卫机器人」怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c77799846.mfilter),tp,LOCATION_GRAVE,0,nil)
		-- 若墓地存在可重叠的怪兽，则询问玩家是否选择重叠作为超量素材
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(77799846,2)) then  --"是否要选择墓地1只名字带有「超级防卫机器人」的怪兽作为超量素材？"
			-- 中断当前效果，使后续的重叠素材处理与特殊召唤不视为同时处理
			Duel.BreakEffect()
			-- 给玩家发送提示信息，提示选择要作为超量素材的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			local mg=g:Select(tp,1,1,nil)
			-- 将选择的怪兽重叠在这张卡下面作为超量素材
			Duel.Overlay(c,mg)
		end
	end
end

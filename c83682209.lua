--海霊賊
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在墓地存在的状态，「海灵贼」以外的自己场上的表侧表示的水属性怪兽被战斗·效果破坏的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的攻击力直到下个回合的结束时上升自己墓地的水属性怪兽数量×100。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c83682209.initial_effect(c)
	-- ①：这张卡在墓地存在的状态，「海灵贼」以外的自己场上的表侧表示的水属性怪兽被战斗·效果破坏的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡的攻击力直到下个回合的结束时上升自己墓地的水属性怪兽数量×100。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83682209,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,83682209)
	e1:SetCondition(c83682209.spcon)
	e1:SetTarget(c83682209.sptg)
	e1:SetOperation(c83682209.spop)
	c:RegisterEffect(e1)
end
-- 过滤出原本由自己控制、原本在怪兽区域表侧表示、因战斗或效果破坏、且不是「海灵贼」的水属性怪兽
function c83682209.spfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsCode(83682209)
		and (c:GetPreviousAttributeOnField()&ATTRIBUTE_WATER)>0
end
-- 检查被破坏的卡中是否存在满足过滤条件的卡，且被破坏的卡中不包含这张卡自身
function c83682209.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c83682209.spfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 判断自身是否能特殊召唤，并检查自己场上是否有可用的怪兽区域
function c83682209.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表示该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤，并为特殊召唤成功的自身添加攻击力上升和离场除外的效果
function c83682209.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于墓地，则将其以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 获取自己墓地中水属性怪兽的数量
		local ct=Duel.GetMatchingGroupCount(Card.IsAttribute,tp,LOCATION_GRAVE,0,nil,ATTRIBUTE_WATER)
		-- 这个效果特殊召唤的这张卡的攻击力直到下个回合的结束时上升自己墓地的水属性怪兽数量×100。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
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

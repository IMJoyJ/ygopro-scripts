--晴天気ベンガーラ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在墓地存在的场合，把自己场上1张表侧表示的永续魔法·永续陷阱卡送去墓地才能发动。这张卡守备表示特殊召唤，从手卡选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置。
-- ②：场上的这张卡为让「天气」卡的效果发动而被除外的场合，下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
function c54895237.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，把自己场上1张表侧表示的永续魔法·永续陷阱卡送去墓地才能发动。这张卡守备表示特殊召唤，从手卡选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54895237,0))  --"墓地的这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,54895237)
	e1:SetCost(c54895237.gspcost)
	e1:SetTarget(c54895237.gsptg)
	e1:SetOperation(c54895237.gspop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为让「天气」卡的效果发动而被除外的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(c54895237.spreg)
	c:RegisterEffect(e2)
	-- 下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(54895237,1))  --"除外的这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCondition(c54895237.spcon)
	e3:SetTarget(c54895237.sptg)
	e3:SetOperation(c54895237.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤作为发动Cost送去墓地的场上表侧表示永续魔陷，并检查特殊召唤和放置卡片所需的格子以及手牌中是否有可放置的「天气」魔陷
function c54895237.costfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToGraveAsCost()
		-- 检查该卡送去墓地后，自己场上是否有可用于特殊召唤的怪兽区域和用于放置魔陷的魔法与陷阱区域
		and Duel.GetMZoneCount(tp,c)>0 and Duel.GetSZoneCount(tp,c)>0
		-- 检查手牌中是否存在至少1张满足放置条件的「天气」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c54895237.setfilter,tp,LOCATION_HAND,0,1,nil,c,tp)
end
-- 过滤手牌中可以表侧表示放置到魔法与陷阱区域的非场地「天气」魔法·陷阱卡
function c54895237.setfilter(c,cc,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD) and c:IsSetCard(0x109)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_ONFIELD,cc)
end
-- 效果①的发动Cost：选择自己场上1张表侧表示的永续魔法·永续陷阱卡送去墓地
function c54895237.gspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动时，自己场上是否存在满足Cost条件的表侧表示永续魔法·永续陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c54895237.costfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张满足条件的表侧表示永续魔法·永续陷阱卡
	local g=Duel.SelectMatchingCard(tp,c54895237.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选择的卡作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的Target：检查自身是否能守备表示特殊召唤，并设置特殊召唤的操作信息
function c54895237.gsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return e:IsCostChecked()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的Operation：将这张卡守备表示特殊召唤，并从手牌选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置
function c54895237.gspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域，且这张卡在墓地中仍与效果相关联
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 将这张卡守备表示特殊召唤，并检查是否特殊召唤成功
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0
		-- 检查自己场上是否有空余的魔法与陷阱区域
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从手牌选择1张满足条件的「天气」魔法·陷阱卡
		local tc=Duel.SelectMatchingCard(tp,c54895237.setfilter,tp,LOCATION_HAND,0,1,1,nil,nil,tp):GetFirst()
		if tc then
			-- 将选择的卡在自己的魔法与陷阱区域表侧表示放置
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end
end
-- 效果②的注册函数：当场上的这张卡因「天气」卡的效果发动而被除外时，记录下个回合的准备阶段并注册Flag
function c54895237.spreg(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsReason(REASON_COST) and rc:IsSetCard(0x109) and c:IsPreviousLocation(LOCATION_ONFIELD) and re:IsActivated() then
		-- 将Label设置为下个回合的回合数
		e:SetLabel(Duel.GetTurnCount()+1)
		c:RegisterFlagEffect(54895237,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- 效果②的Condition：检查当前回合是否为被除外时的下个回合，且该卡带有对应的Flag
function c54895237.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合数是否等于记录的下个回合数，且自身具有效果②的Flag
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(54895237)>0
end
-- 效果②的Target：检查自己场上是否有空余的怪兽区域，且自身是否能特殊召唤，并设置特殊召唤的操作信息
function c54895237.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(54895237)
end
-- 效果②的Operation：将除外的这张卡特殊召唤
function c54895237.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将除外的这张卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

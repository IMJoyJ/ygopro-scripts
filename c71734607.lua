--六花のひとひら
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从卡组选「六花的一瓣」以外的1只「六花」怪兽加入手卡或送去墓地。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
-- ②：这张卡在墓地存在，自己场上没有怪兽存在的场合或者自己场上的怪兽只有植物族怪兽的场合，对方结束阶段才能发动。这张卡特殊召唤。
function c71734607.initial_effect(c)
	-- ①：自己主要阶段才能发动。从卡组选「六花的一瓣」以外的1只「六花」怪兽加入手卡或送去墓地。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71734607,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,71734607)
	e1:SetTarget(c71734607.target)
	e1:SetOperation(c71734607.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上没有怪兽存在的场合或者自己场上的怪兽只有植物族怪兽的场合，对方结束阶段才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71734607,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,71734608)
	e2:SetCondition(c71734607.spcon)
	e2:SetTarget(c71734607.sptg)
	e2:SetOperation(c71734607.spop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「六花的一瓣」以外的「六花」怪兽，且该怪兽能加入手卡或送去墓地。
function c71734607.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x141) and not c:IsCode(71734607) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 效果①的发动准备与合法性检测，设置检索或送墓的操作信息。
function c71734607.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「六花」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c71734607.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组的卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置将卡组的卡送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理，从卡组选择怪兽加入手卡或送去墓地，并适用只能特殊召唤植物族怪兽的限制。
function c71734607.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组选择1张满足条件的「六花」怪兽。
	local g=Duel.SelectMatchingCard(tp,c71734607.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 判断所选卡片是否能加入手卡，且在不能送去墓地或玩家选择加入手卡时，执行加入手卡分支。
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将选中的怪兽加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手卡的卡片。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的怪兽送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。②：这张卡在墓地存在，自己场上没有怪兽存在的场合或者自己场上的怪兽只有植物族怪兽的场合，对方结束阶段才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c71734607.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤植物族以外怪兽的玩家效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能特殊召唤植物族怪兽。
function c71734607.splimit(e,c)
	return not c:IsRace(RACE_PLANT)
end
-- 过滤场上表侧表示的植物族怪兽。
function c71734607.spfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 效果②的发动条件判断，检查是否为对方结束阶段，且自己场上没有怪兽或只有植物族怪兽。
function c71734607.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方。
	if Duel.GetTurnPlayer()~=1-tp then return false end
	-- 获取自己场上的怪兽数量。
	local ct1=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	-- 获取自己场上表侧表示的植物族怪兽数量。
	local ct2=Duel.GetMatchingGroupCount(c71734607.spfilter,tp,LOCATION_MZONE,0,nil)
	local chk1=ct1==0
	local chk2=ct2>0 and ct1-ct2==0
	return chk1 or chk2
end
-- 效果②的发动准备与合法性检测，设置特殊召唤的操作信息。
function c71734607.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空怪兽区域，且此卡是否能特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将此卡特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的处理，将墓地的此卡特殊召唤。
function c71734607.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

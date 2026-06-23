--電脳堺麟－麟々
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。那之后，可以把和作为对象的卡以及送去墓地的卡种类不同的1张「电脑堺麟-麟麟」以外的「电脑堺」卡从卡组送去墓地。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
function c49966326.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49966326,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,49966326)
	e1:SetTarget(c49966326.sptg)
	e1:SetOperation(c49966326.spop)
	c:RegisterEffect(e1)
end
-- 选择满足条件的场上的「电脑堺」卡作为效果的对象
function c49966326.tfilter(c,tp)
	local type1=c:GetType()&0x7
	-- 该对象卡必须是表侧表示且其种类（怪兽·魔法·陷阱）在卡组中存在不同种类的「电脑堺」卡
	return c:IsSetCard(0x14e) and c:IsFaceup() and Duel.IsExistingMatchingCard(c49966326.tgfilter,tp,LOCATION_DECK,0,1,nil,type1)
end
-- 过滤函数，用于筛选卡组中与指定类型不同的「电脑堺」卡并能送去墓地
function c49966326.tgfilter(c,type1)
	return not c:IsType(type1) and c:IsSetCard(0x14e) and c:IsAbleToGrave()
end
-- 过滤函数，用于筛选卡组中与指定类型不同的「电脑堺」卡（排除自己）并能送去墓地
function c49966326.tgfilter2(c,type1)
	return not c:IsType(type1) and c:IsSetCard(0x14e) and not c:IsCode(49966326) and c:IsAbleToGrave()
end
-- 效果处理时的条件判断，检查是否满足发动条件
function c49966326.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c49966326.tfilter(chkc,tp) end
	-- 检查场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否存在满足条件的「电脑堺」卡作为对象
		and Duel.IsExistingTarget(c49966326.tfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的卡作为对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的场上的「电脑堺」卡作为对象
	local g=Duel.SelectTarget(tp,c49966326.tfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置效果处理信息，表示将从卡组送去墓地一张卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置效果处理信息，表示将自己特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行效果的主要逻辑
function c49966326.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的发动者和对象卡
	local c,tc=e:GetHandler(),Duel.GetFirstTarget()
	local type1=tc:GetType()&0x7
	if tc:IsRelateToEffect(e) then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组中选择一张与对象卡种类不同的「电脑堺」卡送去墓地
		local g=Duel.SelectMatchingCard(tp,c49966326.tgfilter,tp,LOCATION_DECK,0,1,1,nil,type1)
		local tgc=g:GetFirst()
		-- 将选中的卡送去墓地并确认其在墓地，同时确认效果发动者仍在场
		if tgc and Duel.SendtoGrave(tgc,REASON_EFFECT)~=0 and tgc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e)
			-- 将自己特殊召唤到场上
			and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local type1=tgc:GetType()&0x7|type1
			-- 获取满足条件的卡组中与对象卡及送去墓地卡种类不同的「电脑堺」卡
			local sg=Duel.GetMatchingGroup(c49966326.tgfilter2,tp,LOCATION_DECK,0,nil,type1)
			-- 判断是否有满足条件的卡可选择，并询问玩家是否发动后续效果
			if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(49966326,1)) then  --"是否从卡组把卡送去墓地？"
				-- 中断当前连锁，使后续处理视为不同时处理
				Duel.BreakEffect()
				-- 提示玩家选择要送去墓地的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
				local g=sg:Select(tp,1,1,nil)
				if #g>0 then
					-- 将选中的卡从卡组送去墓地
					Duel.SendtoGrave(g,REASON_EFFECT)
				end
			end
		end
	end
	-- 这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c49966326.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使对方在本回合不能特殊召唤等级或阶级为3以下的怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否满足不能特殊召唤的条件
function c49966326.splimit(e,c)
	return not (c:IsLevelAbove(3) or c:IsRankAbove(3))
end

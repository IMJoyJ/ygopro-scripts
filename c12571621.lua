--電脳堺豸－豸々
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。这个回合的结束阶段，可以从自己墓地选「电脑堺豸-豸豸」以外的1只「电脑堺」怪兽加入手卡。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
function c12571621.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。这个回合的结束阶段，可以从自己墓地选「电脑堺豸-豸豸」以外的1只「电脑堺」怪兽加入手卡。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12571621,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,12571621)
	e1:SetTarget(c12571621.sptg)
	e1:SetOperation(c12571621.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否存在满足条件的「电脑堺」卡（必须是表侧表示且卡组中存在与该卡种类不同的「电脑堺」卡）
function c12571621.tfilter(c,tp)
	local type1=c:GetType()&0x7
	-- 返回满足条件的「电脑堺」卡：必须是「电脑堺」卡、表侧表示、并且卡组中存在与该卡种类不同的「电脑堺」卡
	return c:IsSetCard(0x14e) and c:IsFaceup() and Duel.IsExistingMatchingCard(c12571621.tgfilter,tp,LOCATION_DECK,0,1,nil,type1)
end
-- 过滤函数，用于判断卡组中是否存在种类与目标卡不同的「电脑堺」卡
function c12571621.tgfilter(c,type1)
	return not c:IsType(type1) and c:IsSetCard(0x14e) and c:IsAbleToGrave()
end
-- 效果的发动时点处理函数，用于判断是否满足发动条件
function c12571621.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c12571621.tfilter(chkc,tp) end
	-- 判断是否满足发动条件：场上是否有足够的召唤区域、自身是否可以特殊召唤、是否场上有满足条件的「电脑堺」卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断是否满足发动条件：场上有满足条件的「电脑堺」卡
		and Duel.IsExistingTarget(c12571621.tfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择满足条件的「电脑堺」卡作为效果对象
	local g=Duel.SelectTarget(tp,c12571621.tfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置效果处理信息：将要从卡组送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置效果处理信息：将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，用于执行效果
function c12571621.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的发动卡和目标卡
	local c,tc=e:GetHandler(),Duel.GetFirstTarget()
	local type1=tc:GetType()&0x7
	if tc:IsRelateToEffect(e) then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		-- 从卡组中选择种类与目标卡不同的「电脑堺」卡
		local g=Duel.SelectMatchingCard(tp,c12571621.tgfilter,tp,LOCATION_DECK,0,1,1,nil,type1)
		local tgc=g:GetFirst()
		-- 判断所选卡是否成功送去墓地且自身是否还在场上
		if tgc and Duel.SendtoGrave(tgc,REASON_EFFECT)~=0 and tgc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e)
			-- 判断是否成功特殊召唤自身
			and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- ①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。这个回合的结束阶段，可以从自己墓地选「电脑堺豸-豸豸」以外的1只「电脑堺」怪兽加入手卡。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetCondition(c12571621.thcon)
			e1:SetOperation(c12571621.thop)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 注册一个在结束阶段触发的效果，用于在结束阶段从墓地将怪兽加入手卡
			Duel.RegisterEffect(e1,tp)
		end
	end
	-- ①：这张卡在手卡存在的场合，以自己场上1张「电脑堺」卡为对象才能发动。和那张卡种类（怪兽·魔法·陷阱）不同的1张「电脑堺」卡从卡组送去墓地，这张卡特殊召唤。这个回合的结束阶段，可以从自己墓地选「电脑堺豸-豸豸」以外的1只「电脑堺」怪兽加入手卡。这个回合，自己若非等级或者阶级是3以上的怪兽则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c12571621.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册一个在结束阶段触发的效果，用于限制自己不能特殊召唤等级或阶级低于3的怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤效果的过滤函数，用于判断是否满足不能特殊召唤等级或阶级低于3的怪兽的条件
function c12571621.splimit(e,c)
	return not (c:IsLevelAbove(3) or c:IsRankAbove(3))
end
-- 用于判断墓地中是否满足条件的「电脑堺」怪兽（不包括自身）
function c12571621.thfilter(c)
	return c:IsSetCard(0x14e) and c:IsType(TYPE_MONSTER) and not c:IsCode(12571621) and c:IsAbleToHand()
end
-- 判断是否满足从墓地将怪兽加入手卡的条件
function c12571621.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在满足条件的「电脑堺」怪兽（不包括自身）
	return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c12571621.thfilter),tp,LOCATION_GRAVE,0,1,nil)
end
-- 处理从墓地将怪兽加入手卡的效果
function c12571621.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 询问玩家是否选择从墓地将怪兽加入手卡
	if Duel.SelectYesNo(tp,aux.Stringid(12571621,1)) then  --"是否从墓地把怪兽加入手卡？"
		-- 提示发动卡片的动画
		Duel.Hint(HINT_CARD,0,12571621)
		-- 提示玩家选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- 从墓地中选择满足条件的「电脑堺」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c12571621.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方看到加入手卡的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

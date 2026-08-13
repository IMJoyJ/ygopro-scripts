--転生炎獣Bバイソン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己墓地有「转生炎兽」怪兽3只以上存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：以最多有对方场上的表侧表示的卡数量的自己墓地的炎属性连接怪兽为对象才能发动。那些怪兽回到额外卡组。那之后，可以选最多有回去的卡数量的对方场上的表侧表示的卡，直到回合结束时那个效果无效。
function c25166510.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己墓地有「转生炎兽」怪兽3只以上存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25166510,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,25166510)
	e1:SetCondition(c25166510.spcon)
	e1:SetTarget(c25166510.sptg)
	e1:SetOperation(c25166510.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：以最多有对方场上的表侧表示的卡数量的自己墓地的炎属性连接怪兽为对象才能发动。那些怪兽回到额外卡组。那之后，可以选最多有回去的卡数量的对方场上的表侧表示的卡，直到回合结束时那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25166510,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,25166511)
	e2:SetTarget(c25166510.target)
	e2:SetOperation(c25166510.operation)
	c:RegisterEffect(e2)
end
-- 筛选字段为「转生炎兽」（0x119）的怪兽卡，用于后续判断墓地中满足条件的「转生炎兽」怪兽。
function c25166510.cfilter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER)
end
-- ①效果的发动条件：自己墓地存在3只以上「转生炎兽」怪兽。
function c25166510.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少3张满足cfilter过滤条件的「转生炎兽」怪兽。
	return Duel.IsExistingMatchingCard(c25166510.cfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- ①效果的发动目标判定：主要怪兽区有空位且此卡可以表侧守备表示特殊召唤到自己的主要怪兽区。
function c25166510.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区有空余区域，作为特殊召唤的前提条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置处理信息：即将把此卡特殊召唤，用于连锁过程中其他效果的响应判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若此卡仍与该效果关联，则将其表侧守备表示特殊召唤。
function c25166510.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：以无召唤条件限制、无苏生限制的方式将此卡表侧守备表示特殊召唤到控制者场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 筛选自己墓地的炎属性连接怪兽，且能够回到额外卡组，作为②效果的对象候选。
function c25166510.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_LINK) and c:IsAbleToExtra()
end
-- ②效果的取对象处理：计算对方场上表侧表示卡数量作为最多可选数，从自己墓地选择1至该数量的符合条件的炎属性连接怪兽为对象，并设置回额外卡组的处理信息。
function c25166510.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25166510.tdfilter(chkc) end
	-- 统计对方场上表侧表示的卡的数量，用于决定②效果最多能选择的墓地怪兽数量。
	local ct=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	-- ②效果的发动条件：对方场上有表侧表示的卡，且自己墓地存在至少1只符合条件的炎属性连接怪兽。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c25166510.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作者显示选择提示，请其选择要返回额外卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让操作者从自己墓地的符合条件的炎属性连接怪兽中选择1到ct张作为效果对象。
	local g=Duel.SelectTarget(tp,c25166510.tdfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
	-- 设置处理信息：将所选对象卡返回额外卡组，供后续连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
-- ②效果处理：先取回仍与效果关联的对象卡并送返额外卡组，得到实际返回数；若返回数>0且对方场上存在可无效的表侧卡，则询问是否追加无效效果；确认后选择对方场上表侧表示卡，使其效果无效直到回合结束。
function c25166510.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁记录的对象，并筛选出仍然与该效果相关的卡（未离场或未被重置联系）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将取回的对象卡以效果原因返回持有者额外卡组并洗牌，返回实际返回数量ct。
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取对方场上表侧表示且可以被无效的卡（怪兽、魔法、陷阱均可）。
	local tg=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	-- 若实际返回数ct>0且对方存在可无效的卡，则让操作者选择是否发动追加无效效果。
	if ct>0 and #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(25166510,2)) then  --"是否选卡无效？"
		-- 中断当前连锁处理，使后续的无效选卡处理视为独立时点处理（错开时点），避免同时处理。
		Duel.BreakEffect()
		-- 提示操作者选择要无效化的对方场上表侧表示卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		local sg=tg:Select(tp,1,ct,nil)
		-- 将所选卡片进行选择动画提示，并登记为当前连锁的对象（广义）。
		Duel.HintSelection(sg)
		local tc=sg:GetFirst()
		while tc do
			-- 直到回合结束时那个效果无效。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 直到回合结束时那个效果无效。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			tc=sg:GetNext()
		end
	end
end

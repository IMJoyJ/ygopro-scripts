--転生炎獣Bバイソン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己墓地有「转生炎兽」怪兽3只以上存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：以最多有对方场上的表侧表示的卡数量的自己墓地的炎属性连接怪兽为对象才能发动。那些怪兽回到额外卡组。那之后，可以选最多有回去的卡数量的对方场上的表侧表示的卡，直到回合结束时那个效果无效。
function c25166510.initial_effect(c)
	-- 效果原文内容：①：自己墓地有「转生炎兽」怪兽3只以上存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
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
	-- 效果原文内容：②：以最多有对方场上的表侧表示的卡数量的自己墓地的炎属性连接怪兽为对象才能发动。那些怪兽回到额外卡组。那之后，可以选最多有回去的卡数量的对方场上的表侧表示的卡，直到回合结束时那个效果无效。
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
-- 规则层面作用：定义用于筛选「转生炎兽」怪兽的过滤函数
function c25166510.cfilter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER)
end
-- 规则层面作用：判断自己墓地是否存在3只以上「转生炎兽」怪兽
function c25166510.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断自己墓地是否存在3只以上「转生炎兽」怪兽
	return Duel.IsExistingMatchingCard(c25166510.cfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- 规则层面作用：设置特殊召唤的条件检查
function c25166510.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 规则层面作用：设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面作用：执行特殊召唤操作
function c25166510.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 规则层面作用：将卡片以守备表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 规则层面作用：定义用于筛选炎属性连接怪兽的过滤函数
function c25166510.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_LINK) and c:IsAbleToExtra()
end
-- 规则层面作用：设置效果2的目标选择和条件检查
function c25166510.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25166510.tdfilter(chkc) end
	-- 规则层面作用：计算对方场上表侧表示的卡的数量
	local ct=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	-- 规则层面作用：检查是否满足效果2的发动条件
	if chk==0 then return ct>0 and Duel.IsExistingTarget(c25166510.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 规则层面作用：提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 规则层面作用：选择目标卡
	local g=Duel.SelectTarget(tp,c25166510.tdfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
	-- 规则层面作用：设置返回卡组的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
-- 规则层面作用：执行效果2的主要处理流程
function c25166510.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 规则层面作用：将卡送回额外卡组
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 规则层面作用：获取对方场上的可无效化卡
	local tg=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	-- 规则层面作用：判断是否发动无效化效果
	if ct>0 and #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(25166510,2)) then  --"是否选卡无效？"
		-- 规则层面作用：中断当前效果处理
		Duel.BreakEffect()
		-- 规则层面作用：提示玩家选择要无效的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		local sg=tg:Select(tp,1,ct,nil)
		-- 规则层面作用：显示被选为对象的卡
		Duel.HintSelection(sg)
		local tc=sg:GetFirst()
		while tc do
			-- 效果原文内容：直到回合结束时那个效果无效。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 效果原文内容：直到回合结束时那个效果无效。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			tc=sg:GetNext()
		end
	end
end

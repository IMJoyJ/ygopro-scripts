--ソーンヴァレル・ドラゴン
-- 效果：
-- 包含「弹丸」怪兽的龙族怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：丢弃1张手卡，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。这个效果把连接怪兽破坏的场合，可以再把最多有那个连接标记数量的「弹丸」怪兽从自己的手卡·墓地特殊召唤（同名卡最多1张）。这个效果的发动后，直到回合结束时自己不能把连接2以下的怪兽从额外卡组特殊召唤。
function c29296344.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2只满足条件的怪兽作为连接素材，且连接素材中必须包含「弹丸」怪兽
	aux.AddLinkProcedure(c,c29296344.mfilter,2,2,c29296344.lcheck)
	c:EnableReviveLimit()
	-- ①：丢弃1张手卡，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。这个效果把连接怪兽破坏的场合，可以再把最多有那个连接标记数量的「弹丸」怪兽从自己的手卡·墓地特殊召唤（同名卡最多1张）。这个效果的发动后，直到回合结束时自己不能把连接2以下的怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,29296344)
	e1:SetCost(c29296344.cost)
	e1:SetTarget(c29296344.target)
	e1:SetOperation(c29296344.operation)
	c:RegisterEffect(e1)
end
-- 连接素材过滤函数，判断怪兽是否为龙族或具有特定效果（77189532）
function c29296344.mfilter(c)
	return c:IsLinkRace(RACE_DRAGON) or c:IsHasEffect(77189532)
end
-- 连接召唤条件检查函数，判断连接素材中是否包含「弹丸」卡组
function c29296344.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x102)
end
-- 效果发动的费用，丢弃1张手卡
function c29296344.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置效果的目标，选择场上1只表侧表示怪兽
function c29296344.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只表侧表示怪兽作为目标
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，确定破坏目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 特殊召唤过滤函数，筛选「弹丸」怪兽且可特殊召唤
function c29296344.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的处理函数，执行破坏和特殊召唤操作
function c29296344.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且被破坏成功且为连接怪兽
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and tc:IsType(TYPE_LINK) then
		-- 计算可特殊召唤的「弹丸」怪兽数量
		local ct=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),tc:GetLink())
		if ct>0 then
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
			-- 获取满足条件的「弹丸」怪兽组
			local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c29296344.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
			-- 判断是否有满足条件的怪兽且玩家选择特殊召唤
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(29296344,0)) then  --"是否特殊召唤「弹丸」怪兽？"
				-- 中断当前效果处理，使后续处理视为不同时处理
				Duel.BreakEffect()
				-- 提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 从符合条件的怪兽中选择满足条件的子组
				local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
				-- 将选择的怪兽特殊召唤到场上
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	-- 设置效果，使玩家在回合结束前不能特殊召唤连接2以下的怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c29296344.splimit)
	-- 将效果注册到玩家全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的条件，禁止特殊召唤连接2以下的额外怪兽
function c29296344.splimit(e,c,tp,sumtp,sumpos)
	return c:IsType(TYPE_LINK) and c:IsLinkBelow(2) and c:IsLocation(LOCATION_EXTRA)
end

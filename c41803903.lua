--魔界台本「ロマンティック・テラー」
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：选自己场上1只「魔界剧团」灵摆怪兽回到持有者手卡，原本卡名和回到手卡的怪兽不同的1只表侧表示的「魔界剧团」灵摆怪兽从自己的额外卡组守备表示特殊召唤。
-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。从卡组选「魔界台本」魔法卡任意数量在自己的魔法与陷阱区域盖放。
function c41803903.initial_effect(c)
	-- ①：选自己场上1只「魔界剧团」灵摆怪兽回到持有者手卡，原本卡名和回到手卡的怪兽不同的1只表侧表示的「魔界剧团」灵摆怪兽从自己的额外卡组守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,41803903+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c41803903.target)
	e1:SetOperation(c41803903.activate)
	c:RegisterEffect(e1)
	-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。从卡组选「魔界台本」魔法卡任意数量在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c41803903.setcon)
	e2:SetTarget(c41803903.settg)
	e2:SetOperation(c41803903.setop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的场上灵摆怪兽，该怪兽需可返回手牌且其原本卡名与目标怪兽不同，且额外卡组存在符合条件的灵摆怪兽。
function c41803903.thfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x10ec) and c:IsAbleToHand()
		-- 检查额外卡组是否存在满足条件的灵摆怪兽。
		and Duel.IsExistingMatchingCard(c41803903.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 筛选额外卡组中满足条件的灵摆怪兽，该怪兽需与目标怪兽卡名不同，且可特殊召唤。
function c41803903.spfilter(c,e,tp,hc)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x10ec)
		and not c:IsOriginalCodeRule(hc:GetOriginalCodeRule())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查目标怪兽是否可特殊召唤到额外卡组。
		and Duel.GetLocationCountFromEx(tp,tp,hc,c)>0
end
-- 设置连锁处理信息，确定效果处理时将要返回手牌和特殊召唤的卡。
function c41803903.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c41803903.thfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 设置效果处理时将要返回手牌的卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
	-- 设置效果处理时将要特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果，选择目标怪兽返回手牌并特殊召唤符合条件的额外卡组怪兽。
function c41803903.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的场上灵摆怪兽。
	local hc=Duel.SelectMatchingCard(tp,c41803903.thfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	-- 将目标怪兽送回手牌并确认其已进入手牌。
	if hc and Duel.SendtoHand(hc,nil,REASON_EFFECT)~=0 and hc:IsLocation(LOCATION_HAND) then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的额外卡组灵摆怪兽。
		local g=Duel.SelectMatchingCard(tp,c41803903.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,hc)
		if g:GetCount()>0 then
			-- 将目标怪兽以守备表示特殊召唤到场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
-- 筛选额外卡组中满足条件的灵摆怪兽。
function c41803903.filter2(c)
	return c:IsSetCard(0x10ec) and c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 判断盖放的此卡是否因对方效果破坏且满足发动条件。
function c41803903.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		-- 检查额外卡组是否存在满足条件的灵摆怪兽。
		and Duel.IsExistingMatchingCard(c41803903.filter2,tp,LOCATION_EXTRA,0,1,nil)
end
-- 筛选卡组中满足条件的「魔界台本」魔法卡。
function c41803903.setfilter(c)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 设置连锁处理信息，确定效果处理时将要盖放的卡。
function c41803903.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c41803903.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 处理效果，从卡组选择满足条件的魔法卡并盖放。
function c41803903.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中满足条件的魔法卡。
	local g=Duel.GetMatchingGroup(c41803903.setfilter,tp,LOCATION_DECK,0,nil)
	-- 计算可盖放的魔法与陷阱区域数量。
	local ct=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),g:GetCount())
	if ct<=0 then return end
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	local sg=g:Select(tp,1,ct,nil)
	-- 将目标卡盖放到玩家的魔法与陷阱区域。
	Duel.SSet(tp,sg)
end

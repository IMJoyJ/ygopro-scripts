--魔界台本「ロマンティック・テラー」
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：选自己场上1只「魔界剧团」灵摆怪兽回到持有者手卡，原本卡名和回到手卡的怪兽不同的1只表侧表示的「魔界剧团」灵摆怪兽从自己的额外卡组守备表示特殊召唤。
-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。从卡组选「魔界台本」魔法卡任意数量在自己的魔法与陷阱区域盖放。
function c41803903.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：选自己场上1只「魔界剧团」灵摆怪兽回到持有者手卡，原本卡名和回到手卡的怪兽不同的1只表侧表示的「魔界剧团」灵摆怪兽从自己的额外卡组守备表示特殊召唤。
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
-- 定义「魔界剧团」灵摆怪兽返回手牌的筛选函数：要求表侧表示、灵摆、属于「魔界剧团」字段且可加入手牌，并确认额外卡组存在可特殊召唤的对象。
function c41803903.thfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x10ec) and c:IsAbleToHand()
		-- 检查额外卡组是否存在至少1张满足spfilter（可特殊召唤且卡名不同）的「魔界剧团」灵摆怪兽，以确保返回手牌后效果能够继续处理。
		and Duel.IsExistingMatchingCard(c41803903.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 定义从额外卡组特殊召唤的筛选函数：要求表侧表示、灵摆、属于「魔界剧团」字段、原本卡名与返回手牌的怪兽不同、可以表侧守备表示特殊召唤，且额外怪兽区域有可用空格。
function c41803903.spfilter(c,e,tp,hc)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x10ec)
		and not c:IsOriginalCodeRule(hc:GetOriginalCodeRule())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 确认在返回手牌的怪兽离场后，玩家仍有足够的额外卡组怪兽特殊召唤空格来特殊召唤c。
		and Duel.GetLocationCountFromEx(tp,tp,hc,c)>0
end
-- 效果①发动的目标判定：检查自己场上有无满足thfilter的怪兽，并设置操作信息：包含返回手卡和特殊召唤各1张。
function c41803903.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）确认自己场上存在至少1只可作为cost返回手牌的「魔界剧团」灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c41803903.thfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 设置操作信息，声明此效果将进行1次返回手卡的操作，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
	-- 设置操作信息，声明此效果将进行1次从额外卡组的特殊召唤操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①处理：选择自己场上1只「魔界剧团」灵摆怪兽返回持有者手牌，若成功且该卡在手牌，则从额外卡组选择1只符合条件的「魔界剧团」灵摆怪兽表侧守备表示特殊召唤。
function c41803903.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己场上选择1只满足thfilter的「魔界剧团」灵摆怪兽，并取得该卡（hc）。
	local hc=Duel.SelectMatchingCard(tp,c41803903.thfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	-- 判断所选怪兽存在、成功返回手牌且当前位于手牌，以确认cost已支付并继续后续特殊召唤。
	if hc and Duel.SendtoHand(hc,nil,REASON_EFFECT)~=0 and hc:IsLocation(LOCATION_HAND) then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足spfilter（且与hc原本卡名不同）的「魔界剧团」灵摆怪兽，作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,c41803903.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,hc)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧守备表示特殊召唤到玩家自己的场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
-- 定义用于②发动条件的过滤器：检查是否存在表侧表示、属于「魔界剧团」字段的灵摆怪兽（用于确认额外卡组有表侧表示的「魔界剧团」灵摆怪兽）。
function c41803903.filter2(c)
	return c:IsSetCard(0x10ec) and c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- ②的发动条件：这张卡因对方的效果破坏，且破坏前由自己控制、位于场上且为里侧表示，并且额外卡组有表侧表示的「魔界剧团」灵摆怪兽。
function c41803903.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		-- 确认额外卡组存在至少1张表侧表示的「魔界剧团」灵摆怪兽。
		and Duel.IsExistingMatchingCard(c41803903.filter2,tp,LOCATION_EXTRA,0,1,nil)
end
-- 定义可盖放的「魔界台本」魔法卡筛选条件：属于「魔界台本」字段、是魔法卡且当前可以被盖放。
function c41803903.setfilter(c)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- ②发动的目标检查：确认卡组中至少存在1张满足setfilter的「魔界台本」魔法卡。
function c41803903.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时确认卡组存在可盖放的「魔界台本」魔法卡，以此作为能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c41803903.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果处理：获取卡组中所有可盖放的「魔界台本」魔法卡，计算可盖放数量上限（不超过魔陷区空格数），然后由玩家选择任意数量盖放到自己的魔法与陷阱区域。
function c41803903.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足setfilter的「魔界台本」魔法卡。
	local g=Duel.GetMatchingGroup(c41803903.setfilter,tp,LOCATION_DECK,0,nil)
	-- 计算可盖放数量：取魔陷区可用空格数与可选卡数量中的较小值作为上限。
	local ct=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),g:GetCount())
	if ct<=0 then return end
	-- 提示玩家选择要盖放的「魔界台本」魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	local sg=g:Select(tp,1,ct,nil)
	-- 将玩家选出的卡盖放到自己的魔法与陷阱区域。
	Duel.SSet(tp,sg)
end

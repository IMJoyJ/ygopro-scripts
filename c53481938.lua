--ヴァレット・バラージュ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只5星以外的龙族·暗属性怪兽送去墓地才能发动。这张卡从手卡特殊召唤。这个回合，自己不是暗属性怪兽不能从额外卡组特殊召唤。
-- ②：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，从自己的手卡·卡组·墓地·除外状态各把最多1只「弹丸雨幕龙」以外的「弹丸」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①手牌起动特召及额外特召限制效果，②场上诱发即时效果，被连接怪兽取对象时自身破坏并特殊召唤最多4只不同位置的「弹丸」怪兽效果。
function s.initial_effect(c)
	-- ①：从卡组把1只5星以外的龙族·暗属性怪兽送去墓地才能发动。这张卡从手卡特殊召唤。这个回合，自己不是暗属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，从自己的手卡·卡组·墓地·除外状态各把最多1只「弹丸雨幕龙」以外的「弹丸」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 定义代价过滤函数：过滤出属于暗属性龙族且等级非5星的卡组怪兽，且它们能够作为发动代价送去墓地。
function s.costfilter(c)
	return not c:IsLevel(5) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGraveAsCost()
end
-- 手牌特殊召唤的代价处理函数：确认卡组中存在符合条件的怪兽，提示并让玩家选择1只送去墓地作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为发动代价检测，确认卡组中是否至少存在1只等级非5星的暗属性龙族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家显示选择提示信息：请选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只符合代价过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 以发动代价的原因为由，将玩家选中的怪兽送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 手牌特殊召唤的效果发动准备和检测：确认主怪兽区域有空位，且本卡可以被特殊召唤，设置特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为效果发动检测，确认自己主要怪兽区域是否还有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：包含特殊召唤当前卡片自身的分类，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 手牌特殊召唤效果的实际处理过程：如果本卡仍与当前连锁关联，将其特殊召唤到场上，并施加本回合自己不能特殊召唤暗属性以外的额外卡组怪兽的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将本卡以表侧表示特殊召唤到玩家的怪兽区。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是暗属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制只可从额外卡组特召暗属性怪兽的效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制判定函数：若目标怪兽非暗属性且从额外卡组特殊召唤，则禁止该特殊召唤动作。
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:IsLocation(LOCATION_EXTRA)
end
-- 被连接怪兽取对象效果的触发条件检查：确认当前发动的效果是否以卡片为对象，且被取对象的卡片中包含本卡，同时触发效果的卡片是连接怪兽。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 从触发效果的连锁中获取所有的效果对象卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- 定义特召怪兽过滤函数：过滤出属于「弹丸」（0x102）且非本名（「弹丸雨幕龙」）的卡片，包括手牌、卡组、墓地或除外的表侧表示怪兽，且其能够被正常特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动阶段检测与准备：确认本卡可以被破坏，本卡离场后主怪兽区是否有空位，且手牌/卡组/墓地/除外区有符合特召条件的「弹丸」怪兽，然后设置破坏和特殊召唤的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable()
		-- 检查以当前卡片作为要离开场上的对象时，主要怪兽区域是否仍有空格可供使用。
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查手牌、卡组、墓地和除外区是否至少存在1只符合特殊召唤条件的「弹丸」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：包含破坏当前卡片本身的分类，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置操作信息：包含特殊召唤的分类，数量为1，目标区域为手牌、卡组、墓地以及除外区。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 多区域特殊召唤怪兽选取合法性检测：如果选择1只则无限制，若选择多只，则在手牌、卡组、墓地、除外区中每个区域选取的卡片数量不能超过1张。
function s.gcheck(g)
	if #g==1 then return true end
	return g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
		and g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)<=1
		and g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
		and g:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)<=1
end
-- 效果实际处理过程：如果本卡仍在场上，将其破坏。若破坏成功，从手牌、卡组、墓地、除外区中检索不受墓地限制影响的符合特召条件的「弹丸」怪兽，并在空位范围内选择最多4只特殊召唤到自己场上。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认本卡是否和当前连锁关联，如果关联，将其以效果原因进行破坏，并判断是否破坏成功。
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 在手牌、卡组、墓地以及除外区中筛选出不受王家长眠之谷影响的、可以特殊召唤的符合条件的「弹丸」怪兽组。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
		-- 获取玩家当前主要怪兽区域可以特殊召唤的空格数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft>0 and #g>0 then
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
			-- 向玩家显示选择提示信息：请选择要特殊召唤的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:SelectSubGroup(tp,s.gcheck,false,1,ft)
			if sg then
				-- 中断当前的特殊召唤效果处理，使得破坏操作与后续特殊召唤操作不同时进行（会使时点错开）。
				Duel.BreakEffect()
				-- 将玩家选择的各区域「弹丸」怪兽组以表侧表示特殊召唤到玩家的场上。
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

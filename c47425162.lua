--R－ACEクイック・アタッカー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·场上（表侧表示）让这张卡以外的1张「救援ACE队」卡回到卡组才能发动。这张卡从手卡特殊召唤。
-- ②：把这张卡解放才能发动。从卡组把1只「救援ACE队」怪兽加入手卡。那之后，只有对方场上才有怪兽存在的场合，可以把加入手卡的那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是炎属性怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册怪兽的①②两个起动效果：①在手卡发动，把手卡·场上表侧表示的自身以外的「救援ACE队」卡返回卡组后自身特殊召唤；②在场上发动，解放自身检索「救援ACE队」怪兽并视条件特殊召唤，且发动后限制非炎属性额外怪兽特殊召唤。两个效果各1回合1次。
function s.initial_effect(c)
	-- ①：从自己的手卡·场上（表侧表示）让这张卡以外的1张「救援ACE队」卡回到卡组才能发动。这张卡从手卡特殊召唤。
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
	-- ②：把这张卡解放才能发动。从卡组把1只「救援ACE队」怪兽加入手卡。那之后，只有对方场上才有怪兽存在的场合，可以把加入手卡的那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是炎属性怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 代价筛选函数：用于①的代价，要求是「救援ACE队」卡、表侧表示、可作为代价返回卡组，并且返回后自己场上仍有可用怪兽区。
function s.cfilter(c,tp)
	-- 具体过滤条件：属于「救援ACE队」、表侧表示、可作为代价返回卡组、返回后自己场上有可用怪兽区。
	return c:IsSetCard(0x18b) and c:IsFaceupEx() and c:IsAbleToDeckAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- ①的代价处理：从手卡或场上表侧表示选择1张此卡以外的「救援ACE队」卡，若在手卡则向对方展示，若在场上则显示选中动画，然后将其返回卡组并洗牌作为发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查代价可行性：我方手卡·场上表侧表示存在1张除自身外的「救援ACE队」卡，且返回后自己场上有可用怪兽区。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler(),tp) end
	-- 弹出“请选择要返回卡组的卡”的提示，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家从自己手卡·场上表侧表示的「救援ACE队」卡中选择1张（不能选择自身）作为返回卡组的代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,e:GetHandler(),tp)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		-- 若选中的卡在手卡，则向对方玩家展示，确认该卡确实作为代价返回卡组。
		Duel.ConfirmCards(1-tp,g)
	end
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD) then
		-- 若选中的卡在场上，则显示其被选中的动画，并将该卡记录为对象。
		Duel.HintSelection(g)
	end
	-- 将选中的卡返回持有者卡组并洗牌，作为①发动的代价。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- ①的发动目标判定：确认此卡自身能被特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本连锁将特殊召唤此卡，供相关时点和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果处理：如果此卡仍与连锁相关（未被无效或离场），则将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡从手卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②的代价处理：确认此卡可以被解放，然后解放自身作为发动代价。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 把此卡解放送去墓地，作为②发动所需的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 检索过滤函数：从卡组选择1只「救援ACE队」怪兽，且该怪兽能被加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x18b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②的发动目标：确认卡组存在满足条件的「救援ACE队」怪兽，并设置加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在1只以上符合条件的「救援ACE队」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将把1只怪兽从卡组加入手卡（数量1，位置卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②的效果处理：从卡组选1只「救援ACE队」怪兽加入手卡并展示；若对方场上有怪兽且自己场上无怪兽、有空位且该怪兽可特殊召唤，则询问玩家是否特殊召唤；最后设置“不能从额外卡组特殊召唤非炎属性怪兽”的约束。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的提示，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只符合条件的「救援ACE队」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选的怪兽加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的怪兽，确认检索内容。
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		-- 判断对方场上是否存在怪兽（用于决定后续能否特殊召唤）。
		if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
			-- 判断自己场上是否没有怪兽（满足“只有对方场上才有怪兽存在”的条件之一）。
			and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
			-- 判断自己场上是否有空余的怪兽区可供特殊召唤。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 询问玩家是否要把刚加入手卡的那只怪兽特殊召唤（选择“是”则继续处理）。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 中断当前效果链，使特殊召唤作为单独时点处理，避免错过时点。
			Duel.BreakEffect()
			-- 将检索到的怪兽以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是炎属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能从额外卡组特殊召唤非炎属性怪兽”的限制效果注册到当前回合的结束阶段前，影响我方。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件的判断函数：如果特殊召唤的怪兽来自额外卡组且不是炎属性，则禁止该特殊召唤。
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLocation(LOCATION_EXTRA)
end

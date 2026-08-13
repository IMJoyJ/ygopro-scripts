--白の循環礁
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只鱼族怪兽为对象才能发动。那只鱼族怪兽破坏，那1只同名怪兽从卡组加入手卡。这张卡的发动时自己场上有鱼族同调怪兽存在的场合，也能不加入手卡特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地2只鱼族同名怪兽为对象才能发动。那2只之内的1只回到卡组最下面，另1只特殊召唤。
local s,id,o=GetID()
-- 注册该卡的两个效果：e1为①效果的魔法卡发动效果（破坏并检索同名卡，或特殊召唤），e2为②效果的墓地起动效果（除外自身，将2只同名鱼族怪兽1只回卡组底、另1只特殊召唤），二者分别用id和id+o设置1回合1次限制。
function s.initial_effect(c)
	-- ①：以自己场上1只鱼族怪兽为对象才能发动。那只鱼族怪兽破坏，那1只同名怪兽从卡组加入手卡。这张卡的发动时自己场上有鱼族同调怪兽存在的场合，也能不加入手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地2只鱼族同名怪兽为对象才能发动。那2只之内的1只回到卡组最下面，另1只特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价：将墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- ①效果选取对象的过滤函数：对象必须为表侧表示鱼族怪兽，且卡组中存在至少1张同名卡，该同名卡可加入手卡，或当check2为真时可特殊召唤。
function s.filter(c,e,tp,check)
	-- check2表示：若发动时场上有鱼族同调怪兽（check为真）且破坏对象后己方怪兽区仍有空位，则允许后续检索的同名卡不加入手卡而直接特殊召唤。
	local check2=check and Duel.GetMZoneCount(tp,c)>0
	return c:IsRace(RACE_FISH) and c:IsFaceup()
		-- 检查卡组中是否存在1张与对象怪兽同名的卡，且该卡能够加入手卡，或在check2成立时能够特殊召唤，以此作为对象怪兽是否可选的额外条件。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check2,c:GetCode())
end
-- 检索候选卡的过滤函数：必须与对象怪兽同名，且要么能加入手卡，要么在check为真时能被特殊召唤。
function s.thfilter(c,e,tp,check,code)
	return c:IsCode(code) and (c:IsAbleToHand() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 判定某卡是否为表侧表示且为鱼族同调怪兽，用于检测己方场上是否存在鱼族同调怪兽。
function s.spcfilter(c)
	return c:IsRace(RACE_FISH) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- ①效果的发动时点处理：先检测己方场上是否有鱼族同调怪兽；然后选择自己场上1只符合条件的鱼族怪兽作为对象；若检测到有鱼族同调怪兽则给效果设置标签1，否则为0，并登记破坏对象的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查己方怪兽区是否存在表侧表示的鱼族同调怪兽，用于决定是否允许特殊召唤检索到的同名怪兽。
	local check=Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp,check) end
	-- 发动合法性检查：确认己方场上存在1只满足s.filter的鱼族怪兽可作为对象，否则不能发动①效果。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp,check) end
	-- 让玩家从己方场上选择1只满足条件的鱼族怪兽作为①效果的对象，并登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,check)
	if check then e:SetLabel(1) else e:SetLabel(0) end
	-- 登记本次连锁将破坏的对象及数量（1张），供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：先破坏对象怪兽；若破坏成功，在满足有鱼族同调怪兽且怪兽区有空位时，从卡组选择同名卡并由玩家选择加入手卡或特殊召唤；否则加入手卡并让对方确认。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	local code=tc:GetCode()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRace(RACE_FISH)
		-- 确认对象仍与效果关联、表侧表示且为鱼族，然后将其破坏，并仅在破坏成功时继续处理。
		and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 检查当前是否满足特殊召唤条件：己方怪兽区有空位，且发动时场上有鱼族同调怪兽（e:GetLabel()==1）。
		local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetLabel()==1
		-- 向玩家显示“请选择要操作的卡”的提示，用于从卡组选择同名卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 让玩家从卡组选择1张满足s.thfilter的同名怪兽（可加入手卡或可特召），并取出该卡。
		local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check,code):GetFirst()
		if not sc then return end
		-- 若满足可特召条件且该卡可以被特殊召唤，并且玩家选择“特殊召唤”（或者该卡不能加入手卡），则执行特殊召唤；否则加入手卡。此处Duel.SelectOption让玩家在“加入手卡”和“特殊召唤”间选择。
		if check and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选择的那张同名怪兽表侧攻击表示特殊召唤到己方场上，无需经过手卡。
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选择的那张同名怪兽加入持有者的手卡。
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			-- 让对方玩家确认被加入手卡的那张卡，以符合规则公开信息。
			Duel.ConfirmCards(1-tp,sc)
		end
	end
end
-- ②效果候选怪兽的过滤条件：候选卡需可作为效果对象且是鱼族并能回卡组，或者可以被特殊召唤；保证在同一组中能分别选出回卡组和特召的卡。
function s.tgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsRace(RACE_FISH)
		and c:IsAbleToDeck() or c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断某张候选卡c能否作为“回卡组”的一张：c本身能回卡组，且同组的剩余卡中存在至少1张可特殊召唤的怪兽。
function s.tdfilter1(c,g,e,tp)
	return c:IsAbleToDeck() and g:IsExists(Card.IsCanBeSpecialSummoned,1,c,e,0,tp,false,false)
end
-- 对2张卡组成的选择组进行校验：两张卡必须卡名相同，且其中至少1张可回卡组、另1张可特殊召唤，满足②效果要求。
function s.fselect(g,e,tp)
	return g:GetClassCount(Card.GetCode)==1 and g:IsExists(s.tdfilter1,1,nil,g,e,tp)
end
-- ②效果发动时点处理：从自己墓地选择一组（2张）同名鱼族怪兽作为对象，设定其中1只回卡组底、另1只特殊召唤，并登记相应操作信息；同时要求己方怪兽区有空位。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地中所有满足s.tgfilter的怪兽，作为②效果可选对象的候选集合。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chkc then return false end
	-- 发动合法性检查：己方怪兽区有空位，并且墓地候选组中存在一组2张同名鱼族怪兽，满足1张可回卡组、另1张可特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:CheckSubGroup(s.fselect,2,2,e,tp) end
	-- 向玩家显示“请选择要操作的卡”的提示，用于选择墓地对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2,e,tp)
	-- 将选中的2张墓地怪兽设置为当前连锁的对象，供效果处理时追踪。
	Duel.SetTargetCard(sg)
	-- 登记本次连锁将把1张卡从墓地返回卡组的操作信息（不指定具体卡，处理时选择），供其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	-- 登记本次连锁将从墓地特殊召唤1只怪兽的操作信息（不指定具体卡，处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：取得连锁的2张对象卡，选择其中1张能回卡组的卡送回卡组最下面；若该卡确实回到卡组/额外卡组，则将另1张卡特殊召唤到己方场上。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与当前连锁关联的2张对象卡（发动②效果时选择的墓地鱼族怪兽）。
	local g=Duel.GetTargetsRelateToChain()
	if #g~=2 then return end
	local exg=nil
	-- 检查己方怪兽区是否有空位，只有在有空位时才允许特殊召唤其中1只怪兽。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		exg=g:Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
		if #exg==2 then exg=nil end
	end
	-- 向玩家显示“请选择要返回卡组的卡”的提示，让玩家选择1只要送回卡组最下面的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local dc=g:FilterSelect(tp,Card.IsAbleToDeck,1,1,exg):GetFirst()
	if not dc then return end
	g:RemoveCard(dc)
	-- 将选择的怪兽以效果原因送回持有者卡组最下面。
	Duel.SendtoDeck(dc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	if dc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 将另一只对象怪兽表侧攻击表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

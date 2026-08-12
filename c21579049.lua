--白の循環礁
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只鱼族怪兽为对象才能发动。那只鱼族怪兽破坏，那1只同名怪兽从卡组加入手卡。这张卡的发动时自己场上有鱼族同调怪兽存在的场合，也能不加入手卡特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地2只鱼族同名怪兽为对象才能发动。那2只之内的1只回到卡组最下面，另1只特殊召唤。
local s,id,o=GetID()
-- 注册卡的效果，包括①②两个效果，①为发动效果，②为墓地发动效果
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
	-- 将此卡从墓地除外作为②效果的费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤场上满足条件的鱼族怪兽，用于①效果的目标选择
function s.filter(c,e,tp,check)
	-- 判断目标怪兽是否满足特殊召唤条件
	local check2=check and Duel.GetMZoneCount(tp,c)>0
	return c:IsRace(RACE_FISH) and c:IsFaceup()
		-- 检查卡组中是否存在同名卡且满足加入手牌或特殊召唤的条件
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check2,c:GetCode())
end
-- 过滤卡组中满足条件的同名卡，用于①效果的检索
function s.thfilter(c,e,tp,check,code)
	return c:IsCode(code) and (c:IsAbleToHand() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 过滤场上满足条件的鱼族同调怪兽，用于①效果的条件判断
function s.spcfilter(c)
	return c:IsRace(RACE_FISH) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- ①效果的目标选择处理，判断是否满足条件并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断场上是否存在鱼族同调怪兽
	local check=Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp,check) end
	-- 检查是否能选择满足条件的鱼族怪兽作为①效果的目标
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp,check) end
	-- 选择满足条件的鱼族怪兽作为①效果的目标
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,check)
	if check then e:SetLabel(1) else e:SetLabel(0) end
	-- 设置①效果的破坏操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果的处理函数，对目标怪兽进行破坏并检索同名卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	local code=tc:GetCode()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRace(RACE_FISH)
		-- 对目标怪兽进行破坏
		and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 判断是否满足特殊召唤条件
		local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetLabel()==1
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从卡组中选择满足条件的同名卡
		local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check,code):GetFirst()
		if not sc then return end
		-- 判断是否满足特殊召唤条件并选择操作方式
		if check and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选中的卡特殊召唤
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选中的卡加入手牌
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sc)
		end
	end
end
-- 过滤墓地中满足条件的鱼族怪兽，用于②效果的目标选择
function s.tgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsRace(RACE_FISH)
		and c:IsAbleToDeck() or c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤满足条件的卡，用于②效果的子组判断
function s.tdfilter1(c,g,e,tp)
	return c:IsAbleToDeck() and g:IsExists(Card.IsCanBeSpecialSummoned,1,c,e,0,tp,false,false)
end
-- 判断墓地中的卡是否满足②效果的条件
function s.fselect(g,e,tp)
	return g:GetClassCount(Card.GetCode)==1 and g:IsExists(s.tdfilter1,1,nil,g,e,tp)
end
-- ②效果的目标选择处理，选择满足条件的2只鱼族怪兽
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取墓地中满足条件的鱼族怪兽
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chkc then return false end
	-- 检查是否能选择满足条件的2只鱼族怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:CheckSubGroup(s.fselect,2,2,e,tp) end
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2,e,tp)
	-- 设置②效果的目标卡
	Duel.SetTargetCard(sg)
	-- 设置②效果的回卡组操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	-- 设置②效果的特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的处理函数，将1只卡回卡组底部，另1只特殊召唤
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中涉及的目标卡
	local g=Duel.GetTargetsRelateToChain()
	if #g~=2 then return end
	local exg=nil
	-- 判断场上是否有空位可特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		exg=g:Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
		if #exg==2 then exg=nil end
	end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local dc=g:FilterSelect(tp,Card.IsAbleToDeck,1,1,exg):GetFirst()
	if not dc then return end
	g:RemoveCard(dc)
	-- 将选中的卡送回卡组底部
	Duel.SendtoDeck(dc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	if dc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 将剩余的卡特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

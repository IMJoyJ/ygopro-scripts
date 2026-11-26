--白の循環礁
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只鱼族怪兽为对象才能发动。那只鱼族怪兽破坏，那1只同名怪兽从卡组加入手卡。这张卡的发动时自己场上有鱼族同调怪兽存在的场合，也能不加入手卡特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地2只鱼族同名怪兽为对象才能发动。那2只之内的1只回到卡组最下面，另1只特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（破坏己方场上鱼族怪兽并从卡组检索或特召同名怪兽）与②效果（除外墓地自身将墓地2只同名鱼族怪兽1只回卡组底、另1只特召）
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。 ①：以自己场上1只鱼族怪兽为对象才能发动。那只鱼族怪兽破坏，那1只同名怪兽从卡组加入手卡。这张卡的发动时自己场上有鱼族同调怪兽存在的场合，也能不加入手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
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
	-- 设置②效果的发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 筛选条件：检查己方场上怪兽是否为表侧鱼族怪兽，且卡组中存在可加入手卡或在有鱼族同调怪兽且该怪兽离场后仍有空位时可特殊召唤的同名怪兽
function s.filter(c,e,tp,check)
	-- 判断是否满足特殊召唤条件：发动时存在鱼族同调怪兽，且目标怪兽离场后己方怪兽区存在可用空位
	local check2=check and Duel.GetMZoneCount(tp,c)>0
	return c:IsRace(RACE_FISH) and c:IsFaceup()
		-- 检查己方卡组中是否存在满足加入手卡或特殊召唤条件的同名怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check2,c:GetCode())
end
-- 筛选条件：检查卡组中的卡是否与目标怪兽同名，且可加入手卡或在满足条件时可特殊召唤
function s.thfilter(c,e,tp,check,code)
	return c:IsCode(code) and (c:IsAbleToHand() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 筛选条件：检查卡片是否为表侧表示的鱼族同调怪兽
function s.spcfilter(c)
	return c:IsRace(RACE_FISH) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- ①效果的发动检测、取对象及信息设置：记录发动时己方场上是否存在鱼族同调怪兽，选择己方场上1只鱼族怪兽作为对象并登记破坏操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查发动时己方怪兽区是否存在表侧表示的鱼族同调怪兽
	local check=Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_MZONE,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp,check) end
	-- 发动条件检查：确认己方怪兽区存在可成为对象且卡组有对应同名卡的鱼族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp,check) end
	-- 让己方选择己方怪兽区1只满足条件的鱼族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,check)
	if check then e:SetLabel(1) else e:SetLabel(0) end
	-- 登记连锁的破坏操作信息，预计破坏所选对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果的处理流程：破坏对象鱼族怪兽后，从卡组选1只同名怪兽；若发动时有鱼族同调怪兽且当前有空位则可选特殊召唤，否则加入手卡并展示
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁所指定的对象怪兽
	local tc=Duel.GetFirstTarget()
	local code=tc:GetCode()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRace(RACE_FISH)
		-- 以效果破坏对象怪兽并判断是否破坏成功
		and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 检查当前己方怪兽区是否有空位且发动时记录了存在鱼族同调怪兽的标记
		local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetLabel()==1
		-- 向己方提示选择要从卡组操作的同名卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 让己方从己方卡组选择1张满足条件的同名怪兽
		local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check,code):GetFirst()
		if not sc then return end
		-- 若满足特殊召唤条件且该卡能被特殊召唤，并且在不能加入手卡或己方选择特殊召唤时进入特殊召唤分支
		if check and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选出的同名怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 以效果将选出的同名怪兽加入持有者手卡
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			-- 向对方展示加入手卡的卡片
			Duel.ConfirmCards(1-tp,sc)
		end
	end
end
-- 筛选条件：检查墓地卡片是否可作为对象、为鱼族且可回卡组或可特殊召唤
function s.tgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsRace(RACE_FISH)
		and c:IsAbleToDeck() or c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选条件：检查所选卡组中某张卡能否返回卡组，同时组内另1张卡能否被特殊召唤
function s.tdfilter1(c,g,e,tp)
	return c:IsAbleToDeck() and g:IsExists(Card.IsCanBeSpecialSummoned,1,c,e,0,tp,false,false)
end
-- 子组校验函数：检查所选2张卡是否卡名相同，且其中1张可回卡组、另1张可特殊召唤
function s.fselect(g,e,tp)
	return g:GetClassCount(Card.GetCode)==1 and g:IsExists(s.tdfilter1,1,nil,g,e,tp)
end
-- ②效果的发动检测、取对象及信息设置：确认怪兽区有空位且墓地存在满足条件的2只同名鱼族怪兽，选择它们作为对象并登记回卡组与特召信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取己方墓地中符合筛选条件的卡片组
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chkc then return false end
	-- 发动条件检查：确认己方怪兽区有空位，且墓地存在符合条件的2只同名鱼族怪兽组合
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:CheckSubGroup(s.fselect,2,2,e,tp) end
	-- 向己方提示选择要作为对象的2只鱼族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2,e,tp)
	-- 将选出的2只同名怪兽设为当前连锁的对象卡
	Duel.SetTargetCard(sg)
	-- 登记连锁的返回卡组操作信息，预计将己方墓地1张卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	-- 登记连锁的特殊召唤操作信息，预计将己方墓地1张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的处理流程：确认2只对象仍与连锁有联系，选其中1只返回卡组最下面，并把另1只特殊召唤到己方场上
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前仍与本连锁存在联系的对象卡片组
	local g=Duel.GetTargetsRelateToChain()
	if #g~=2 then return end
	local exg=nil
	-- 检查当前己方主要怪兽区是否仍有空位，用于过滤避免把唯一可特召的怪兽选去回卡组
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		exg=g:Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false)
		if #exg==2 then exg=nil end
	end
	-- 向己方提示选择要返回卡组最下面的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local dc=g:FilterSelect(tp,Card.IsAbleToDeck,1,1,exg):GetFirst()
	if not dc then return end
	g:RemoveCard(dc)
	-- 以效果将所选的1只怪兽返回持有者卡组最下面
	Duel.SendtoDeck(dc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	if dc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 将剩下的另1只怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

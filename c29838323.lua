--水晶機巧－シストバーン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「水晶机巧」调整特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族同调怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把「水晶机巧-紫晶龙」以外的1只「水晶机巧」怪兽加入手卡。
function c29838323.initial_effect(c)
	-- ①：以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「水晶机巧」调整特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29838323,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,29838323)
	e1:SetTarget(c29838323.sptg)
	e1:SetOperation(c29838323.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把「水晶机巧-紫晶龙」以外的1只「水晶机巧」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29838323,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,29838323)
	-- 将这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c29838323.thtg)
	e2:SetOperation(c29838323.thop)
	c:RegisterEffect(e2)
end
-- 破坏效果的对象过滤器，用于筛选场上表侧表示的卡
function c29838323.desfilter(c)
	return c:IsFaceup()
end
-- 特殊召唤的过滤器，用于筛选「水晶机巧」调整
function c29838323.spfilter(c,e,tp)
	return c:IsSetCard(0xea) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动时点处理，判断是否满足发动条件
function c29838323.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(e:GetLabel()) and chkc:IsControler(tp) and c29838323.desfilter(chkc) end
	if chk==0 then
		-- 获取玩家场上怪兽区域的可用空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<-1 then return false end
		local loc=LOCATION_ONFIELD
		if ft==0 then loc=LOCATION_MZONE end
		e:SetLabel(loc)
		-- 检查场上是否存在满足条件的破坏对象
		return Duel.IsExistingTarget(c29838323.desfilter,tp,loc,0,1,nil)
			-- 检查卡组中是否存在满足条件的特殊召唤对象
			and Duel.IsExistingMatchingCard(c29838323.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的目标卡
	local g=Duel.SelectTarget(tp,c29838323.desfilter,tp,e:GetLabel(),0,1,1,nil)
	-- 设置操作信息，记录将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，记录将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的执行函数，执行破坏和特殊召唤操作
function c29838323.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效并执行破坏操作
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择要特殊召唤的卡
		local g=Duel.SelectMatchingCard(tp,c29838323.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的卡特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置一个直到回合结束时生效的限制效果，禁止玩家从额外卡组特殊召唤非机械族同调怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c29838323.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的判断函数，禁止非机械族同调怪兽从额外卡组特殊召唤
function c29838323.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:IsType(TYPE_SYNCHRO)) and c:IsLocation(LOCATION_EXTRA)
end
-- 检索效果的对象过滤器，用于筛选「水晶机巧」怪兽（除紫晶龙外）
function c29838323.thfilter(c)
	return c:IsSetCard(0xea) and c:IsType(TYPE_MONSTER) and not c:IsCode(29838323) and c:IsAbleToHand()
end
-- 检索效果的发动时点处理，判断是否满足发动条件
function c29838323.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的检索对象
	if chk==0 then return Duel.IsExistingMatchingCard(c29838323.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，记录将要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理时的执行函数，执行检索操作
function c29838323.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择要加入手牌的卡
	local g=Duel.SelectMatchingCard(tp,c29838323.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

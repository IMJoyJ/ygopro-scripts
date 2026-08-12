--水晶機巧－スモーガー
-- 效果：
-- 「水晶机巧-烟晶虎」的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「水晶机巧」调整特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族同调怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「水晶机巧」魔法·陷阱卡加入手卡。
function c83443619.initial_effect(c)
	-- ①：以自己场上1张表侧表示的卡为对象才能发动。那张卡破坏，从卡组把1只「水晶机巧」调整特殊召唤。这个效果的发动后，直到回合结束时自己不是机械族同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83443619,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,83443619)
	e1:SetTarget(c83443619.sptg)
	e1:SetOperation(c83443619.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1张「水晶机巧」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83443619,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,83443619)
	-- 把墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c83443619.thtg)
	e2:SetOperation(c83443619.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的卡
function c83443619.desfilter(c)
	return c:IsFaceup()
end
-- 过滤条件：卡组中可以特殊召唤的「水晶机巧」调整怪兽
function c83443619.spfilter(c,e,tp)
	return c:IsSetCard(0xea) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备（检查怪兽区域空格、确定可选对象范围、选择要破坏的卡并设置效果分类信息）
function c83443619.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(e:GetLabel()) and chkc:IsControler(tp) and c83443619.desfilter(chkc) end
	if chk==0 then
		-- 获取自身场上可用怪兽区域的数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<-1 then return false end
		local loc=LOCATION_ONFIELD
		if ft==0 then loc=LOCATION_MZONE end
		e:SetLabel(loc)
		-- 检查场上是否存在可以作为效果对象的表侧表示卡片
		return Duel.IsExistingTarget(c83443619.desfilter,tp,loc,0,1,nil)
			-- 检查卡组中是否存在可以特殊召唤的「水晶机巧」调整怪兽
			and Duel.IsExistingMatchingCard(c83443619.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1张表侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,c83443619.desfilter,tp,e:GetLabel(),0,1,1,nil)
	-- 设置效果处理信息为破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的处理（破坏对象卡，特殊召唤调整怪兽，并添加只能特殊召唤机械族同调怪兽的限制）
function c83443619.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍适用效果，将其破坏，若破坏成功且怪兽区域有空位则继续处理
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从卡组选择1只满足条件的「水晶机巧」调整怪兽
		local g=Duel.SelectMatchingCard(tp,c83443619.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是机械族同调怪兽不能从额外卡组特殊召唤。②：把墓地的这张卡除外才能发动。从卡组把1张「水晶机巧」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c83443619.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该限制效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能从额外卡组特殊召唤机械族同调怪兽以外的怪兽
function c83443619.splimit(e,c)
	return not (c:IsRace(RACE_MACHINE) and c:IsType(TYPE_SYNCHRO)) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：卡组中可以加入手牌的「水晶机巧」魔法·陷阱卡
function c83443619.thfilter(c)
	return c:IsSetCard(0xea) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②号效果的发动准备（检查卡组中是否存在可检索的卡，并设置检索效果分类信息）
function c83443619.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「水晶机巧」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c83443619.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的处理（从卡组选择1张「水晶机巧」魔法·陷阱卡加入手牌并给对方确认）
function c83443619.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足条件的「水晶机巧」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c83443619.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

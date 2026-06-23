--地縛囚人 ライン・ウォーカー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1张「地缚牢」或「异界共鸣-同调融合」加入手卡。
-- ②：自己场上有6星以上的「地缚」怪兽存在的场合，把墓地的这张卡除外，以从额外卡组特殊召唤的对方场上1只效果怪兽为对象才能发动。那只效果怪兽回到卡组。那之后，对方可以把那1只同名怪兽从自身的额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果，包括①②两个效果，分别对应召唤/特殊召唤时的检索和墓地发动的特殊召唤效果
function s.initial_effect(c)
	-- 记录该卡拥有「地缚牢」和「异界共鸣-同调融合」这两个卡名
	aux.AddCodeList(c,71089030,7473735)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的卡组·墓地把1张「地缚牢」或「异界共鸣-同调融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己场上有6星以上的「地缚」怪兽存在的场合，把墓地的这张卡除外，以从额外卡组特殊召唤的对方场上1只效果怪兽为对象才能发动。那只效果怪兽回到卡组。那之后，对方可以把那1只同名怪兽从自身的额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.tdcon)
	-- 将此卡从墓地除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于检索「地缚牢」或「异界共鸣-同调融合」卡
function s.filter(c)
	return c:IsCode(71089030,7473735) and c:IsAbleToHand()
end
-- 设置检索效果的处理条件，检查场上是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息，表示将要将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 处理检索效果，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于判断场上是否存在6星以上的「地缚」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(6) and c:IsSetCard(0x21)
end
-- 设置墓地发动效果的触发条件，检查场上是否存在6星以上的「地缚」怪兽
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在6星以上的「地缚」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断对方场上从额外卡组特殊召唤的效果怪兽
function s.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToDeck()
end
-- 设置墓地发动效果的目标选择处理，选择对方场上的效果怪兽
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.dfilter(chkc) end
	-- 检查对方场上是否存在满足条件的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(s.dfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上的效果怪兽
	local g=Duel.SelectTarget(tp,s.dfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示将要将卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 过滤函数，用于判断额外卡组中是否存在可特殊召唤的同名怪兽
function s.sfilter(c,e,tp,...)
	return c:IsCode(...) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否有足够的召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 处理墓地发动效果，将目标怪兽返回卡组并询问是否特殊召唤同名怪兽
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_EFFECT)
		-- 将目标怪兽返回卡组
		and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 获取额外卡组中可特殊召唤的同名怪兽
		local g=Duel.GetMatchingGroup(s.sfilter,tp,0,LOCATION_EXTRA,nil,e,1-tp,tc:GetCode())
		-- 询问对方是否特殊召唤同名怪兽
		if #g>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then  --"是否特殊召唤同名怪兽？"
			-- 提示对方选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(1-tp,1,1,nil)
			-- 中断当前效果处理，使后续效果能正常处理
			Duel.BreakEffect()
			-- 将选中的同名怪兽特殊召唤到对方场上
			Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end

--ミミグル・ルーム
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从手卡·卡组选1只「迷拟宝箱鬼」怪兽在自己场上特殊召唤或在对方场上里侧守备表示特殊召唤。那之后，可以把场上1只表侧表示怪兽变成里侧守备表示。
-- ②：把墓地的这张卡除外，以自己场上的「迷拟宝箱鬼」卡任意数量为对象才能发动。那些卡回到手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- ①：从手卡·卡组选1只「迷拟宝箱鬼」怪兽在自己场上特殊召唤或在对方场上里侧守备表示特殊召唤。那之后，可以把场上1只表侧表示怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上的「迷拟宝箱鬼」卡任意数量为对象才能发动。那些卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	-- 将把墓地的这张卡除外作为效果发动的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤手卡·卡组中可以特殊召唤到自己场上或对方场上里侧守备表示的「迷拟宝箱鬼」怪兽。
function s.filter(c,e,tp)
	-- 检查是否为「迷拟宝箱鬼」怪兽，且自己场上有空位并可以特殊召唤。
	return c:IsSetCard(0x1b7) and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 或者对方场上有空位并可以里侧守备表示特殊召唤。
		or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0)
end
-- 效果①的发动准备与合法性检查。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·卡组是否存在满足特殊召唤条件的「迷拟宝箱鬼」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 过滤场上可以变成里侧守备表示的表侧表示怪兽。
function s.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果①的处理函数，执行特殊召唤及后续的表示形式变更。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只满足条件的「迷拟宝箱鬼」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 检查是否可以特殊召唤到自己场上。
		local s1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否可以里侧守备表示特殊召唤到对方场上。
		local s2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
		-- 让玩家选择在自己场上特殊召唤或在对方场上里侧守备表示特殊召唤。
		local op=aux.SelectFromOptions(tp,
			{s1,aux.Stringid(id,2),tp},  --"在自己场上特殊召唤"
			{s2,aux.Stringid(id,3),1-tp})  --"在对方场上特殊召唤"
		local sumpos=op==tp and POS_FACEUP or POS_FACEDOWN_DEFENCE
		-- 执行特殊召唤，若特殊召唤失败则结束效果处理。
		if Duel.SpecialSummon(tc,0,tp,op,false,false,sumpos)==0 then return end
		-- 若在对方场上里侧守备表示特殊召唤，则让对方玩家确认该卡。
		if op==1-tp then Duel.ConfirmCards(1-tp,tc) end
		-- 检查场上是否存在可以变成里侧守备表示的表侧表示怪兽。
		if Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			-- 询问玩家是否要把场上1只表侧表示怪兽变成里侧守备表示。
			and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否把怪兽变成里侧守备表示？"
			-- 中断当前效果处理，使后续的表示形式变更与特殊召唤不视为同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要改变表示形式的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			-- 选择场上1只表侧表示怪兽。
			local sg=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			-- 显式示出所选择的怪兽。
			Duel.HintSelection(sg)
			-- 将选择的怪兽变成里侧守备表示。
			Duel.ChangePosition(sg:GetFirst(),POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 过滤自己场上表侧表示且可以回到手牌的「迷拟宝箱鬼」卡片。
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1b7) and c:IsAbleToHand()
end
-- 效果②的发动准备、对象选择与合法性检查。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查自己场上是否存在可以回到手牌的「迷拟宝箱鬼」卡片。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要回到手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上任意数量的「迷拟宝箱鬼」卡片作为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,99,nil)
	-- 设置回到手牌的操作信息，指定对象卡片和数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 效果②的处理函数，执行将对象卡片回到手牌的操作。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在连锁处理时仍合法的对象卡片。
	local g=Duel.GetTargetsRelateToChain()
	if #g>0 then
		-- 将这些卡片回到持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end

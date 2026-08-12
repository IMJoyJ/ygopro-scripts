--アルカナリーディング
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：进行1次投掷硬币，那个里表的以下效果适用。自己的场地区域有「光之结界」存在的场合，不进行投掷硬币而选里表的其中1个适用。
-- ●表：从卡组把「秘仪读牌」以外的1张持有进行投掷硬币效果的卡加入手卡。
-- ●里：对方从自身卡组选1张卡加入手卡。
-- ②：把墓地的这张卡除外才能发动。从手卡把1只「秘仪之力」怪兽召唤。
function c11819473.initial_effect(c)
	-- 为卡片注册关联卡片代码，标明该卡效果文本中提及了「光之结界」
	aux.AddCodeList(c,73206827)
	-- ①：进行1次投掷硬币，那个里表的以下效果适用。自己的场地区域有「光之结界」存在的场合，不进行投掷硬币而选里表的其中1个适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11819473,0))  --"投掷硬币"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11819473)
	e1:SetTarget(c11819473.target)
	e1:SetOperation(c11819473.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从手卡把1只「秘仪之力」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11819473,1))  --"召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,11819474)
	-- 设置效果发动时的费用为将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c11819473.sumtg)
	e2:SetOperation(c11819473.sumop)
	c:RegisterEffect(e2)
end
-- 定义用于筛选满足条件的卡的过滤函数，用于检索卡组中除自身外拥有投掷硬币效果的卡
function c11819473.thfilter1(c)
	-- 过滤条件：该卡不是自身且拥有投掷硬币效果且可以加入手牌
	return not c:IsCode(11819473) and c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN)) and c:IsAbleToHand()
end
-- 定义用于筛选满足条件的卡的过滤函数，用于检索对方卡组中可加入手牌的卡
function c11819473.thfilter2(c,p)
	return c:IsAbleToHand(p)
end
-- 定义效果发动时的处理函数，用于判断是否满足发动条件
function c11819473.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：自己卡组中存在满足thfilter1条件的卡或对方卡组中存在满足thfilter2条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c11819473.thfilter1,tp,LOCATION_DECK,0,1,nil)
		-- 检查是否满足发动条件：自己卡组中存在满足thfilter1条件的卡或对方卡组中存在满足thfilter2条件的卡
		or Duel.IsExistingMatchingCard(c11819473.thfilter2,tp,0,LOCATION_DECK,1,nil,1-tp) end
	-- 设置连锁操作信息：提示将进行一次投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	-- 设置连锁操作信息：提示将从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_DECK)
end
-- 定义效果发动时的处理函数，用于执行效果内容
function c11819473.activate(e,tp,eg,ep,ev,re,r,rp)
	local res
	-- 检查当前是否处于「光之结界」场地效果影响下
	if Duel.IsEnvironment(73206827,tp,LOCATION_FZONE) then
		local off=1
		local ops={}
		local opval={}
		-- 检查自己卡组中是否存在满足thfilter1条件的卡
		if Duel.IsExistingMatchingCard(c11819473.thfilter1,tp,LOCATION_DECK,0,1,nil) then
			ops[off]=aux.Stringid(11819473,2)  --"表：从卡组把持有进行投掷硬币效果的卡加入手卡"
			opval[off-1]=0
			off=off+1
		end
		-- 检查对方卡组中是否存在满足thfilter2条件的卡
		if Duel.IsExistingMatchingCard(c11819473.thfilter2,tp,0,LOCATION_DECK,1,nil,1-tp) then
			ops[off]=aux.Stringid(11819473,3)  --"里：对方从自身卡组选1张卡加入手卡"
			opval[off-1]=1
			off=off+1
		end
		if off==1 then return end
		-- 让玩家选择投掷硬币结果的选项
		local op=Duel.SelectOption(tp,table.unpack(ops))
		res=opval[op]
	else
		-- 进行一次投掷硬币并计算结果
		res=1-Duel.TossCoin(tp,1)
	end
	if res==0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- 从自己卡组中选择满足thfilter1条件的卡
		local g=Duel.SelectMatchingCard(tp,c11819473.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 提示对方选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
		-- 从对方卡组中选择满足thfilter2条件的卡
		local g=Duel.SelectMatchingCard(1-tp,c11819473.thfilter2,1-tp,LOCATION_DECK,0,1,1,nil,1-tp)
		if g:GetCount()>0 then
			g:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
-- 定义用于筛选满足条件的卡的过滤函数，用于检索手牌中可召唤的「秘仪之力」怪兽
function c11819473.sumfilter(c)
	return c:IsSetCard(0x5) and c:IsSummonable(true,nil)
end
-- 定义效果发动时的处理函数，用于判断是否满足发动条件
function c11819473.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：手牌中存在满足sumfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c11819473.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁操作信息：提示将召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 定义效果发动时的处理函数，用于执行效果内容
function c11819473.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	-- 从手牌中选择满足sumfilter条件的卡
	local g=Duel.SelectMatchingCard(tp,c11819473.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽进行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end

--ヒヤリ＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「@火灵天星」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把这张卡以外的自己场上1只电子界族怪兽解放才能发动。从卡组把1只5星以上的「@火灵天星」怪兽加入手卡，这张卡的等级直到回合结束时变成4星。为这个效果发动而把连接怪兽解放的场合，可以再从卡组把1张「“艾”之仪式」加入手卡。
function c41306080.initial_effect(c)
	-- ①：自己场上有「@火灵天星」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41306080,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,41306080)
	e1:SetCondition(c41306080.spcon)
	e1:SetTarget(c41306080.sptg)
	e1:SetOperation(c41306080.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡以外的自己场上1只电子界族怪兽解放才能发动。从卡组把1只5星以上的「@火灵天星」怪兽加入手卡，这张卡的等级直到回合结束时变成4星。为这个效果发动而把连接怪兽解放的场合，可以再从卡组把1张「“艾”之仪式」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41306080,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,41306081)
	e2:SetCost(c41306080.thcost)
	e2:SetTarget(c41306080.thtg)
	e2:SetOperation(c41306080.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在「@火灵天星」怪兽（正面表示）
function c41306080.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x135)
end
-- 效果条件函数，判断自己场上是否存在「@火灵天星」怪兽
function c41306080.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只「@火灵天星」怪兽
	return Duel.IsExistingMatchingCard(c41306080.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的目标设定函数，检查是否满足特殊召唤条件
function c41306080.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，将卡片特殊召唤到场上
function c41306080.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果解放怪兽的处理函数，选择并解放一只电子界族怪兽
function c41306080.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否存在至少1只电子界族怪兽可解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,c,RACE_CYBERSE) end
	-- 选择一只电子界族怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,c,RACE_CYBERSE)
	e:SetLabel(g:GetFirst():GetType())
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 检索过滤函数，用于筛选5星以上且为「@火灵天星」的怪兽
function c41306080.thfilter1(c)
	return c:IsLevelAbove(5) and c:IsSetCard(0x135) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果目标设定函数，检查是否满足检索条件
function c41306080.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查卡组中是否存在满足条件的「@火灵天星」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41306080.thfilter1,tp,LOCATION_DECK,0,1,nil)
		and not c:IsLevel(4) and c:IsLevelAbove(1) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索过滤函数，用于筛选「“艾”之仪式」
function c41306080.thfilter2(c)
	return c:IsCode(85327820) and c:IsAbleToHand()
end
-- 效果处理函数，执行检索并改变等级
function c41306080.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张满足条件的「@火灵天星」怪兽加入手牌
	local g1=Duel.SelectMatchingCard(tp,c41306080.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡加入手牌
	if g1:GetCount()>0 and Duel.SendtoHand(g1,nil,REASON_EFFECT)~=0 and g1:GetFirst():IsLocation(LOCATION_HAND) then
		-- 确认玩家手牌中加入的卡
		Duel.ConfirmCards(1-tp,g1)
		local c=e:GetHandler()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 创建等级改变效果，使卡片等级变为4星
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(4)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
			-- 获取卡组中所有「“艾”之仪式」
			local g2=Duel.GetMatchingGroup(c41306080.thfilter2,tp,LOCATION_DECK,0,nil)
			-- 判断是否为连接怪兽并询问是否检索「“艾”之仪式」
			if bit.band(e:GetLabel(),TYPE_LINK)~=0 and g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(41306080,2)) then  --"是否把「“艾”之仪式」加入手卡？"
				-- 中断当前效果处理，使后续效果视为错时点
				Duel.BreakEffect()
				-- 提示玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local sg=g2:Select(tp,1,1,nil)
				-- 将选定的「“艾”之仪式」加入手牌
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 确认玩家手牌中加入的卡
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end

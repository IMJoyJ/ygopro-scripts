--ヒヤリ＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「@火灵天星」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把这张卡以外的自己场上1只电子界族怪兽解放才能发动。从卡组把1只5星以上的「@火灵天星」怪兽加入手卡，这张卡的等级直到回合结束时变成4星。为这个效果发动而把连接怪兽解放的场合，可以再从卡组把1张「“艾”之仪式」加入手卡。
function c41306080.initial_effect(c)
	-- 注册卡片密码85327820（“艾”之仪式）到本卡的关系卡片列表中
	aux.AddCodeList(c,85327820)
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
-- 过滤场上正面表示的「@火灵天星」怪兽
function c41306080.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x135)
end
-- ①号效果的发动条件判定函数，检查我方场上是否存在「@火灵天星」怪兽
function c41306080.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在正面表示的「@火灵天星」怪兽
	return Duel.IsExistingMatchingCard(c41306080.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①号效果的发动靶指向（Target）函数，判断是否能够特殊召唤本卡并设置操作信息
function c41306080.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断我方主要怪兽区域是否还有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息，将本卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的执行逻辑（Operation）函数，特殊召唤本卡
function c41306080.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将本卡以正面表示特殊召唤到我方场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②号效果的发动代价（Cost）函数，解放自己场上除本卡以外的1只电子界族怪兽，并保存解放怪兽的卡片类型
function c41306080.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在除本卡外可解放的电子界族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,c,RACE_CYBERSE) end
	-- 选择我方场上1只可解放的电子界族怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,c,RACE_CYBERSE)
	e:SetLabel(g:GetFirst():GetType())
	-- 解放选定的怪兽
	Duel.Release(g,REASON_COST)
end
-- 检索满足5星以上且属于「@火灵天星」怪兽条件的过滤器函数
function c41306080.thfilter1(c)
	return c:IsLevelAbove(5) and c:IsSetCard(0x135) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②号效果的发动靶指向（Target）函数，检查卡组是否有满足条件的怪兽可以加入手卡，并检查自身等级，设置连锁操作信息
function c41306080.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查卡组中是否存在符合条件的5星以上的「@火灵天星」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c41306080.thfilter1,tp,LOCATION_DECK,0,1,nil)
		and not c:IsLevel(4) and c:IsLevelAbove(1) end
	-- 设置当前连锁的操作信息，将卡组的1只怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索「“艾”之仪式」（卡号85327820）卡片的过滤器函数
function c41306080.thfilter2(c)
	return c:IsCode(85327820) and c:IsAbleToHand()
end
-- ②号效果的执行逻辑（Operation）函数，检索5星以上「@火灵天星」怪兽加入手卡，使自己等级变为4星，且若解放了连接怪兽，可选择再检索「“艾”之仪式」
function c41306080.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示信息：“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只符合条件的「@火灵天星」怪兽
	local g1=Duel.SelectMatchingCard(tp,c41306080.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选定的怪兽加入我方手牌
	if g1:GetCount()>0 and Duel.SendtoHand(g1,nil,REASON_EFFECT)~=0 and g1:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g1)
		local c=e:GetHandler()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 这张卡的等级直到回合结束时变成4星。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(4)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
			-- 从卡组中检索满足条件的「“艾”之仪式」卡片
			local g2=Duel.GetMatchingGroup(c41306080.thfilter2,tp,LOCATION_DECK,0,nil)
			-- 判断解放的卡是否为连接怪兽，卡组中是否有「“艾”之仪式」，且让我方玩家选择是否检索
			if bit.band(e:GetLabel(),TYPE_LINK)~=0 and g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(41306080,2)) then  --"是否把「“艾”之仪式」加入手卡？"
				-- 中断当前效果，使得检索「“艾”之仪式」与前文检索怪兽的步骤被判定为不同时处理
				Duel.BreakEffect()
				-- 向玩家提示信息：“请选择要加入手牌的卡”
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local sg=g2:Select(tp,1,1,nil)
				-- 将选择的「“艾”之仪式」卡片加入我方手牌
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 向对方展示加入手牌的仪式魔法卡
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
end

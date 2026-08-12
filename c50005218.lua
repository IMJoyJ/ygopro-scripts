--閃刀空域－エリアゼロ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以这张卡以外的自己场上1张卡为对象才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1张「闪刀」卡加入手卡。剩下的卡回到卡组。「闪刀」卡被翻开的场合，再把作为对象的卡送去墓地。
-- ②：这张卡被效果从场地区域送去墓地的场合才能发动。从卡组把1只「闪刀姬」怪兽特殊召唤。
function c50005218.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以这张卡以外的自己场上1张卡为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50005218,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,50005218)
	e2:SetTarget(c50005218.thtg)
	e2:SetOperation(c50005218.thop)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果从场地区域送去墓地的场合才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50005218,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,50005219)
	e3:SetCondition(c50005218.spcon)
	e3:SetTarget(c50005218.sptg)
	e3:SetOperation(c50005218.spop)
	c:RegisterEffect(e3)
end
-- 检查是否满足效果发动条件：场上存在1张非此卡的己方场地卡，且己方卡组数量不少于3张。
function c50005218.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c end
	-- 检查是否满足效果发动条件：场上存在1张非此卡的己方场地卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,c)
		-- 检查是否满足效果发动条件：己方卡组数量不少于3张。
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张己方场上的卡作为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 设置效果处理信息：将1张卡从卡组加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
	-- 设置效果处理信息：将目标卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 定义过滤函数：筛选「闪刀」卡且能加入手牌的卡片。
function c50005218.thfilter(c)
	return c:IsSetCard(0x115) and c:IsAbleToHand()
end
-- 执行①效果的主要处理流程：翻开卡组最上方3张卡，若存在「闪刀」卡则可选择1张加入手牌，并将对象卡送去墓地。
function c50005218.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 翻开玩家卡组最上方3张卡。
	Duel.ConfirmDecktop(tp,3)
	-- 获取翻开的3张卡组成的Group。
	local g=Duel.GetDecktopGroup(tp,3)
	if g:GetCount()>0 then
		if g:IsExists(Card.IsSetCard,1,nil,0x115) then
			-- 判断翻开的卡中是否存在「闪刀」卡，若存在则询问是否选择加入手牌。
			if g:IsExists(c50005218.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(50005218,2)) then  --"是否选卡加入手卡？"
				-- 提示玩家选择要加入手牌的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local sg=g:FilterSelect(tp,c50005218.thfilter,1,1,nil)
				-- 将选中的卡以效果原因送入手牌。
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 向对方确认玩家选中的卡。
				Duel.ConfirmCards(1-tp,sg)
				-- 洗切玩家的手牌。
				Duel.ShuffleHand(tp)
			end
			if tc:IsRelateToEffect(e) then
				-- 将对象卡以效果原因送去墓地。
				Duel.SendtoGrave(tc,REASON_EFFECT)
			end
		end
		-- 洗切玩家的卡组。
		Duel.ShuffleDeck(tp)
	end
end
-- 判断此卡是否因效果被送入墓地且之前在场地区域。
function c50005218.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_FZONE)
end
-- 定义过滤函数：筛选「闪刀姬」怪兽且能特殊召唤的卡片。
function c50005218.spfilter(c,e,tp)
	return c:IsSetCard(0x1115) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否满足②效果发动条件：己方场上存在空位，且卡组中存在1只「闪刀姬」怪兽。
function c50005218.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足②效果发动条件：己方场上存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足②效果发动条件：卡组中存在1只「闪刀姬」怪兽。
		and Duel.IsExistingMatchingCard(c50005218.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：将1只「闪刀姬」怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行②效果的主要处理流程：从卡组选择1只「闪刀姬」怪兽特殊召唤。
function c50005218.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只「闪刀姬」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c50005218.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果原因特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

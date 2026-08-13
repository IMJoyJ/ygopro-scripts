--P.U.N.K.JAMドラゴン・ドライブ
-- 效果：
-- 念动力族调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤或者用「朋克」卡的效果特殊召唤的场合，支付600基本分才能发动。从卡组选1只念动力族·3星怪兽加入手卡或送去墓地。
-- ②：这张卡在墓地存在的状态，对方连锁自己的「朋克」卡的效果的发动把卡的效果发动的场合才能发动。这张卡特殊召唤。
function c28403802.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整必须为念动力族怪兽，调整以外的怪兽任意数量（1只以上），对应其同调召唤素材要求。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PSYCHO),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡同调召唤或者用「朋克」卡的效果特殊召唤的场合，支付600基本分才能发动。从卡组选1只念动力族·3星怪兽加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,28403802)
	e1:SetCondition(c28403802.thcon)
	e1:SetCost(c28403802.thcost)
	e1:SetTarget(c28403802.thtg)
	e1:SetOperation(c28403802.thop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡在墓地存在的状态，对方连锁自己的「朋克」卡的效果的发动把卡的效果发动的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,28403803)
	e2:SetCondition(c28403802.spcon)
	e2:SetTarget(c28403802.sptg)
	e2:SetOperation(c28403802.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：这张卡以同调召唤方式特殊召唤成功，或者通过「朋克」卡的效果特殊召唤成功时，且满足场合型触发（延迟）条件。
function c28403802.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) or c:IsSpecialSummonSetCard(0x171)
end
-- ①效果的发动代价处理：效果发动时需支付600基本分；先检查是否能支付，再在实际发动时扣除。
function c28403802.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件检查：确认自己当前基本分足够支付600点，否则无法发动该效果。
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 实际支付600基本分作为发动①效果的代价。
	Duel.PayLPCost(tp,600)
end
-- 定义①效果可选择卡牌的条件：必须是念动力族·3星怪兽，并且能够加入手卡或能够送去墓地（至少满足一种）。
function c28403802.thfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsLevel(3) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ①效果发动时的目标设定（不取对象）：仅在发动时确认卡组中存在符合条件的怪兽，不预先选定具体卡；具体选择在效果处理时进行。
function c28403802.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足筛选条件的念动力族·3星怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28403802.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果处理：从卡组选择1只符合条件的念动力族·3星怪兽，并由玩家决定加入手卡或送去墓地。
function c28403802.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，引导玩家从卡组中选取要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组中选出1张符合条件的念动力族·3星怪兽。
	local g=Duel.SelectMatchingCard(tp,c28403802.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 分支判断：若该卡不能送去墓地，或玩家选择“加入手卡”（选项0），则加入手卡；否则送去墓地。
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将选中的卡加入其持有者的手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示这张加入手卡的卡。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的卡送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：当前连锁数≥2，且当前连锁的前一环是自己的「朋克」卡效果发动，同时本连锁由对方玩家发动卡的效果响应。
function c28403802.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁序号，用于判断是否发生对方连锁自己的「朋克」卡效果的情况。
	local ct=Duel.GetCurrentChain()
	if ct<2 then return end
	-- 获取前一个连锁的效果和发动玩家，以确认上一个连锁是自己发动的「朋克」卡效果。
	local te,p=Duel.GetChainInfo(ct-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return te and te:GetHandler():IsSetCard(0x171) and p==tp and rp==1-tp
end
-- ②效果发动时的目标检查：自己场上怪兽区域有空位，且墓地中的这张卡可以被特殊召唤。
function c28403802.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区域是否有可用的空格，确保特殊召唤有位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁操作信息设为特殊召唤这张卡，供后续效果处理和相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：将处于墓地的这张卡特殊召唤到自己场上。
function c28403802.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再确认：仍有可用怪兽区域，且这张卡仍与此效果关联（没有离场或失效），否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end

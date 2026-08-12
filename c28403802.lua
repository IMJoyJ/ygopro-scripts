--P.U.N.K.JAMドラゴン・ドライブ
-- 效果：
-- 念动力族调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤或者用「朋克」卡的效果特殊召唤的场合，支付600基本分才能发动。从卡组选1只念动力族·3星怪兽加入手卡或送去墓地。
-- ②：这张卡在墓地存在的状态，对方连锁自己的「朋克」卡的效果的发动把卡的效果发动的场合才能发动。这张卡特殊召唤。
function c28403802.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只念动力族调整和1只以上调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PSYCHO),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤或者用「朋克」卡的效果特殊召唤的场合，支付600基本分才能发动。从卡组选1只念动力族·3星怪兽加入手卡或送去墓地。
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
	-- ②：这张卡在墓地存在的状态，对方连锁自己的「朋克」卡的效果的发动把卡的效果发动的场合才能发动。这张卡特殊召唤。
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
-- 效果①的发动条件：这张卡是同调召唤或用「朋克」卡的效果特殊召唤成功
function c28403802.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) or c:IsSpecialSummonSetCard(0x171)
end
-- 效果①的发动费用：支付600基本分
function c28403802.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付600基本分
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 让玩家支付600基本分
	Duel.PayLPCost(tp,600)
end
-- 检索满足条件的念动力族3星怪兽（可加入手卡或送去墓地）
function c28403802.thfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsLevel(3) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 效果①的目标设定：检查卡组是否存在满足条件的念动力族3星怪兽
function c28403802.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家来看的卡组中是否存在至少1张满足条件的念动力族3星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28403802.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果①的处理：选择一张念动力族3星怪兽加入手卡或送去墓地
function c28403802.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择满足条件的念动力族3星怪兽
	local g=Duel.SelectMatchingCard(tp,c28403802.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 判断选择的怪兽是否可以加入手卡，若可以则由玩家选择加入手卡或送去墓地
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将选择的怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选择的怪兽送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- 效果②的发动条件：对方连锁自己的「朋克」卡的效果发动时
function c28403802.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁序号
	local ct=Duel.GetCurrentChain()
	if ct<2 then return end
	-- 获取上一个连锁的效果和发动玩家
	local te,p=Duel.GetChainInfo(ct-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return te and te:GetHandler():IsSetCard(0x171) and p==tp and rp==1-tp
end
-- 效果②的目标设定：检查是否可以特殊召唤此卡
function c28403802.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果②的处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的处理：将此卡特殊召唤到场上
function c28403802.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足特殊召唤条件（场上是否有空位且此卡与效果相关）
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not e:GetHandler():IsRelateToEffect(e) then return end
	-- 将此卡以正面表示特殊召唤到场上
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end

--ティアラメンツ・キトカロス
-- 效果：
-- 「珠泪哀歌族」怪兽＋水族怪兽
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从卡组选1张「珠泪哀歌族」卡加入手卡或送去墓地。
-- ②：以自己场上1只怪兽为对象才能发动。从自己的手卡·墓地选1只「珠泪哀歌族」怪兽特殊召唤，作为对象的怪兽送去墓地。
-- ③：这张卡被效果送去墓地的场合才能发动。从自己卡组上面把5张卡送去墓地。
function c92731385.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合召唤手续：需要「珠泪哀歌族」怪兽和水族怪兽各1只作为素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x181),aux.FilterBoolFunction(Card.IsRace,RACE_AQUA),true)
	-- ①：这张卡特殊召唤成功的场合才能发动。从卡组选1张「珠泪哀歌族」卡加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92731385,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,92731385)
	e1:SetTarget(c92731385.target)
	e1:SetOperation(c92731385.operation)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只怪兽为对象才能发动。从自己的手卡·墓地选1只「珠泪哀歌族」怪兽特殊召唤，作为对象的怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92731385,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,92731386)
	e2:SetTarget(c92731385.tgtg)
	e2:SetOperation(c92731385.tgop)
	c:RegisterEffect(e2)
	-- ③：这张卡被效果送去墓地的场合才能发动。从自己卡组上面把5张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92731385,2))
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,92731387)
	e3:SetCondition(c92731385.discon)
	e3:SetTarget(c92731385.distg)
	e3:SetOperation(c92731385.disop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中可以加入手卡或送去墓地的「珠泪哀歌族」卡
function c92731385.cfilter(c)
	return c:IsSetCard(0x181) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ①号效果的发动准备与合法性检测函数
function c92731385.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「珠泪哀歌族」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c92731385.cfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①号效果的执行函数：从卡组选择1张「珠泪哀歌族」卡，并让玩家选择加入手卡或送去墓地
function c92731385.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组中选择1张满足条件的「珠泪哀歌族」卡
	local g=Duel.SelectMatchingCard(tp,c92731385.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 判断所选卡片是否能加入手卡，并让玩家在“加入手卡”和“送去墓地”之间进行选择
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将选择的卡片加入玩家手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡片
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选择的卡片送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- 过滤手卡或墓地中可以特殊召唤的「珠泪哀歌族」怪兽
function c92731385.spfilter(c,e,tp)
	return c:IsSetCard(0x181) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ②号效果的发动准备与对象选择函数
function c92731385.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsAbleToGrave() end
	-- 检查自己场上是否存在可以送去墓地的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查自己的手卡或墓地中是否存在可以特殊召唤的「珠泪哀歌族」怪兽
		and Duel.IsExistingMatchingCard(c92731385.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 并且检查自己场上是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp)>0 end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1只可以送去墓地的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息：此效果包含将选中的对象怪兽送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置连锁信息：此效果包含从手卡或墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②号效果的执行函数：特殊召唤手卡或墓地的「珠泪哀歌族」怪兽，并将作为对象的怪兽送去墓地
function c92731385.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则无法特殊召唤，直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的「珠泪哀歌族」怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c92731385.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 如果成功特殊召唤了选中的怪兽，且作为对象的怪兽仍在该效果的影响范围内
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- ③号效果的发动条件函数：检查这张卡是否是被效果送去墓地
function c92731385.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- ③号效果的发动准备与参数设定函数
function c92731385.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能将卡组最上方的5张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) end
	-- 设置效果的目标玩家为当前发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为5张卡
	Duel.SetTargetParam(5)
	-- 设置连锁信息：此效果包含将玩家卡组上方的5张卡送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,5)
end
-- ③号效果的执行函数：将自己卡组最上方的5张卡送去墓地
function c92731385.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时设定的目标玩家和需要送去墓地的卡片数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 将目标玩家卡组最上方的指定数量卡片送去墓地
	Duel.DiscardDeck(p,d,REASON_EFFECT)
end

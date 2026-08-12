--オルターガイスト・プライムバンシー
-- 效果：
-- 「幻变骚灵」怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把这张卡以外的自己场上1只「幻变骚灵」怪兽解放才能发动。从卡组把1只「幻变骚灵」怪兽在作为这张卡所连接区的自己场上特殊召唤。
-- ②：这张卡从场上送去墓地的场合，以自己墓地1张「幻变骚灵」卡为对象才能发动。那张卡加入手卡。
function c93503294.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续，需要「幻变骚灵」怪兽2只以上。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x103),2)
	-- ①：自己·对方的主要阶段，把这张卡以外的自己场上1只「幻变骚灵」怪兽解放才能发动。从卡组把1只「幻变骚灵」怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93503294,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,93503294)
	e1:SetCondition(c93503294.spcon)
	e1:SetCost(c93503294.spcost)
	e1:SetTarget(c93503294.sptg)
	e1:SetOperation(c93503294.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合，以自己墓地1张「幻变骚灵」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93503294,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,93503295)
	e2:SetCondition(c93503294.thcon)
	e2:SetTarget(c93503294.thtg)
	e2:SetOperation(c93503294.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件函数：必须在自己或对方的主要阶段。
function c93503294.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果①解放怪兽的过滤条件：属于「幻变骚灵」系列，且解放该卡后能腾出可用的怪兽区域。
function c93503294.spcfilter(c,tp,zone)
	-- 检查卡片是否为「幻变骚灵」怪兽，且解放该卡后在连接区是否有可用的怪兽区域。
	return c:IsSetCard(0x103) and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 效果①的发动代价函数：解放这张卡以外的自己场上1只「幻变骚灵」怪兽。
function c93503294.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	-- 步骤0：检查自己场上是否存在至少1只满足过滤条件的可解放怪兽（排除自身）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c93503294.spcfilter,1,c,tp,zone) end
	-- 玩家选择1只满足过滤条件的可解放怪兽。
	local g=Duel.SelectReleaseGroup(tp,c93503294.spcfilter,1,1,c,tp,zone)
	-- 解放选择的怪兽作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 效果①特殊召唤的过滤条件：卡组中的「幻变骚灵」怪兽且可以被特殊召唤。
function c93503294.spfilter(c,e,tp)
	return c:IsSetCard(0x103) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与效果分类设置函数。
function c93503294.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤0：检查卡组中是否存在至少1只满足特殊召唤条件的「幻变骚灵」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c93503294.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理函数：从卡组把1只「幻变骚灵」怪兽在作为这张卡所连接区的自己场上特殊召唤。
function c93503294.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 检查连接区是否有可用的怪兽区域，若无则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只满足条件的「幻变骚灵」怪兽。
	local g=Duel.SelectMatchingCard(tp,c93503294.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到这张卡的连接区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 效果②的发动条件函数：这张卡必须是从场上送去墓地。
function c93503294.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果②加入手牌的过滤条件：墓地中的「幻变骚灵」卡片且可以加入手牌。
function c93503294.thfilter(c)
	return c:IsSetCard(0x103) and c:IsAbleToHand()
end
-- 效果②的发动准备与对象选择函数。
function c93503294.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c93503294.thfilter(chkc) end
	-- 步骤0：检查自己墓地是否存在至少1张满足条件的「幻变骚灵」卡。
	if chk==0 then return Duel.IsExistingTarget(c93503294.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择墓地中1张满足条件的「幻变骚灵」卡作为效果对象。
	local sg=Duel.SelectTarget(tp,c93503294.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表示该效果包含将选择的对象卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- 效果②的效果处理函数：将选择的墓地中的「幻变骚灵」卡加入手牌。
function c93503294.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍适应于此效果，且不受「王家长眠之谷」的影响。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象卡加入持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

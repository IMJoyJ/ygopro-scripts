--Uk－P.U.N.K.アメイジング・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡同调召唤的场合，以最多有自己的场上·墓地的念动力族·3星怪兽种类数量的对方场上的卡为对象才能发动。那些卡回到手卡。
-- ②：以「浮世绘朋克 惊龙」以外的自己墓地1只「朋克」怪兽为对象才能发动。那只怪兽特殊召唤。
function c44708154.initial_effect(c)
	-- 添加同调召唤手续，要求必须是1只调整，且调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，以最多有自己的场上·墓地的念动力族·3星怪兽种类数量的对方场上的卡为对象才能发动。那些卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44708154,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,44708154)
	e1:SetCondition(c44708154.thcon)
	e1:SetTarget(c44708154.thtg)
	e1:SetOperation(c44708154.thop)
	c:RegisterEffect(e1)
	-- ②：以「浮世绘朋克 惊龙」以外的自己墓地1只「朋克」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44708154,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,44708154)
	e2:SetTarget(c44708154.sptg)
	e2:SetOperation(c44708154.spop)
	c:RegisterEffect(e2)
end
-- 效果发动的条件：此卡必须是同调召唤成功
function c44708154.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的念动力族3星怪兽（场上或墓地均可）
function c44708154.thfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsRace(RACE_PSYCHO) and c:IsLevel(3)
end
-- 设置效果的发动条件：检查自己场上或墓地是否存在满足条件的念动力族3星怪兽，以及对方场上是否存在可以送回手牌的卡
function c44708154.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查自己场上或墓地是否存在满足条件的念动力族3星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44708154.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
		-- 检查对方场上是否存在可以送回手牌的卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取满足条件的念动力族3星怪兽组，用于计算种类数量
	local g=Duel.GetMatchingGroup(c44708154.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 提示玩家选择要送回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上的卡作为效果对象，数量为满足条件的念动力族3星怪兽数量
	local sg=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置效果处理信息，指定将选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果处理函数：获取连锁中选中的卡，并将它们送回手牌
function c44708154.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选中的卡，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将符合条件的卡送回手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤满足条件的「朋克」怪兽（非本卡），且可以特殊召唤
function c44708154.spfilter(c,e,tp)
	return not c:IsCode(44708154) and c:IsSetCard(0x171) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的发动条件：检查自己墓地是否存在满足条件的「朋克」怪兽，以及是否有足够的召唤区域
function c44708154.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44708154.spfilter(chkc,e,tp) end
	-- 检查自己是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的「朋克」怪兽
		and Duel.IsExistingTarget(c44708154.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地满足条件的「朋克」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c44708154.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，指定将选中的卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：获取连锁中选中的卡，并将其特殊召唤
function c44708154.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选中的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

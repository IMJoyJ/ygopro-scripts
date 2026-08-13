--Uk－P.U.N.K.アメイジング・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡同调召唤的场合，以最多有自己的场上·墓地的念动力族·3星怪兽种类数量的对方场上的卡为对象才能发动。那些卡回到手卡。
-- ②：以「浮世绘朋克 惊龙」以外的自己墓地1只「朋克」怪兽为对象才能发动。那只怪兽特殊召唤。
function c44708154.initial_effect(c)
	-- 为这张卡添加同调召唤手续（对应效果原文：调整＋调整以外的怪兽1只以上）：需要1只调整＋调整以外的怪兽1只以上作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡同调召唤的场合，以最多有自己的场上·墓地的念动力族·3星怪兽种类数量的对方场上的卡为对象才能发动。那些卡回到手卡。
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
-- 效果①的发动条件判断：这张卡是否以同调召唤方式特殊召唤成功。
function c44708154.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①计数用过滤函数：选出自己场上表侧表示或墓地中的念动力族·3星怪兽。
function c44708154.thfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsRace(RACE_PSYCHO) and c:IsLevel(3)
end
-- 效果①的取对象处理：先检查被指认的对象是否为在场且对方可控且可回手卡的卡；再验证是否存在计数用的怪兽以及对方场上是否存在可回手的对象。
function c44708154.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 发动合法性检查：确认自己场上·墓地存在至少1只可用于计算弹卡数量的表侧表示或墓地的念动力族·3星怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c44708154.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
		-- 发动合法性检查：确认对方场上存在至少1张能被选择为对象并返回手卡的卡。
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 取得自己场上（表侧）与墓地的全部念动力族·3星怪兽，用于计算种类数。
	local g=Duel.GetMatchingGroup(c44708154.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 向玩家显示选择返回手牌对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从对方场上选择1～ct张（ct为符合条件的念动力族·3星怪兽种类数）能回手卡的卡作为效果对象。
	local sg=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置本次连锁的操作信息：将刚选择的对象卡作为“返回手卡”的目标。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果①处理：把仍与效果相关且被选择的对象卡返回持有者手卡。
function c44708154.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取出登记的对象卡，并过滤掉已与效果失去联系的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将过滤后的对象卡以“效果”原因返回其持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 效果②的对象过滤：墓地中除「浮世绘朋克 惊龙」以外的「朋克」怪兽，且能够被特殊召唤。
function c44708154.spfilter(c,e,tp)
	return not c:IsCode(44708154) and c:IsSetCard(0x171) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动条件与对象合法性检查：确认我方主怪兽区有空位且墓地存在可特殊召唤的“朋克”怪兽；若指定对象则需在墓地且由我方控制并符合特殊召唤条件。
function c44708154.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44708154.spfilter(chkc,e,tp) end
	-- 发动合法性检查：我方主要怪兽区有空余格子可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查：墓地中存在至少1只符合条件的“朋克”怪兽可被选择为对象。
		and Duel.IsExistingTarget(c44708154.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择特殊召唤对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的“朋克”怪兽作为特殊召唤对象。
	local g=Duel.SelectTarget(tp,c44708154.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息：将选择的对象卡作为“特殊召唤”目标。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②处理：将对象怪兽从墓地以表侧表示特殊召唤到自己场上。
function c44708154.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象怪兽（即被选择的那张墓地“朋克”怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 检查对象仍与效果相关后，将其以表侧表示特殊召唤到自己场上（不改变召唤类型，需满足召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

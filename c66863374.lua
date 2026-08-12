--スレイブパンサー
-- 效果：
-- 包含「剑斗兽」怪兽的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「剑斗兽」卡加入手卡。
-- ②：以自己场上1只「剑斗兽」怪兽为对象才能发动。那只「剑斗兽」怪兽回到持有者卡组，原本卡名和那只怪兽不同的1只「剑斗兽」怪兽当作「剑斗兽」怪兽的效果的特殊召唤从卡组特殊召唤。
function c66863374.initial_effect(c)
	-- 设置连接召唤的手续，需要2只怪兽作为素材，且必须满足lcheck过滤条件（包含「剑斗兽」怪兽）
	aux.AddLinkProcedure(c,nil,2,2,c66863374.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「剑斗兽」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66863374,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,66863374)
	e1:SetCondition(c66863374.thcon)
	e1:SetTarget(c66863374.thtg)
	e1:SetOperation(c66863374.thop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只「剑斗兽」怪兽为对象才能发动。那只「剑斗兽」怪兽回到持有者卡组，原本卡名和那只怪兽不同的1只「剑斗兽」怪兽当作「剑斗兽」怪兽的效果的特殊召唤从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66863374,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,66863375)
	e2:SetTarget(c66863374.sptg)
	e2:SetOperation(c66863374.spop)
	c:RegisterEffect(e2)
end
-- 连接召唤素材的过滤条件：用于检测素材组中是否包含至少1只「剑斗兽」怪兽
function c66863374.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1019)
end
-- 效果①的发动条件：这张卡是通过连接召唤特殊召唤成功的
function c66863374.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的检索过滤条件：卡组中属于「剑斗兽」系列且能加入手牌的卡
function c66863374.thfilter(c)
	return c:IsSetCard(0x1019) and c:IsAbleToHand()
end
-- 效果①的发动准备（Target）：检查卡组中是否存在可检索的「剑斗兽」卡，并设置检索的操作信息
function c66863374.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「剑斗兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c66863374.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）：从卡组选择1张「剑斗兽」卡加入手牌并给对方确认
function c66863374.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「剑斗兽」卡
	local g=Duel.SelectMatchingCard(tp,c66863374.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的对象过滤条件：自己场上表侧表示的「剑斗兽」怪兽，且该怪兽离场后有可用的怪兽区域，并且卡组中存在原本卡名不同且可特殊召唤的「剑斗兽」怪兽
function c66863374.tdfilter(c,e,tp)
	-- 过滤条件：卡片必须是自己场上表侧表示的「剑斗兽」怪兽，且该怪兽回到卡组后必须有可用的怪兽区域
	return c:IsFaceup() and c:IsSetCard(0x1019) and Duel.GetMZoneCount(tp,c)>0
		-- 过滤条件：卡组中必须存在至少1只满足特殊召唤条件的「剑斗兽」怪兽（且原本卡名与该对象不同）
		and Duel.IsExistingMatchingCard(c66863374.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 效果②的特殊召唤过滤条件：卡组中属于「剑斗兽」系列、原本卡名与对象不同、且可以当作「剑斗兽」怪兽效果特殊召唤的怪兽
function c66863374.spfilter(c,e,tp,tc)
	return c:IsSetCard(0x1019) and not c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
		and c:IsCanBeSpecialSummoned(e,SUMMON_VALUE_GLADIATOR,tp,false,false)
end
-- 效果②的发动准备（Target）：选择自己场上1只「剑斗兽」怪兽为对象，并设置回到卡组和特殊召唤的操作信息
function c66863374.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c66863374.tdfilter(chkc,e,tp) end
	-- 检查自己场上是否存在满足回到卡组及后续特召条件的对象怪兽
	if chk==0 then return Duel.IsExistingTarget(c66863374.tdfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1只满足条件的「剑斗兽」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66863374.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：将选中的对象怪兽回到持有者卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理（Operation）：使对象怪兽回到卡组，若成功，则从卡组将1只原本卡名不同的「剑斗兽」怪兽当作「剑斗兽」怪兽的效果特殊召唤
function c66863374.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适应此效果，并将其送回持有者卡组并洗牌，确认是否成功回到卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		-- 检查当前玩家场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组中选择1只原本卡名与对象不同且满足特召条件的「剑斗兽」怪兽
		local g=Duel.SelectMatchingCard(tp,c66863374.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc)
		local tc=g:GetFirst()
		if tc then
			-- 将选择的怪兽以表侧表示特殊召唤，并赋予其「当作剑斗兽怪兽的效果特殊召唤」的召唤数值标记
			Duel.SpecialSummon(tc,SUMMON_VALUE_GLADIATOR,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
		end
	end
end

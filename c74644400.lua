--サイキック・リフレクター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。除「念动力反射者」外的1张「爆裂模式」或者有那个卡名记述的卡从卡组加入手卡。
-- ②：把手卡1张「爆裂模式」给对方观看，以「念动力反射者」以外的有「爆裂模式」的卡名记述的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤，那个等级上升最多4星。
function c74644400.initial_effect(c)
	-- 注册该卡记述了「爆裂模式」的卡片密码，以便其他卡片进行相关检测。
	aux.AddCodeList(c,80280737)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。除「念动力反射者」外的1张「爆裂模式」或者有那个卡名记述的卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74644400,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,74644400)
	e1:SetTarget(c74644400.thtg)
	e1:SetOperation(c74644400.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把手卡1张「爆裂模式」给对方观看，以「念动力反射者」以外的有「爆裂模式」的卡名记述的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤，那个等级上升最多4星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74644400,1))  --"墓地苏生"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,74644401)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c74644400.spcost)
	e3:SetTarget(c74644400.sptg)
	e3:SetOperation(c74644400.spop)
	c:RegisterEffect(e3)
end
-- 定义检索过滤条件：卡名是「爆裂模式」或记述了「爆裂模式」卡名、且不是「念动力反射者」的可以加入手牌的卡。
function c74644400.thfilter(c)
	-- 判断卡片是否满足：卡名是「爆裂模式」或记述了「爆裂模式」卡名、且不是「念动力反射者」且可以加入手牌。
	return aux.IsCodeOrListed(c,80280737) and not c:IsCode(74644400) and c:IsAbleToHand()
end
-- ①号效果的发动准备，检查卡组中是否存在符合条件的卡，并设置操作信息。
function c74644400.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组中是否存在至少1张满足检索过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c74644400.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果包含从卡组将1张卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的执行，从卡组选择符合条件的卡加入手牌并给对方确认。
function c74644400.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从己方卡组选择1张满足检索过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,c74644400.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义展示过滤条件：手牌中未公开的「爆裂模式」。
function c74644400.cfilter(c)
	return c:IsCode(80280737) and not c:IsPublic()
end
-- ②号效果的发动代价，展示手牌中的1张「爆裂模式」。
function c74644400.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在未公开的「爆裂模式」以作为发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c74644400.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手牌选择1张未公开的「爆裂模式」。
	local g=Duel.SelectMatchingCard(tp,c74644400.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 重新洗切己方手牌。
	Duel.ShuffleHand(tp)
end
-- 定义特殊召唤过滤条件：记述了「爆裂模式」卡名、且不是「念动力反射者」的、有等级且可以特殊召唤的怪兽。
function c74644400.spfilter(c,e,tp)
	-- 判断卡片是否满足：记述了「爆裂模式」卡名、且不是「念动力反射者」且等级在1星以上。
	return aux.IsCodeListed(c,80280737) and not c:IsCode(74644400) and c:IsLevelAbove(1)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②号效果的发动准备，检查怪兽区域空位和墓地中符合条件的怪兽，并选择对象。
function c74644400.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c74644400.spfilter(chkc,e,tp) end
	-- 检查己方场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方墓地中是否存在可以作为效果对象的符合特殊召唤条件的怪兽。
		and Duel.IsExistingTarget(c74644400.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择己方墓地中1只符合特殊召唤条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c74644400.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示该效果包含特殊召唤选中的对象怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②号效果的执行，特殊召唤对象怪兽，并让玩家选择上升1到4个等级。
function c74644400.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合效果条件，则将其以表侧表示特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 提示玩家选择要上升的等级。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(74644400,2))  --"请选择要上升的等级"
		-- 让玩家宣言一个1至4之间的数字作为上升的等级。
		local lv=Duel.AnnounceNumber(tp,1,2,3,4)
		-- 那个等级上升最多4星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(lv)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理。
	Duel.SpecialSummonComplete()
end

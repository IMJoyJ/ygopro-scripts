--剣闘獣エクイテ
-- 效果：
-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，从自己墓地选择1张名字带有「剑斗兽」的卡加入手卡。这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 骑斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
function c57731460.initial_effect(c)
	-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，从自己墓地选择1张名字带有「剑斗兽」的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57731460,0))  --"墓地回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置效果发动条件为：这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时
	e1:SetCondition(aux.gbspcon)
	e1:SetTarget(c57731460.rettg)
	e1:SetOperation(c57731460.retop)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组，从卡组把「剑斗兽 骑斗」以外的1只名字带有「剑斗兽」的怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57731460,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c57731460.spcon)
	e2:SetCost(c57731460.spcost)
	e2:SetTarget(c57731460.sptg)
	e2:SetOperation(c57731460.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地中可以加入手牌的「剑斗兽」卡片
function c57731460.retfilter(c)
	return c:IsSetCard(0x1019) and c:IsAbleToHand()
end
-- 墓地回收效果的目标选择与合法性检查
function c57731460.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c57731460.retfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张满足条件的「剑斗兽」卡片作为效果对象
	local g=Duel.SelectTarget(tp,c57731460.retfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为：将选中的卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 墓地回收效果的处理，将选中的对象卡片加入手牌
function c57731460.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在效果发动时选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 检查此卡在本次战斗阶段中是否进行过战斗，作为特殊召唤效果的发动条件
function c57731460.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 特殊召唤效果的代价处理：将自身回到持有者卡组
function c57731460.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 作为发动代价，将此卡送回卡组并洗牌
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤条件：卡组中除「剑斗兽 骑斗」以外、可以特殊召唤的「剑斗兽」怪兽
function c57731460.filter(c,e,tp)
	return not c:IsCode(57731460) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标选择与合法性检查
function c57731460.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用空格（因为自身作为代价回卡组，所以可用空格数需大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并且检查卡组中是否存在至少1只满足过滤条件的「剑斗兽」怪兽
		and Duel.IsExistingMatchingCard(c57731460.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的处理，从卡组选择1只「剑斗兽」怪兽特殊召唤到场上
function c57731460.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有可用空格，若无则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c57731460.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end

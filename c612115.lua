--剣闘獣レティアリィ
-- 效果：
-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，可以选择对方墓地1张卡除外。这张卡进行战斗的战斗阶段结束时可以通过让这张卡回到卡组，从卡组把「剑斗兽 网斗」以外的1只名字带有「剑斗兽」的怪兽特殊召唤。
function c612115.initial_effect(c)
	-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功时，可以选择对方墓地1张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(612115,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置效果发动条件为：这张卡用「剑斗兽」怪兽的效果特殊召唤成功
	e1:SetCondition(aux.gbspcon)
	e1:SetTarget(c612115.rmtg)
	e1:SetOperation(c612115.rmop)
	c:RegisterEffect(e1)
	-- 这张卡进行战斗的战斗阶段结束时可以通过让这张卡回到卡组，从卡组把「剑斗兽 网斗」以外的1只名字带有「剑斗兽」的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(612115,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c612115.spcon)
	e2:SetCost(c612115.spcost)
	e2:SetTarget(c612115.sptg)
	e2:SetOperation(c612115.spop)
	c:RegisterEffect(e2)
end
-- 除外效果的发动准备阶段（Target），判断并选择对方墓地的一张卡作为对象
function c612115.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 给玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息，表示该效果的操作分类为除外，目标是对方墓地的所选卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 除外效果的处理阶段（Operation），将选中的卡除外
function c612115.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 检查自身是否在本次战斗阶段进行过战斗，作为特殊召唤效果的发动条件
function c612115.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 特殊召唤效果的代价处理，将自身回到持有者卡组
function c612115.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 作为发动代价，将自身送回卡组并洗牌
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤卡组中「剑斗兽 网斗」以外的名字带有「剑斗兽」且可以特殊召唤的怪兽
function c612115.filter(c,e,tp)
	return not c:IsCode(612115) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备阶段（Target），检查怪兽区域空位以及卡组中是否存在可特召的怪兽
function c612115.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用空间（由于自身作为代价回到卡组，空位计算需考虑自身离场，故>-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在满足过滤条件的「剑斗兽」怪兽
		and Duel.IsExistingMatchingCard(c612115.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示该效果的操作分类为特殊召唤，目标为卡组中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的处理阶段（Operation），从卡组特殊召唤1只「剑斗兽」怪兽
function c612115.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前怪兽区域是否有空位，若无则无法特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足条件的「剑斗兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c612115.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end

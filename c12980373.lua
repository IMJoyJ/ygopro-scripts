--マドルチェ・ミィルフィーヤ
-- 效果：
-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。这张卡召唤成功时，可以从手卡把1只名字带有「魔偶甜点」的怪兽特殊召唤。
function c12980373.initial_effect(c)
	-- 效果原文内容：这张卡被对方破坏送去墓地时，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12980373,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c12980373.retcon)
	e1:SetTarget(c12980373.rettg)
	e1:SetOperation(c12980373.retop)
	c:RegisterEffect(e1)
	-- 效果原文内容：这张卡召唤成功时，可以从手卡把1只名字带有「魔偶甜点」的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12980373,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c12980373.sptg)
	e2:SetOperation(c12980373.spop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断该卡是否因对方破坏而送去墓地且之前在自己场上
function c12980373.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 规则层面作用：设置效果处理时的OperationInfo，用于提示将要将该卡送回卡组
function c12980373.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置将该卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 规则层面作用：定义该卡被破坏送入墓地时的处理逻辑
function c12980373.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 规则层面作用：将该卡以效果原因送回卡组并洗牌
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 规则层面作用：过滤手牌中名字带有「魔偶甜点」且可特殊召唤的怪兽
function c12980373.filter(c,e,tp)
	return c:IsSetCard(0x71) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置特殊召唤效果的目标选择逻辑
function c12980373.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c12980373.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面作用：设置特殊召唤操作信息，表示将要从手牌特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 规则层面作用：定义召唤成功时的特殊召唤处理逻辑
function c12980373.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查是否还有召唤区域，没有则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 规则层面作用：从手牌中选择一只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c12980373.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--マドルチェ・ミィルフィーヤ
-- 效果：
-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。这张卡召唤成功时，可以从手卡把1只名字带有「魔偶甜点」的怪兽特殊召唤。
function c12980373.initial_effect(c)
	-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12980373,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c12980373.retcon)
	e1:SetTarget(c12980373.rettg)
	e1:SetOperation(c12980373.retop)
	c:RegisterEffect(e1)
	-- 这张卡召唤成功时，可以从手卡把1只名字带有「魔偶甜点」的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12980373,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c12980373.sptg)
	e2:SetOperation(c12980373.spop)
	c:RegisterEffect(e2)
end
-- 判断这张卡是否因对方玩家的效果被破坏送去墓地，且被破坏前由自己控制。
function c12980373.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 回卡组效果的发动时点：只要满足条件即可发动，并准备将这张卡本身送回卡组的处理信息。
function c12980373.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记本次操作的信息：将这张卡（e:GetHandler()）送入卡组（CATEGORY_TODECK），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与本次效果关联（未被中途离场等情况重置联系），则将其送回持有者卡组。
function c12980373.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以效果为原因将这张卡送回持有者卡组，并置于卡组最底端后洗牌（SEQ_DECKSHUFFLE）。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤条件：选择手卡中卡名带有「魔偶甜点」字段，并且能够被通常特殊召唤的怪兽。
function c12980373.filter(c,e,tp)
	return c:IsSetCard(0x71) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动条件：己方怪兽区有空位，且手卡中存在符合条件的「魔偶甜点」怪兽。
function c12980373.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认己方主要怪兽区是否有空余区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认手卡中至少存在1只满足c12980373.filter条件的「魔偶甜点」怪兽。
		and Duel.IsExistingMatchingCard(c12980373.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向系统登记本次操作的信息：将进行从手卡特殊召唤（CATEGORY_SPECIAL_SUMMON）的处理，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：选择并特殊召唤1只手卡中符合条件的「魔偶甜点」怪兽到己方场上。
function c12980373.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查己方怪兽区是否有空位，若已无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示提示信息，要求其选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选出1只满足c12980373.filter条件的「魔偶甜点」怪兽作为对象。
	local g=Duel.SelectMatchingCard(tp,c12980373.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上（不限制召唤方式、不解除苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

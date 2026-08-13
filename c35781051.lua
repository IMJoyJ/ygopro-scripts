--アルカナフォースⅢ－THE EMPRESS
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，进行1次投掷硬币得到以下效果。
-- ●表：每次对方对怪兽的通常召唤成功可以从手卡把1只名字带有「秘仪之力」的怪兽在自己场上特殊召唤。
-- ●里：每次对方对怪兽的通常召唤成功自己把手卡1张卡送去墓地。
function c35781051.initial_effect(c)
	-- 为这张卡注册秘仪之力通用的抛硬币触发流程：在召唤成功、反转召唤成功、特殊召唤成功时强制进行1次投掷硬币，并根据正反面将FLAG_ID_ARCANA_COIN标签设为1（表）或0（里），以决定后续表里效果。
	aux.EnableArcanaCoin(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS)
	-- ●表：每次对方对怪兽的通常召唤成功可以从手卡把1只名字带有「秘仪之力」的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35781051,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c35781051.spcon)
	e1:SetTarget(c35781051.sptg)
	e1:SetOperation(c35781051.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_MSET)
	c:RegisterEffect(e2)
	-- ●里：每次对方对怪兽的通常召唤成功自己把手卡1张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35781051,2))  --"手牌送墓"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c35781051.tgcon)
	e3:SetTarget(c35781051.tgtg)
	e3:SetOperation(c35781051.tgop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_MSET)
	c:RegisterEffect(e4)
end
-- 这是表效果的发动条件：仅在对方玩家通常召唤怪兽成功（ep~=tp），且这张卡此前抛硬币结果为表（FLAG_ID_ARCANA_COIN标签值为1）时，表效果才满足发动条件。
function c35781051.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1
end
-- 手卡特召对象的过滤器：需要是名字带有「秘仪之力」的怪兽，并且能够被该效果特殊召唤（符合其召唤条件与苏生限制）。
function c35781051.spfilter(c,e,tp)
	return c:IsSetCard(0x5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 表效果发动时的合法性判定：自己主要怪兽区存在空位，并且手卡中存在至少1只可通过该效果特殊召唤的「秘仪之力」怪兽。
function c35781051.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）检查自己主要怪兽区是否有可用空格（空格数需大于0），否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手卡中是否存在至少1张满足spfilter的「秘仪之力」怪兽；e和tp作为过滤器额外参数传入。
		and Duel.IsExistingMatchingCard(c35781051.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记连锁操作信息：本次效果处理时将从手卡特殊召唤1只怪兽；因具体特殊召唤哪只在处理时才确定，所以targets传nil，目标玩家为tp，目标位置为手卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 表效果实际处理：若我方怪兽区没有空位则直接结束；否则由我方从手卡选择1只符合条件的「秘仪之力」怪兽，以表侧表示特殊召唤到我方场上。
function c35781051.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认：如果我方主要怪兽区可用空格数小于等于0，则无法特殊召唤，立即终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示，并将该提示写入SelectMatchingCard的选择消息缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从我方手卡选择1张满足spfilter的「秘仪之力」怪兽；这是不取对象的效果，在实际处理时选择。
	local g=Duel.SelectMatchingCard(tp,c35781051.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选择的怪兽以表侧表示特殊召唤到我方场上；nocheck=false与nolimit=false表示仍需检查该怪兽的召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 这是里效果的发动条件：仅在对方玩家通常召唤怪兽成功（ep~=tp），且这张卡抛硬币结果为里（FLAG_ID_ARCANA_COIN标签值为0）时，里效果才满足发动条件。
function c35781051.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==0
end
-- 里效果发动时没有额外条件；只需登记操作信息，预告效果处理时将把手卡1张卡送去墓地。
function c35781051.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记连锁操作信息：本次处理包含“从手卡把1张卡送去墓地”这一类别；具体是哪张手卡在处理时才确定，所以targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 里效果实际处理：由我方从手卡选择1张卡（任意卡），将其以效果原因送去墓地。
function c35781051.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示“请选择要送去墓地的卡”的提示，并将该提示写入选择消息缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己手卡选择1张卡（无过滤条件，可选择任意手卡卡片；不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()~=0 then
		-- 将所选择的手卡以效果原因（REASON_EFFECT）送去墓地，完成里效果。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

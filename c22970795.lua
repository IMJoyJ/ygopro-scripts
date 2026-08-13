--ワイトロード
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在墓地存在当作「白骨」使用。
-- ②：自己墓地有「白骨」或「白骨王」存在的场合，把手卡·场上的这张卡送去墓地才能发动。把最多有自己墓地的「白骨」「白骨王」数量的卡从自己卡组上面送去墓地。
-- ③：把墓地的这张卡除外，以自己墓地1只「白骨」或「白骨王」为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册「白骨道领主」的初始效果：①墓地中卡名当作「白骨」；②发动后从自己卡组顶送墓；③除外自身并特殊召唤墓地1只「白骨」/「白骨王」。
function s.initial_effect(c)
	-- ①效果：这张卡的卡名只要在墓地存在当作「白骨」使用（注册在墓地视为32274490「白骨」）。
	aux.EnableChangeCode(c,32274490,LOCATION_GRAVE)
	-- 这个卡名的②③的效果1回合各能使用1次。②：自己墓地有「白骨」或「白骨王」存在的场合，把手卡·场上的这张卡送去墓地才能发动。把最多有自己墓地的「白骨」「白骨王」数量的卡从自己卡组上面送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组送去墓地"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetCost(s.tgcost)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- 这个卡名的②③的效果1回合各能使用1次。③：把墓地的这张卡除外，以自己墓地1只「白骨」或「白骨王」为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置③效果的发动代价：把墓地中的这张卡除外（利用aux.bfgcost实现对墓地的自身除外的cost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ②效果的发动条件函数：确认自己墓地存在至少1张「白骨」或「白骨王」。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己墓地是否存在至少1张卡名符合「白骨」(32274490)或「白骨王」(36021814)的卡。
	return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- ②效果的代价函数：把手卡·场上的这张卡送去墓地作为发动代价；检查其能否作为cost送去墓地，支付时将其送入墓地。
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 实际支付代价：将这张卡以cost原因送去墓地。
	Duel.SendtoGrave(c,REASON_COST)
end
-- ②效果的数量计算过滤函数：筛选卡名为「白骨」或「白骨王」的卡，用于统计墓地中这两种卡的数量。
function s.tgfilter(c)
	return c:IsCode(32274490,36021814)
end
-- ②效果的发动目标/合法检查函数：确认卡组有卡且玩家可以从卡组顶送墓，并设置本次效果的操作信息为卡组送墓。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组至少有1张卡，且玩家允许将卡组顶的卡送去墓地。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 设置操作信息：本次效果处理涉及从卡组顶把卡送去墓地；具体数量在效果处理时决定，因此对象暂为nil。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,0)
end
-- ②效果处理：计算可送墓的最大数量，让玩家选择实际送墓张数，然后从卡组顶将对应数量的卡送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算最大送墓数：取当前卡组剩余数量和墓地中「白骨」「白骨王」总数中的较小值。
	local max=math.min(Duel.GetFieldGroupCount(tp,LOCATION_DECK,0),Duel.GetMatchingGroupCount(s.tgfilter,tp,LOCATION_GRAVE,0,nil))
	if max==0 then return end
	local t={}
	for i=1,max do
		t[i]=max-i+1
	end
	-- 显示选择提示，请求玩家选择要送去墓地的卡的数量。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要送去墓地的卡的数量"
	-- 让玩家从可选数量（1到max）中宣言一个数字，作为实际从卡组顶送去墓地的卡数。
	local announce=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 以效果原因将玩家卡组顶的announce张卡送去墓地。
	Duel.DiscardDeck(tp,announce,REASON_EFFECT)
end
-- ③效果对象过滤函数：选择墓地中卡名为「白骨」或「白骨王」，且能够被特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsCode(32274490,36021814) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动目标与对象选择函数：确认自己怪兽区有空位且墓地有合法对象，然后选择1只墓地的「白骨」/「白骨王」作为效果对象，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc) end
	-- 发动合法性检查：自己场上存在可用的怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查：墓地存在至少1只符合条件的「白骨」或「白骨王」，且能成为此效果的对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 显示选择提示，请求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只符合条件的「白骨」或「白骨王」作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果会将对象怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理：将发动时选择且在效果处理时仍与效果关联的对象怪兽，以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽特殊召唤到自己场上，表侧表示（POS_FACEUP），不检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

--C・チッキー
-- 效果：
-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·天空蜂鸟」。
function c17363041.initial_effect(c)
	-- 记录这张卡上记载着卡号54959865（新空间侠·天空蜂鸟）的卡名，用于支持相关检索与判定。
	aux.AddCodeList(c,54959865)
	-- 场上有「新宇宙」存在时，可以把这张卡作为祭品从手卡·卡组特殊召唤1只「新空间侠·天空蜂鸟」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17363041,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c17363041.spcon)
	e1:SetCost(c17363041.spcost)
	e1:SetTarget(c17363041.sptg)
	e1:SetOperation(c17363041.spop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：仅当场上存在「新宇宙」时，该起动效果才能发动。
function c17363041.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前场上是否有卡号为42015635的「新宇宙」场地存在。
	return Duel.IsEnvironment(42015635)
end
-- 定义发动代价：将这张卡自身解放作为cost；chk==0时先检查这张卡是否可以解放。
function c17363041.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡作为代价解放（REASON_COST）送入墓地。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义特殊召唤候选的过滤条件：卡号为54959865，且能被当前效果正常特殊召唤。
function c17363041.spfilter(c,e,tp)
	return c:IsCode(54959865) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动目标检查：确认自己场上有可用的特召区域，且手卡·卡组中存在符合条件的特召对象。
function c17363041.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可供特殊召唤的可用区域（允许解放自身后空出区域的情况）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡·卡组中是否存在至少1张满足spfilter条件的「新空间侠·天空蜂鸟」。
		and Duel.IsExistingMatchingCard(c17363041.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的特殊召唤操作信息，声明将从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义效果处理：实际从手卡·卡组将「新空间侠·天空蜂鸟」特殊召唤到自己场上。
function c17363041.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上有可用怪兽区域，没有则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时再次确认场上仍有「新宇宙」存在，若已不在则效果不处理。
	if not Duel.IsEnvironment(42015635) then return end
	-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组选择1张满足条件的「新空间侠·天空蜂鸟」。
	local g=Duel.SelectMatchingCard(tp,c17363041.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

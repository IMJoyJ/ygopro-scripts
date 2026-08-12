--不知火の隠者
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上1只不死族怪兽解放才能发动。从卡组把1只守备力0的不死族调整特殊召唤。
-- ②：这张卡被除外的场合，以「不知火的隐者」以外的除外的1只自己的「不知火」怪兽为对象才能发动。那只怪兽特殊召唤。场上有「不知火流 转生之阵」存在的场合，这个效果的对象可以变成2只。
function c94801854.initial_effect(c)
	-- 记录这张卡的效果中记载了「不知火流 转生之阵」的卡名
	aux.AddCodeList(c,40005099)
	-- ①：把自己场上1只不死族怪兽解放才能发动。从卡组把1只守备力0的不死族调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94801854,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCountLimit(1,94801854)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c94801854.cost)
	e1:SetTarget(c94801854.target)
	e1:SetOperation(c94801854.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以「不知火的隐者」以外的除外的1只自己的「不知火」怪兽为对象才能发动。那只怪兽特殊召唤。场上有「不知火流 转生之阵」存在的场合，这个效果的对象可以变成2只。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94801854,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,94801855)
	e2:SetTarget(c94801854.sptg)
	e2:SetOperation(c94801854.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上可解放的不死族怪兽（若怪兽区已满，则必须解放自己主要怪兽区内的怪兽以腾出空位）
function c94801854.spcfilter(c,ft,tp)
	return c:IsRace(RACE_ZOMBIE)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- ①号效果的COST：解放自己场上1只不死族怪兽
function c94801854.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否满足发动条件：场上存在至少1只可解放的满足过滤条件的不死族怪兽
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c94801854.spcfilter,1,nil,ft,tp) end
	-- 玩家选择1只满足过滤条件的不死族怪兽
	local sg=Duel.SelectReleaseGroup(tp,c94801854.spcfilter,1,1,nil,ft,tp)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(sg,REASON_COST)
end
-- 过滤条件：卡组中守备力为0的不死族调整怪兽，且能被特殊召唤
function c94801854.spfilter1(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_TUNER) and c:IsDefense(0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的靶向：检查卡组中是否存在满足条件的怪兽，并设置特殊召唤的操作信息
function c94801854.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足过滤条件的不死族调整怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94801854.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的处理：从卡组选择1只守备力0的不死族调整怪兽特殊召唤
function c94801854.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组中选择1只满足过滤条件的不死族调整怪兽
	local g=Duel.SelectMatchingCard(tp,c94801854.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：除外状态的、表侧表示的、卡名不为「不知火的隐者」的「不知火」怪兽，且能被特殊召唤
function c94801854.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xd9) and not c:IsCode(94801854) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②号效果的靶向：检查并选择除外状态的「不知火」怪兽作为效果对象
function c94801854.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c94801854.spfilter2(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外状态中是否存在至少1只满足过滤条件的「不知火」怪兽
		and Duel.IsExistingTarget(c94801854.spfilter2,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 计算最大可选择的对象数量（不超过2只，且不超过自己场上可用怪兽区域的数量）
	local ct=math.min(2,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or not Duel.IsEnvironment(40005099) then ct=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择1到ct只满足过滤条件的除外状态的「不知火」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c94801854.spfilter2,tp,LOCATION_REMOVED,0,1,ct,nil,e,tp)
	-- 设置效果处理时的操作信息为：特殊召唤选中的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- ②号效果的处理：将作为效果对象的「不知火」怪兽特殊召唤
function c94801854.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁中仍与该效果有关联的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	-- 将选中的怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end

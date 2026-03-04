--クローラー・ランヴィエ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡反转的场合，以自己墓地最多2只「机怪虫」怪兽为对象才能发动。那些怪兽加入手卡。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「机怪虫·郎飞结虫」以外的2只「机怪虫」怪兽从卡组里侧守备表示特殊召唤（同名卡最多1张）。
function c10698416.initial_effect(c)
	-- ①：这张卡反转的场合，以自己墓地最多2只「机怪虫」怪兽为对象才能发动。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10698416,0))  --"墓地回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,10698416)
	e1:SetTarget(c10698416.target)
	e1:SetOperation(c10698416.operation)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「机怪虫·郎飞结虫」以外的2只「机怪虫」怪兽从卡组里侧守备表示特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10698416,1))  --"2只怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,10698417)
	e2:SetCondition(c10698416.spcon)
	e2:SetTarget(c10698416.sptg)
	e2:SetOperation(c10698416.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「机怪虫」怪兽（可加入手牌）
function c10698416.filter(c)
	return c:IsSetCard(0x104) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理时的选对象函数，用于选择墓地中的「机怪虫」怪兽
function c10698416.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10698416.filter(chkc) end
	-- 检查是否满足选择对象的条件（墓地至少有1只符合条件的怪兽）
	if chk==0 then return Duel.IsExistingTarget(c10698416.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择1~2只满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c10698416.filter,tp,LOCATION_GRAVE,0,1,2,nil)
	-- 设置效果处理信息，表示将选择的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数，执行将怪兽加入手牌的操作
function c10698416.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的对象卡组，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将符合条件的怪兽以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 判断该卡是否因对方效果离场的条件函数
function c10698416.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 过滤函数，用于筛选满足条件的「机怪虫」怪兽（可特殊召唤）
function c10698416.filter1(c,e,tp)
	return c:IsSetCard(0x104) and not c:IsCode(10698416) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果处理时的选对象函数，用于选择要特殊召唤的怪兽
function c10698416.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家是否受到「王家长眠之谷」等效果影响
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 检查玩家场上是否有足够的召唤区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		-- 获取满足条件的卡组怪兽集合
		local g=Duel.GetMatchingGroup(c10698416.filter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置效果处理信息，表示将特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤操作
function c10698416.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否受到「王家长眠之谷」等效果影响
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查玩家场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取满足条件的卡组怪兽集合
	local g=Duel.GetMatchingGroup(c10698416.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从满足条件的怪兽中选择2只不同卡名的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 以里侧守备表示将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方确认特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,sg)
	end
end

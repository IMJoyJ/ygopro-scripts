--クローラー・レセプター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡反转的场合才能发动。从卡组把1只「机怪虫」怪兽加入手卡。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「机怪虫·受体虫」以外的2只「机怪虫」怪兽从卡组里侧守备表示特殊召唤（同名卡最多1张）。
function c83293307.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从卡组把1只「机怪虫」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83293307,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,83293307)
	e1:SetTarget(c83293307.target)
	e1:SetOperation(c83293307.operation)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「机怪虫·受体虫」以外的2只「机怪虫」怪兽从卡组里侧守备表示特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83293307,1))  --"2只怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,83293308)
	e2:SetCondition(c83293307.spcon)
	e2:SetTarget(c83293307.sptg)
	e2:SetOperation(c83293307.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中的「机怪虫」怪兽且可以加入手卡
function c83293307.filter(c)
	return c:IsSetCard(0x104) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备与操作信息设置（检索卡组中的「机怪虫」怪兽）
function c83293307.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足过滤条件的「机怪虫」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c83293307.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含将卡组的1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的执行：从卡组选择1只「机怪虫」怪兽加入手卡并给对方确认
function c83293307.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1只满足条件的「机怪虫」怪兽
	local g=Duel.SelectMatchingCard(tp,c83293307.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件：表侧表示的这张卡因对方的效果从自己场上离开
function c83293307.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 过滤条件：卡组中「机怪虫·受体虫」以外的、可以里侧守备表示特殊召唤的「机怪虫」怪兽
function c83293307.filter1(c,e,tp)
	return c:IsSetCard(0x104) and not c:IsCode(83293307) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果②的发动准备与操作信息设置（特殊召唤2只卡名不同的「机怪虫」怪兽）
function c83293307.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 检查自己的主要怪兽区域是否有2个及以上的空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		-- 获取卡组中所有满足特殊召唤条件的「机怪虫」怪兽
		local g=Duel.GetMatchingGroup(c83293307.filter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置连锁信息，表示该效果包含从卡组特殊召唤2只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果②的执行：从卡组选择2只卡名不同的「机怪虫」怪兽里侧守备表示特殊召唤
function c83293307.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时，若自己的主要怪兽区域空位不足2个，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 效果处理时，获取卡组中所有满足特殊召唤条件的「机怪虫」怪兽
	local g=Duel.GetMatchingGroup(c83293307.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从满足条件的怪兽中选择2只卡名不同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 将选中的2只怪兽在自己场上里侧守备表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认特殊召唤的里侧表示怪兽
		Duel.ConfirmCards(1-tp,sg)
	end
end

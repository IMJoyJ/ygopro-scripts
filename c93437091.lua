--ビンゴマシーンGO！GO！
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组选以下的卡合计3张给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩下的卡回到卡组。
-- ●「青眼」怪兽
-- ●除「摇号机GO！GO！」外的有「青眼白龙」「青眼究极龙」其中任意种的卡名记述的魔法·陷阱卡
function c93437091.initial_effect(c)
	-- 注册该卡片记述了「青眼白龙」和「青眼究极龙」的卡名
	aux.AddCodeList(c,89631139,23995346)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组选以下的卡合计3张给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩下的卡回到卡组。●「青眼」怪兽●除「摇号机GO！GO！」外的有「青眼白龙」「青眼究极龙」其中任意种的卡名记述的魔法·陷阱卡
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,93437091+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c93437091.thtg)
	e1:SetOperation(c93437091.thop)
	c:RegisterEffect(e1)
end
-- 过滤卡组中符合条件的「青眼」怪兽，或者除「摇号机GO！GO！」外记述有「青眼白龙」或「青眼究极龙」卡名的魔法·陷阱卡
function c93437091.thfilter(c)
	-- 过滤除「摇号机GO！GO！」外，记述有「青眼白龙」或「青眼究极龙」卡名的魔法·陷阱卡
	return (((aux.IsCodeListed(c,89631139) or aux.IsCodeListed(c,23995346)) and not c:IsCode(93437091) and c:IsType(TYPE_SPELL+TYPE_TRAP))
		or (c:IsSetCard(0xdd) and c:IsType(TYPE_MONSTER))) and c:IsAbleToHand()
end
-- 效果发动的目标过滤与检测，检查卡组中是否存在至少3张符合条件的卡，并设置检索的操作信息
function c93437091.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检测卡组中是否存在至少3张符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c93437091.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组选3张符合条件的卡给对方观看并由对方随机选1张加入手牌，其余卡回到卡组
function c93437091.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有符合条件的卡片
	local g=Duel.GetMatchingGroup(c93437091.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 提示己方玩家选择要展示给对方观看的3张卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 将选出的3张卡给对方玩家确认
		Duel.ConfirmCards(1-tp,sg)
		-- 提示对方玩家从展示的卡片中随机选择1张
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:RandomSelect(1-tp,1)
		-- 将己方卡组洗牌
		Duel.ShuffleDeck(tp)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方随机选中的那1张卡加入己方手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end

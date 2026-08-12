--運命の一枚
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：双方从自身卡组选1张卡。那之后，双方把对方卡组的卡随机选4张。双方各自把自身选的1张卡和对方选的4张混合洗切，从那5张之中随机选1张，给双方确认，加入自身手卡。剩下的卡回到自身卡组。
function c74191528.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：双方从自身卡组选1张卡。那之后，双方把对方卡组的卡随机选4张。双方各自把自身选的1张卡和对方选的4张混合洗切，从那5张之中随机选1张，给双方确认，加入自身手卡。剩下的卡回到自身卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,74191528+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c74191528.target)
	e1:SetOperation(c74191528.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查卡片是否可以加入手卡
function c74191528.filter(c)
	return c:IsAbleToHand()
end
-- 效果发动的目标检查，确认双方卡组是否都至少有5张卡，且各自卡组中存在可以加入手卡的卡
function c74191528.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查回合玩家的卡组中是否至少有5张卡，且存在可以加入手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c74191528.filter,tp,LOCATION_DECK,0,5,nil)
		-- 检查对方玩家的卡组中是否至少有5张卡，且存在可以加入手卡的卡
		and Duel.IsExistingMatchingCard(c74191528.filter,1-tp,LOCATION_DECK,0,5,nil) end
	-- 设置操作信息，表示此效果的处理涉及双方玩家从卡组将卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_DECK)
end
-- 效果处理的开始，再次检查双方卡组数量是否都至少有5张，且各自卡组中存在可以加入手卡的卡，若不满足则不处理
function c74191528.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方卡组的卡片数量是否都至少有5张
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 or Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<5
		-- 检查回合玩家的卡组中是否存在可以加入手卡的卡
		or not Duel.IsExistingMatchingCard(c74191528.filter,tp,LOCATION_DECK,0,1,nil)
		-- 检查对方玩家的卡组中是否存在可以加入手卡的卡，若不满足上述任一条件则结束效果处理
		or not Duel.IsExistingMatchingCard(c74191528.filter,1-tp,LOCATION_DECK,0,1,nil) then return end
	-- 给回合玩家发送提示信息，提示其从自身卡组选择1张卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(74191528,0))  --"请选择自己的1张卡"
	-- 回合玩家从自身卡组选择1张可以加入手卡的卡
	local g1=Duel.SelectMatchingCard(tp,c74191528.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 给对方玩家发送提示信息，提示其从自身卡组选择1张卡
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(74191528,0))  --"请选择自己的1张卡"
	-- 对方玩家从自身卡组选择1张可以加入手卡的卡
	local g2=Duel.SelectMatchingCard(1-tp,c74191528.filter,1-tp,LOCATION_DECK,0,1,1,nil)
	-- 中断当前效果，使之后的效果处理不与前面的选择卡片同时处理
	Duel.BreakEffect()
	-- 洗切回合玩家的卡组，以便后续对方能随机选择卡片
	Duel.ShuffleDeck(tp)
	-- 洗切对方玩家的卡组，以便后续回合玩家能随机选择卡片
	Duel.ShuffleDeck(1-tp)
	-- 给回合玩家发送提示信息，提示其从对方卡组随机选择4张卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(74191528,1))  --"请随机选择对方的4张卡"
	-- 回合玩家从对方卡组中随机选择4张卡（排除对方之前选出的那1张卡）
	local og2=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_DECK,4,4,g2:GetFirst())
	-- 给对方玩家发送提示信息，提示其从对方（即回合玩家）卡组随机选择4张卡
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(74191528,1))  --"请随机选择对方的4张卡"
	-- 对方玩家从回合玩家的卡组中随机选择4张卡（排除回合玩家之前选出的那1张卡）
	local og1=Duel.SelectMatchingCard(1-tp,nil,1-tp,0,LOCATION_DECK,4,4,g1:GetFirst())
	g1:Merge(og1)
	g2:Merge(og2)
	-- 再次洗切回合玩家的卡组（将未被选中的卡洗回卡组）
	Duel.ShuffleDeck(tp)
	-- 再次洗切对方玩家的卡组（将未被选中的卡洗回卡组）
	Duel.ShuffleDeck(1-tp)
	-- 给回合玩家发送提示信息，提示其从对方的5张卡中随机选择1张加入对方手卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(74191528,2))  --"请随机选择要加入对方手卡的卡"
	local sg2=g2:Select(tp,1,1,nil)
	-- 给对方玩家发送提示信息，提示其从回合玩家的5张卡中随机选择1张加入回合玩家手卡
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(74191528,2))  --"请随机选择要加入对方手卡的卡"
	local sg1=g1:Select(1-tp,1,1,nil)
	-- 将对方玩家为回合玩家随机选出的1张卡加入回合玩家的手卡
	Duel.SendtoHand(sg1,tp,REASON_EFFECT)
	-- 将回合玩家为对方玩家随机选出的1张卡加入对方玩家的手卡
	Duel.SendtoHand(sg2,1-tp,REASON_EFFECT)
	-- 给回合玩家确认加入对方手卡的那张卡
	Duel.ConfirmCards(tp,sg2)
	-- 给对方玩家确认加入回合玩家手卡的那张卡
	Duel.ConfirmCards(1-tp,sg1)
end

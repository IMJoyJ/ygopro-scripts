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
-- 过滤条件：可以加入手卡的卡
function c74191528.filter(c,p)
	return c:IsAbleToHand(p)
end
-- 发动条件与操作信息
function c74191528.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否有至少5张可加入手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c74191528.filter,tp,LOCATION_DECK,0,5,nil,tp)
		-- 且对方卡组是否有至少5张可加入手卡的卡
		and Duel.IsExistingMatchingCard(c74191528.filter,1-tp,LOCATION_DECK,0,5,nil,1-tp) end
	-- 设置操作信息：双方各自将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_DECK)
end
-- 效果处理函数
function c74191528.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方卡组数量是否均至少为5张
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 or Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<5
		-- 或自己卡组没有可加入手卡的卡
		or not Duel.IsExistingMatchingCard(c74191528.filter,tp,LOCATION_DECK,0,1,nil,tp)
		-- 或对方卡组没有可加入手卡的卡
		or not Duel.IsExistingMatchingCard(c74191528.filter,1-tp,LOCATION_DECK,0,1,nil,1-tp) then return end
	-- 提示自己从自身卡组选1张卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(74191528,0))  --"请选择自己的1张卡"
	-- 自己从自身卡组选1张卡
	local g1=Duel.SelectMatchingCard(tp,c74191528.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	-- 提示对方从自身卡组选1张卡
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(74191528,0))  --"请选择自己的1张卡"
	-- 对方从自身卡组选1张卡
	local g2=Duel.SelectMatchingCard(1-tp,c74191528.filter,1-tp,LOCATION_DECK,0,1,1,nil,1-tp)
	-- 中断效果处理
	Duel.BreakEffect()
	-- 洗切自己卡组
	Duel.ShuffleDeck(tp)
	-- 洗切对方卡组
	Duel.ShuffleDeck(1-tp)
	-- 提示自己随机选对方卡组4张卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(74191528,1))  --"请随机选择对方的4张卡"
	-- 自己从对方卡组随机选4张卡
	local og2=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_DECK,4,4,g2:GetFirst())
	-- 提示对方随机选自己卡组4张卡
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(74191528,1))  --"请随机选择对方的4张卡"
	-- 对方从自己卡组随机选4张卡
	local og1=Duel.SelectMatchingCard(1-tp,nil,1-tp,0,LOCATION_DECK,4,4,g1:GetFirst())
	g1:Merge(og1)
	g2:Merge(og2)
	-- 洗切自己卡组
	Duel.ShuffleDeck(tp)
	-- 洗切对方卡组
	Duel.ShuffleDeck(1-tp)
	-- 提示自己从对方选出的5张卡中随机选1张
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(74191528,2))  --"请随机选择要加入对方手卡的卡"
	local sg2=g2:Select(tp,1,1,nil)
	-- 提示对方从自己选出的5张卡中随机选1张
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(74191528,2))  --"请随机选择要加入对方手卡的卡"
	local sg1=g1:Select(1-tp,1,1,nil)
	-- 将选中的卡加入自己手卡
	Duel.SendtoHand(sg1,tp,REASON_EFFECT)
	-- 将选中的卡加入对方手卡
	Duel.SendtoHand(sg2,1-tp,REASON_EFFECT,1-tp)
	-- 双方确认对方加入手卡的卡
	Duel.ConfirmCards(tp,sg2)
	-- 双方确认自己加入手卡的卡
	Duel.ConfirmCards(1-tp,sg1)
end

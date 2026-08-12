--ティンダングル・アポストル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡反转的场合才能发动。选自己场上最多3只里侧表示怪兽变成表侧守备表示。这个效果变成表侧守备表示的怪兽全部是「廷达魔三角」怪兽的场合，可以把最多有那些怪兽数量的「廷达魔三角」卡从卡组加入手卡。
function c67744384.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。选自己场上最多3只里侧表示怪兽变成表侧守备表示。这个效果变成表侧守备表示的怪兽全部是「廷达魔三角」怪兽的场合，可以把最多有那些怪兽数量的「廷达魔三角」卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67744384,0))  --"变成表侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,67744384)
	e1:SetTarget(c67744384.target)
	e1:SetOperation(c67744384.operation)
	c:RegisterEffect(e1)
end
-- 效果①的发动准备与可行性检测
function c67744384.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只里侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- 过滤卡组中可以加入手牌的「廷达魔三角」卡
function c67744384.thfilter(c)
	return c:IsSetCard(0x10b) and c:IsAbleToHand()
end
-- 效果①的处理阶段
function c67744384.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择自己场上1到3只里侧表示怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_MZONE,0,1,3,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽变成表侧守备表示，并记录成功改变表示形式的怪兽数量
		local ct=Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
		-- 获取实际改变了表示形式的怪兽卡片组
		local og=Duel.GetOperatedGroup()
		if og:IsExists(Card.IsSetCard,ct,nil,0x10b) then
			-- 获取卡组中所有满足条件的「廷达魔三角」卡
			local sg=Duel.GetMatchingGroup(c67744384.thfilter,tp,LOCATION_DECK,0,nil)
			-- 检查卡组中是否有可检索的卡，并询问玩家是否发动检索效果
			if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(67744384,1)) then  --"是否把卡加入手卡？"
				-- 中断当前效果处理，使后续的检索手牌处理与改变表示形式不视为同时进行
				Duel.BreakEffect()
				-- 提示玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local tg=sg:Select(tp,1,ct,nil)
				-- 将选中的「廷达魔三角」卡加入玩家手牌
				Duel.SendtoHand(tg,tp,REASON_EFFECT)
				-- 让对方玩家确认加入手牌的卡片
				Duel.ConfirmCards(1-tp,tg)
			end
		end
	end
end

--レプティレス・ラミフィケーション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以把1张手卡送去墓地，从以下效果选择2个发动。
-- ●从卡组把1只「爬虫妖」怪兽加入手卡。
-- ●从卡组把「爬虫妖女的蛇化分歧」以外的1张「爬虫妖」魔法·陷阱卡加入手卡。
-- ●选对方场上1只怪兽，那个攻击力变成0。
function c81615450.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以把1张手卡送去墓地，从以下效果选择2个发动。●从卡组把1只「爬虫妖」怪兽加入手卡。●从卡组把「爬虫妖女的蛇化分歧」以外的1张「爬虫妖」魔法·陷阱卡加入手卡。●选对方场上1只怪兽，那个攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81615450,0))  --"选择效果发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,81615450+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c81615450.cost)
	e1:SetTarget(c81615450.target)
	e1:SetOperation(c81615450.activate)
	c:RegisterEffect(e1)
end
-- 发动代价：把1张手卡送去墓地。
function c81615450.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外可以作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡送去墓地。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 过滤条件：卡组中的「爬虫妖」怪兽。
function c81615450.thfilter1(c)
	return c:IsSetCard(0x3c) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
-- 过滤条件：卡组中「爬虫妖女的蛇化分歧」以外的「爬虫妖」魔法·陷阱卡。
function c81615450.thfilter2(c)
	return c:IsSetCard(0x3c) and c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(81615450)
end
-- 效果发动时的目标选择：从3个效果中选择2个不同的效果发动。
function c81615450.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local off=1
	local ops={}
	local opval={}
	-- 检查卡组中是否存在可以检索的「爬虫妖」怪兽。
	if Duel.IsExistingMatchingCard(c81615450.thfilter1,tp,LOCATION_DECK,0,1,nil) then
		ops[off]=aux.Stringid(81615450,1)  --"检索「爬虫妖」怪兽"
		opval[off]=1
		off=off+1
	end
	-- 检查卡组中是否存在可以检索的「爬虫妖女的蛇化分歧」以外的「爬虫妖」魔法·陷阱卡。
	if Duel.IsExistingMatchingCard(c81615450.thfilter2,tp,LOCATION_DECK,0,1,nil) then
		ops[off]=aux.Stringid(81615450,2)  --"检索「爬虫妖」魔法·陷阱卡"
		opval[off]=2
		off=off+1
	end
	-- 检查对方场上是否存在攻击力不为0的表侧表示怪兽。
	if Duel.IsExistingMatchingCard(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) then
		ops[off]=aux.Stringid(81615450,3)  --"对方怪兽攻击力变成0"
		opval[off]=3
		off=off+1
	end
	if chk==0 then return off>2 end
	-- 让玩家选择第1个要发动的效果。
	local sel=Duel.SelectOption(tp,table.unpack(ops))+1
	local op=opval[sel]
	table.remove(ops,sel)
	table.remove(opval,sel)
	-- 让玩家从剩余的选项中选择第2个要发动的效果。
	sel=Duel.SelectOption(tp,table.unpack(ops))+1
	op=op+(opval[sel]<<4)
	e:SetLabel(op)
	-- 设置连锁信息：包含从卡组将卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：依次执行玩家选择的两个效果。
function c81615450.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local op1=op&0xf
	local op2=op>>4
	if op1==1 or op2==1 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只「爬虫妖」怪兽。
		local g=Duel.SelectMatchingCard(tp,c81615450.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if op1==2 or op2==2 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张「爬虫妖女的蛇化分歧」以外的「爬虫妖」魔法·陷阱卡。
		local g=Duel.SelectMatchingCard(tp,c81615450.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断效果处理，使后续处理不视为与前一个效果同时处理。
			Duel.BreakEffect()
			-- 将选中的魔法·陷阱卡加入手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if op1==3 or op2==3 then
		-- 提示玩家选择表侧表示的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择对方场上1只攻击力不为0的表侧表示怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 选中该怪兽并显示选择框动画。
			Duel.HintSelection(g)
			-- 中断效果处理，使后续处理不视为与前一个效果同时处理。
			Duel.BreakEffect()
			-- 选对方场上1只怪兽，那个攻击力变成0。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			g:GetFirst():RegisterEffect(e1)
		end
	end
end

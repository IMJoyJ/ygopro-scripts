--金満で謙虚な壺
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能用卡的效果抽卡。
-- ①：从额外卡组把3张或6张卡里侧除外才能发动。把除外数量的卡从自己卡组上面翻开，从那之中选1张加入手卡，剩下的卡用喜欢的顺序回到卡组下面。这张卡的发动后，直到回合结束时对方受到的全部伤害变成一半。
function c84211599.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能用卡的效果抽卡。①：从额外卡组把3张或6张卡里侧除外才能发动。把除外数量的卡从自己卡组上面翻开，从那之中选1张加入手卡，剩下的卡用喜欢的顺序回到卡组下面。这张卡的发动后，直到回合结束时对方受到的全部伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,84211599+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c84211599.cost)
	e1:SetTarget(c84211599.target)
	e1:SetOperation(c84211599.activate)
	c:RegisterEffect(e1)
	if not c84211599.gf then
		c84211599.gf=true
		-- 这张卡发动的回合，自己不能用卡的效果抽卡。①：从额外卡组把3张或6张卡里侧除外才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_DRAW)
		ge1:SetOperation(c84211599.regop)
		-- 注册全局环境效果，用于检测玩家是否在当前回合通过卡的效果抽过卡。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 抽卡事件触发时的操作函数，若因卡的效果抽卡，则给该玩家注册对应的标识效果。
function c84211599.regop(e,tp,eg,ep,ev,re,r,rp)
	if r==REASON_EFFECT then
		-- 为因卡的效果抽卡的玩家注册回合结束前有效的标识效果。
		Duel.RegisterFlagEffect(ep,84211599,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 效果发动成本（Cost）的暂存标记函数，将Label设为100以在target中确认是否正确支付Cost。
function c84211599.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 效果发动时的目标选择与合法性检测函数，处理Cost支付（里侧除外额外卡组的卡）以及限制条件的检测。
function c84211599.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己额外卡组中可以作为Cost里侧除外的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_EXTRA,0,nil,POS_FACEDOWN)
	-- 获取自己卡组的卡片数量。
	local count=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	-- 检查是否满足“除外3张卡发动”的条件（额外卡组及卡组数量均不小于3，且卡组最上方3张卡中存在可以加入手牌的卡）。
	local b1=#g>=3 and count>=3 and Duel.GetDecktopGroup(tp,3):IsExists(Card.IsAbleToHand,1,nil)
	-- 检查是否满足“除外6张卡发动”的条件（额外卡组及卡组数量均不小于6，且卡组最上方6张卡中存在可以加入手牌的卡）。
	local b2=#g>=6 and count>=6 and Duel.GetDecktopGroup(tp,6):IsExists(Card.IsAbleToHand,1,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 确认本回合自己没有用卡的效果抽过卡，且满足除外3张或6张的发动条件。
		return Duel.GetFlagEffect(tp,84211599)==0 and (b1 or b2)
	end
	local op=0
	if b1 and b2 then
		-- 让玩家选择是“除外3张卡发动”还是“除外6张卡发动”。
		op=Duel.SelectOption(tp,aux.Stringid(84211599,0),aux.Stringid(84211599,1))  --"除外3张卡发动/除外6张卡发动"
	else
		-- 仅满足除外3张的条件时，强制选择“除外3张卡发动”。
		op=Duel.SelectOption(tp,aux.Stringid(84211599,0))  --"除外3张卡发动"
	end
	local ct= op==0 and 3 or 6
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=g:Select(tp,ct,ct,nil)
	-- 将选中的额外卡组卡片里侧除外作为发动的Cost。
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
	-- 设置当前连锁的目标玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为除外卡片的数量（3或6）。
	Duel.SetTargetParam(ct)
	-- 设置连锁的操作信息，表示该效果包含“从卡组将1张卡加入手牌”的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡发动的回合，自己不能用卡的效果抽卡。把除外数量的卡从自己卡组上面翻开，从那之中选1张加入手卡，剩下的卡用喜欢的顺序回到卡组下面。这张卡的发动后，直到回合结束时对方受到的全部伤害变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合自己不能用卡的效果抽卡的效果。
	Duel.RegisterEffect(e1,tp)
end
-- 效果处理（Activate）函数，执行翻开卡组、选卡加入手牌、余下卡片放回卡组最下方以及伤害减半的效果。
function c84211599.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和翻开卡片的数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 确认（翻开）玩家卡组最上方的指定数量（3张或6张）的卡。
	Duel.ConfirmDecktop(p,d)
	-- 获取玩家卡组最上方的指定数量（3张或6张）的卡片组。
	local g=Duel.GetDecktopGroup(p,d)
	if #g>0 then
		-- 禁用接下来的洗牌检测，防止系统在卡片加入手牌时自动洗牌。
		Duel.DisableShuffleCheck()
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sc=g:Select(p,1,1,nil):GetFirst()
		if sc:IsAbleToHand() then
			-- 将选中的卡片因效果加入手牌。
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡片。
			Duel.ConfirmCards(1-p,sc)
			-- 洗切玩家的手牌。
			Duel.ShuffleHand(p)
		else
			-- 若选中的卡无法加入手牌，则根据规则送去墓地。
			Duel.SendtoGrave(sc,REASON_RULE)
		end
	end
	if #g>1 then
		-- 让玩家对卡组最上方剩下的卡片进行排序。
		Duel.SortDecktop(tp,tp,#g-1)
		for i=1,#g-1 do
			-- 获取卡组最上方的一张卡。
			local dg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡片移动到卡组最下方。
			Duel.MoveSequence(dg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时对方受到的全部伤害变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c84211599.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册直到回合结束时对方受到的全部伤害变成一半的效果。
	Duel.RegisterEffect(e1,tp)
end
-- 伤害减半的数值计算函数，返回原始伤害值除以2并向下取整后的数值。
function c84211599.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end

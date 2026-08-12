--ゴーストリック・セイレーン
-- 效果：
-- 自己场上有「鬼计」怪兽存在的场合才能让这张卡表侧表示召唤。
-- ①：这张卡召唤·反转的场合发动。从自己卡组上面把2张卡送去墓地。那之中有「鬼计」卡的场合，可以再从以下效果选1个适用。
-- ●从卡组把1张「鬼计」魔法·陷阱卡加入手卡。
-- ●选对方场上1只效果怪兽变成里侧守备表示。
-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
function c64804316.initial_effect(c)
	-- 自己场上有「鬼计」怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c64804316.sumcon)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·反转的场合发动。从自己卡组上面把2张卡送去墓地。那之中有「鬼计」卡的场合，可以再从以下效果选1个适用。●从卡组把1张「鬼计」魔法·陷阱卡加入手卡。●选对方场上1只效果怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64804316,0))  --"从自己卡组上面把2张卡送去墓地"
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c64804316.distg)
	e2:SetOperation(c64804316.disop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
	-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(c64804316.postg)
	e4:SetOperation(c64804316.posop)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示的「鬼计」怪兽
function c64804316.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤限制效果的发生条件：自己场上不存在表侧表示的「鬼计」怪兽
function c64804316.sumcon(e)
	-- 检查自己场上是否不存在表侧表示的「鬼计」怪兽
	return not Duel.IsExistingMatchingCard(c64804316.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 召唤·反转成功时效果的靶指向（Target）函数，设置送去墓地的操作信息
function c64804316.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从卡组将2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- 过滤条件：送去墓地的卡中属于「鬼计」的卡
function c64804316.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x8d)
end
-- 过滤条件：卡组中可以加入手牌的「鬼计」魔法·陷阱卡
function c64804316.thfilter(c)
	return c:IsSetCard(0x8d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 过滤条件：对方场上表侧表示、可以变成里侧守备表示的效果怪兽
function c64804316.stfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup() and c:IsCanTurnSet()
end
-- 召唤·反转成功时效果的运行（Operation）函数，处理卡组送墓及后续的分支效果
function c64804316.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组上面把2张卡送去墓地
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
	-- 获取刚才因效果实际送去墓地的卡片组
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(c64804316.cfilter,nil)
	if ct>0 then
		-- 检查卡组中是否存在可检索的「鬼计」魔法·陷阱卡
		local b1=Duel.IsExistingMatchingCard(c64804316.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查对方场上是否存在可变成里侧守备表示的效果怪兽
		local b2=Duel.IsExistingMatchingCard(c64804316.stfilter,tp,0,LOCATION_MZONE,1,nil)
		local off=1
		local ops,opval={},{}
		if b1 then
			ops[off]=aux.Stringid(64804316,1)  --"从卡组把1张「鬼计」魔法·陷阱卡加入手卡"
			opval[off]=1
			off=off+1
		end
		if b2 then
			ops[off]=aux.Stringid(64804316,2)  --"选对方场上1只效果怪兽变成里侧守备表示"
			opval[off]=2
			off=off+1
		end
		ops[off]=aux.Stringid(64804316,3)  --"什么都不做"
		opval[off]=0
		-- 让玩家从可用的分支效果（或什么都不做）中选择一个适用
		local op=Duel.SelectOption(tp,table.unpack(ops))+1
		local sel=opval[op]
		if sel==1 then
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 让玩家从卡组选择1张「鬼计」魔法·陷阱卡
			local sg=Duel.SelectMatchingCard(tp,c64804316.thfilter,tp,LOCATION_DECK,0,1,1,nil)
			-- 将选中的卡加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		elseif sel==2 then
			-- 提示玩家选择要改变表示形式的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			-- 让玩家选择对方场上1只符合条件的效果怪兽
			local sg=Duel.SelectMatchingCard(tp,c64804316.stfilter,tp,0,LOCATION_MZONE,1,1,nil)
			-- 选中目标怪兽并显示选择框动画
			Duel.HintSelection(sg)
			-- 将选中的怪兽变成里侧守备表示
			Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
		end
	end
end
-- 自身变成里侧守备表示效果的靶指向（Target）函数，设置1回合1次限制及操作信息
function c64804316.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(64804316)==0 end
	c:RegisterFlagEffect(64804316,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：将自身变成里侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 自身变成里侧守备表示效果的运行（Operation）函数
function c64804316.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡变成里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end

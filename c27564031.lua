--Sin World
-- 效果：
-- ①：自己抽卡阶段作为进行通常抽卡的代替才能发动。从卡组把3张「罪」卡给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩下的卡回到卡组。
function c27564031.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己抽卡阶段作为进行通常抽卡的代替才能发动。从卡组把3张「罪」卡给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩下的卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27564031,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c27564031.condition)
	e2:SetTarget(c27564031.target)
	e2:SetOperation(c27564031.operation)
	c:RegisterEffect(e2)
end
-- 效果发动条件：仅在当前回合玩家是自己（即自己的抽卡阶段）时满足，确保该效果只在自己回合的抽卡阶段可以发动。
function c27564031.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断表达式：触发玩家tp是否等于当前回合玩家，用于限定只有自己回合的抽卡阶段才允许发动。
	return tp==Duel.GetTurnPlayer()
end
-- 定义筛选条件：选出卡名属于「罪」字段（0x23）且能够加入手卡的卡。
function c27564031.filter(c)
	return c:IsSetCard(0x23) and c:IsAbleToHand()
end
-- 效果发动前的合法性检查与发动手续设置：确认自己可以进行通常抽卡且卡组存在至少3张符合条件的「罪」卡；然后放弃本回合通常抽卡，并设置操作信息以声明后续会有从卡组加入手牌的处理。
function c27564031.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段（chk==0），检查是否满足发动条件：自己可以进行通常抽卡，且卡组中存在至少3张符合条件的「罪」卡。
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.IsExistingMatchingCard(c27564031.filter,tp,LOCATION_DECK,0,3,nil) end
	-- 让自己放弃本回合的通常抽卡，作为发动代价/手续，对应效果中“作为进行通常抽卡的代替才能发动”。
	aux.GiveUpNormalDraw(e,tp)
	-- 设置操作信息：效果将包含从卡组将1张卡加入手牌的处理，由于具体是哪张由对方随机选择、无法预先指定，因此targets传nil，数量为1，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果处理：从卡组筛选所有符合条件的「罪」卡；若数量不少于3张，则自己选择3张展示给对方，洗切卡组；对方随机选1张，将该卡加入自己手卡，其余卡留在卡组（即完成“剩下的卡回到卡组”）。
function c27564031.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的「罪」卡集合，作为后续选择和展示的候选。
	local g=Duel.GetMatchingGroup(c27564031.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 向自己发送选择提示，提示内容为“请选择要加入手牌的卡”，用于选择要展示给对方确认的3张「罪」卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 将选出的3张「罪」卡展示给对方玩家确认，对应“从卡组把3张「罪」卡给对方观看”。
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切自己的卡组，使卡组重新排序，同时也对应“剩下的卡回到卡组”后的洗切处理。
		Duel.ShuffleDeck(tp)
		local tg=sg:RandomSelect(1-tp,1)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方随机选中的1张卡加入其持有者的手卡（即自己手卡），效果处理原因为效果。之前已设置该卡不需要再次确认，因此直接加入手卡。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end

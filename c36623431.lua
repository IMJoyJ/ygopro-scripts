--コアキメイルの鋼核
-- 效果：
-- 这张卡在墓地存在的场合，可以作为自己的抽卡阶段时进行通常抽卡的代替，把这张卡加入手卡。此外，自己的抽卡阶段时可以从手卡把1只名字带有「核成」的怪兽送去墓地，自己墓地存在的这张卡加入手卡。
function c36623431.initial_effect(c)
	-- 这张卡在墓地存在的场合，可以作为自己的抽卡阶段时进行通常抽卡的代替，把这张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36623431,0))  --"代替抽卡加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c36623431.condition1)
	e1:SetTarget(c36623431.target1)
	e1:SetOperation(c36623431.operation1)
	c:RegisterEffect(e1)
	-- 此外，自己的抽卡阶段时可以从手卡把1只名字带有「核成」的怪兽送去墓地，自己墓地存在的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36623431,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_DRAW)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c36623431.condition2)
	e2:SetCost(c36623431.cost2)
	e2:SetTarget(c36623431.target2)
	e2:SetOperation(c36623431.operation2)
	c:RegisterEffect(e2)
end
-- 第一个效果（代替抽卡加入手卡）的发动条件：仅当本效果持有者是当前回合玩家，即在自己回合的抽卡阶段通常抽卡前才可能发动。
function c36623431.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定效果持有者tp是否为当前回合玩家，确保只在本人回合的抽卡阶段满足条件。
	return tp==Duel.GetTurnPlayer()
end
-- 第一个效果的发动目标处理：确认玩家可以进行通常抽卡且墓地的这张卡能够加入手卡，然后设定本次连锁将这张卡加入手卡的操作信息。
function c36623431.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时的合法性检查：当前玩家可以进行通常抽卡，且这张卡能够从墓地加入手卡，二者同时满足才允许发动。
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and e:GetHandler():IsAbleToHand() end
	-- 将本次连锁的操作信息设为回手牌效果，对象为这张卡，数量为1，供相关效果检测（例如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 第一个效果的处理：若仍然可以进行通常抽卡，则放弃本次通常抽卡，并将墓地的这张卡加入手卡，向对方展示。
function c36623431.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认玩家仍可进行通常抽卡，若已不能则直接终止处理。
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	-- 放弃本回合通常抽卡：将玩家的常规抽卡次数设为0并登记限制标记，实现“代替通常抽卡”的规则处理。
	aux.GiveUpNormalDraw(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果原因将这张卡从墓地送去手卡（回到持有者手牌）。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 将加入手卡的这张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,c)
	end
end
-- 第二个效果（从手牌丢弃核成怪兽后回收此卡）的发动条件：仅当效果持有者是当前回合玩家，即在自己回合的抽卡阶段结束时才能发动。
function c36623431.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定效果持有者tp是否为当前回合玩家，确保只在本人回合的抽卡阶段结束时满足条件。
	return tp==Duel.GetTurnPlayer()
end
-- cost筛选函数：手牌中满足名字带有「核成」、是怪兽且可以作为代价送去墓地的卡。
function c36623431.costfilter(c)
	return c:IsSetCard(0x1d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 第二个效果的cost处理：确认手牌存在符合条件的「核成」怪兽，则选择1张丢弃作为cost。
function c36623431.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查：从自己手牌中确认是否存在至少1张满足costfilter的卡，即名字带有「核成」的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c36623431.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌选择1张满足条件的「核成」怪兽，以cost原因丢弃。
	Duel.DiscardHand(tp,c36623431.costfilter,1,1,REASON_COST,nil)
end
-- 第二个效果的目标处理：确认墓地的这张卡可以加入手卡，并设定处理时回手牌的操作信息。
function c36623431.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 将本次连锁的操作信息设为回手牌效果，对象为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 第二个效果的处理：将墓地的这张卡加入手卡，并向对方展示。
function c36623431.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以效果原因将这张卡从墓地送去手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 将加入手卡的这张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,c)
	end
end

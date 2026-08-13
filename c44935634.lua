--レフティ・ドライバー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。这张卡的等级直到回合结束时变成3星。
-- ②：把墓地的这张卡除外才能发动。从卡组把1只「右起子」加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c44935634.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合才能发动。这张卡的等级直到回合结束时变成3星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44935634,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c44935634.target)
	e1:SetOperation(c44935634.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把墓地的这张卡除外才能发动。从卡组把1只「右起子」加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,44935634)
	-- 设置②效果的发动条件：这张卡送去墓地的回合不能发动该效果（若当前回合就是送墓回合则不能发动）。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：将这张卡从墓地除外（作为发动效果的COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44935634.thtg)
	e2:SetOperation(c44935634.thop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：这张卡不是3星时才能发动（若已是3星则不能发动）。
function c44935634.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsLevel(3) end
end
-- ①效果处理：为这张卡生成一个“等级变成3星”的效果并注册，该效果持续到回合结束（满足标准重置条件或结束阶段时被重置）。
function c44935634.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的等级直到回合结束时变成3星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(3)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 定义②效果的检索过滤函数：从卡组中选出卡名为「右起子」（60071928）且可以被加入手卡的卡。
function c44935634.thfilter(c)
	return c:IsCode(60071928) and c:IsAbleToHand()
end
-- ②效果的发动条件与操作信息：发动时确认己方卡组存在符合条件的「右起子」，并向系统登记本效果将把卡组中的1张卡加入手牌。
function c44935634.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件：己方卡组中存在至少1张符合条件的「右起子」时才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c44935634.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本效果处理时会从卡组将1张卡加入手牌（CATEGORY_TOHAND），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张符合条件的「右起子」加入其持有者手牌，并向对方玩家展示该卡。
function c44935634.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：提示玩家选择一张要加入手牌的卡，提示文字为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方玩家从卡组中选择1张符合检索条件的「右起子」。
	local g=Duel.SelectMatchingCard(tp,c44935634.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「右起子」加入其持有者的手牌，原因记为效果处理（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的「右起子」展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end

--煉獄の乖放
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1张「影依」卡给对方观看才能发动。和给人观看的卡种类（怪兽·魔法·陷阱）不同的2张「影依」卡从卡组加入手卡（相同种类最多1张）。那之后，选自己1张手卡丢弃。
-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地把1只「狱火机」怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（魔法卡发动）和②效果（墓地起动效果）。
function s.initial_effect(c)
	-- ①：把手卡1张「影依」卡给对方观看才能发动。和给人观看的卡种类（怪兽·魔法·陷阱）不同的2张「影依」卡从卡组加入手卡（相同种类最多1张）。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索并丢弃"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从自己的卡组·墓地把1只「狱火机」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置效果②的Cost为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤手牌中可展示的「影依」卡，且卡组中必须存在能与该卡及另一张不同种类的「影依」卡凑齐怪兽、魔法、陷阱各1张的2张「影依」卡。
function s.cfilter(c,tp)
	if not (c:IsSetCard(0x9d) and not c:IsPublic()) then return false end
	-- 获取卡组中所有可以加入手牌的「影依」卡。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	return g:CheckSubGroup(s.gcheck,2,2,c)
end
-- 过滤卡组中属于「影依」字段且能加入手牌的卡。
function s.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsAbleToHand()
end
-- 检查选出的卡组卡片与展示的卡片组合在一起后，是否刚好包含怪兽、魔法、陷阱各1张。
function s.gcheck(g,c)
	local mg=g:Clone()
	mg:AddCard(c)
	return mg:FilterCount(Card.IsType,nil,TYPE_MONSTER)==1
		and mg:FilterCount(Card.IsType,nil,TYPE_SPELL)==1
		and mg:FilterCount(Card.IsType,nil,TYPE_TRAP)==1
end
-- 效果①的发动Cost处理：展示手牌中1张满足条件的「影依」卡，并将其设为效果处理时的目标。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可展示且满足后续检索条件的「影依」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手牌中1张满足条件的「影依」卡。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	-- 向对方玩家展示所选的卡。
	Duel.ConfirmCards(1-tp,g)
	-- 洗切展示卡片后的手牌。
	Duel.ShuffleHand(tp)
	-- 将展示的卡设置为当前连锁的目标，以便在效果处理时读取其种类。
	Duel.SetTargetCard(g)
end
-- 效果①的发动Target处理：检查Cost是否已支付，并设置检索2张卡的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置操作信息：从卡组将2张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果①的效果处理：根据展示的卡，从卡组检索2张不同种类的「影依」卡，之后选1张手牌丢弃。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在Cost阶段展示并设为目标的卡。
	local tc=Duel.GetFirstTarget()
	-- 获取卡组中所有可检索的「影依」卡。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,tc)
	if not sg or sg:GetCount()==0 then return end
	-- 将选出的2张「影依」卡加入手牌。
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	-- 向对方展示加入手牌的卡。
	Duel.ConfirmCards(1-tp,sg)
	-- 提示玩家选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家选择1张可丢弃的手牌。
	local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
	-- 洗切剩余的手牌。
	Duel.ShuffleHand(tp)
	-- 将选中的手牌送去墓地（视为因效果丢弃）。
	Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
end
-- 过滤卡组或墓地中属于「狱火机」字段且能加入手牌的怪兽卡。
function s.thfilter2(c)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动Target处理：检查卡组或墓地是否存在「狱火机」怪兽，并设置检索的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地是否存在至少1只可加入手牌的「狱火机」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从卡组或墓地将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②的效果处理：从卡组或墓地选择1只「狱火机」怪兽加入手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1只满足条件的「狱火机」怪兽（受王家之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「狱火机」怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end

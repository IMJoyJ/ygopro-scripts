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
	-- ②：把墓地的这张卡除外才能发动。从卡组把1只「右起子」加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,44935634)
	-- 设置效果发动条件为：这张卡不在送去墓地的回合
	e2:SetCondition(aux.exccon)
	-- 设置效果发动费用为：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44935634.thtg)
	e2:SetOperation(c44935634.thop)
	c:RegisterEffect(e2)
end
-- 效果发动时的处理：检查这张卡当前等级是否不是3星
function c44935634.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsLevel(3) end
end
-- 效果发动时的处理：将这张卡的等级设置为3星，直到回合结束时
function c44935634.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将这张卡的等级设置为3星，直到回合结束时
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(3)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 检索卡组中满足条件的「右起子」卡片
function c44935634.thfilter(c)
	return c:IsCode(60071928) and c:IsAbleToHand()
end
-- 设置效果发动时的处理：检索卡组中满足条件的「右起子」卡片
function c44935634.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家来看的卡组中是否存在至少1张满足条件的「右起子」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c44935634.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理：选择1张「右起子」加入手牌并确认对方看到
function c44935634.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张「右起子」卡片
	local g=Duel.SelectMatchingCard(tp,c44935634.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end

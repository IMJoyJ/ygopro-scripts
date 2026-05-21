--ゼンマイマニュファクチャ
-- 效果：
-- 名字带有「发条」的怪兽的效果发动的场合，可以从自己卡组把1只4星以下的名字带有「发条」的怪兽加入手卡。这个效果1回合只能使用1次。
function c95714077.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 名字带有「发条」的怪兽的效果发动的场合，可以从自己卡组把1只4星以下的名字带有「发条」的怪兽加入手卡。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95714077,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c95714077.thcon)
	e2:SetTarget(c95714077.thtg)
	e2:SetOperation(c95714077.thop)
	c:RegisterEffect(e2)
end
-- 判断发动效果的卡是否为名字带有「发条」的怪兽
function c95714077.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x58)
end
-- 过滤卡组中4星以下、名字带有「发条」且可以加入手牌的怪兽
function c95714077.filter(c)
	return c:IsSetCard(0x58) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 效果发动的目标，确认此卡自身不在当前连锁中且卡组中存在符合条件的卡
function c95714077.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsStatus(STATUS_CHAINING)
		-- 检查自己卡组是否存在至少1张满足过滤条件的卡
		and Duel.IsExistingMatchingCard(c95714077.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果的处理为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理，从卡组将1只符合条件的「发条」怪兽加入手牌并给对方确认
function c95714077.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c95714077.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

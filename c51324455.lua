--魔製産卵床
-- 效果：
-- 自己场上表侧表示存在的鱼族·海龙族·水族怪兽从游戏中除外时才能发动。从自己卡组把1只4星以下的鱼族·海龙族·水族怪兽加入手卡。
function c51324455.initial_effect(c)
	-- 自己场上表侧表示存在的鱼族·海龙族·水族怪兽从游戏中除外时才能发动。从自己卡组把1只4星以下的鱼族·海龙族·水族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(c51324455.condition)
	e1:SetTarget(c51324455.target)
	e1:SetOperation(c51324455.activate)
	c:RegisterEffect(e1)
end
-- 发动条件的筛选函数：判定被除外的怪兽是否满足以下条件——除外前在我方怪兽区表侧表示、除外前控制者是我方，且种族为鱼族、海龙族或水族。
function c51324455.cfilter(c,tp)
	return c:IsFaceup() and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA)
end
-- 发动条件：本次除外事件中至少存在1只满足上述筛选条件的怪兽。
function c51324455.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c51324455.cfilter,1,nil,tp)
end
-- 检索筛选函数：从卡组中选出等级4以下、种族为鱼族/海龙族/水族且能够加入手卡的怪兽。
function c51324455.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA) and c:IsAbleToHand()
end
-- 发动时目标阶段：先检查卡组中是否存在满足检索条件的卡，若存在则设置本次效果处理为从卡组把1张卡加入手卡的检索信息。
function c51324455.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：确认卡组中至少存在1张满足条件的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c51324455.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本次效果将从卡组把1张卡加入手卡，以触发检索/回手牌相关检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段：从卡组选择1张符合条件的怪兽卡加入手卡，并向对方展示，完成检索。
function c51324455.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给操作者显示“请选择要加入手牌的卡”的提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选择1张满足筛选条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c51324455.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的那张卡以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的那张卡，让对方看到检索到的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end

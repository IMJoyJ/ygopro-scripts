--篝火
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只4星以下的炎族怪兽加入手卡。
local s,id,o=GetID()
-- 定义卡片效果的初始化函数，注册魔法卡的发动效果。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只4星以下的炎族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：等级4以下、炎族且可以加入手牌的怪兽。
function s.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_PYRO) and c:IsAbleToHand()
end
-- 效果发动的目标检测与操作信息设置。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检测卡组中是否存在至少1只符合条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果的处理是将卡组的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动的具体处理函数，执行检索并加入手牌的操作。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片进行确认。
		Duel.ConfirmCards(1-tp,g)
	end
end

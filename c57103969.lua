--炎舞－「天璣」
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只4星以下的兽战士族怪兽加入手卡。
-- ②：只要这张卡在魔法与陷阱区域存在，自己场上的兽战士族怪兽的攻击力上升100。
function c57103969.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只4星以下的兽战士族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,57103969+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c57103969.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，自己场上的兽战士族怪兽的攻击力上升100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置永续效果的影响对象为兽战士族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEASTWARRIOR))
	e2:SetValue(100)
	c:RegisterEffect(e2)
end
-- 过滤卡组中等级4以下、种族为兽战士族且可以加入手牌的怪兽
function c57103969.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_BEASTWARRIOR) and c:IsAbleToHand()
end
-- 卡片发动时的效果处理：玩家可以选择是否从卡组将1只4星以下的兽战士族怪兽加入手牌
function c57103969.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足过滤条件的卡片组
	local g=Duel.GetMatchingGroup(c57103969.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的怪兽，则询问玩家是否执行检索效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(57103969,0)) then  --"是否要从卡组把1只4星以下的兽战士族怪兽加入手卡？"
		-- 给玩家发送“请选择要加入手牌的卡”的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡片因效果加入玩家手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手牌的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,sg)
	end
end

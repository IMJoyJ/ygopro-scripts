--サンダー・シーホース
-- 效果：
-- 「雷海马」的效果1回合只能使用1次，这个效果发动的回合，自己不能把怪兽特殊召唤。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把2只攻击力1600以下的雷族·光属性·4星的同名怪兽加入手卡。
function c48049769.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把2只攻击力1600以下的雷族·光属性·4星的同名怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48049769,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,48049769)
	e1:SetCost(c48049769.cost)
	e1:SetTarget(c48049769.target)
	e1:SetOperation(c48049769.operation)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件，包括本回合未进行过特殊召唤且手牌可以丢弃
function c48049769.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：本回合未进行过特殊召唤且手牌可以丢弃
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 and e:GetHandler():IsDiscardable() end
	-- 将自身从手牌丢入墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	-- 创建一个影响当前玩家的永续效果，使其在结束阶段无法特殊召唤怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将该效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义过滤函数，筛选雷族·光属性·4星且攻击力1600以下可加入手牌的怪兽
function c48049769.filter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4) and c:IsAttackBelow(1600) and c:IsAbleToHand()
end
-- 定义辅助过滤函数，用于判断卡组中是否存在同名怪兽
function c48049769.filter1(c,g)
	return g:IsExists(Card.IsCode,1,c,c:GetCode())
end
-- 设置连锁处理的目标阶段，确定检索2只符合条件怪兽的效果
function c48049769.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取满足条件的卡组怪兽集合
		local g=Duel.GetMatchingGroup(c48049769.filter,tp,LOCATION_DECK,0,nil)
		return g:IsExists(c48049769.filter1,1,nil,g)
	end
	-- 设置操作信息，表示将从卡组检索2张符合条件的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 执行效果处理，选择并检索符合条件的2只怪兽加入手牌
function c48049769.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取满足条件的卡组怪兽集合
	local g=Duel.GetMatchingGroup(c48049769.filter,tp,LOCATION_DECK,0,nil)
	local sg=g:Filter(c48049769.filter1,nil,g)
	if sg:GetCount()==0 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local hg=sg:Select(tp,1,1,nil)
	local hc=sg:Filter(Card.IsCode,hg:GetFirst(),hg:GetFirst():GetCode()):GetFirst()
	hg:AddCard(hc)
	-- 将选中的卡加入手牌
	Duel.SendtoHand(hg,nil,REASON_EFFECT)
	-- 向对方确认所选卡牌
	Duel.ConfirmCards(1-tp,hg)
end

--サンダー・シーホース
-- 效果：
-- 「雷海马」的效果1回合只能使用1次，这个效果发动的回合，自己不能把怪兽特殊召唤。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把2只攻击力1600以下的雷族·光属性·4星的同名怪兽加入手卡。
function c48049769.initial_effect(c)
	-- 「雷海马」的效果1回合只能使用1次，这个效果发动的回合，自己不能把怪兽特殊召唤。①：把这张卡从手卡丢弃才能发动。从卡组把2只攻击力1600以下的雷族·光属性·4星的同名怪兽加入手卡。
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
-- 代价处理函数：合法性检查时确认本回合没有特殊召唤过且此卡可丢弃；正式支付时将这张雷海马从手卡丢弃，并以誓约效果给发动玩家附加直到结束阶段不能特殊召唤怪兽的自肃。
function c48049769.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：本回合自己尚未特殊召唤过怪兽（满足自肃发动条件），且手牌中的此卡能以代价丢弃时，才允许发动。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 and e:GetHandler():IsDiscardable() end
	-- 实际支付代价：将效果持有者（手牌中的这张雷海马）以代价+丢弃的原因送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	-- 这个效果发动的回合，自己不能把怪兽特殊召唤。①：把这张卡从手卡丢弃才能发动。从卡组把2只攻击力1600以下的雷族·光属性·4星的同名怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将刚生成的“不能特殊召唤怪兽”的誓约效果注册到决斗中，使该自肃从此刻起对发动玩家生效。
	Duel.RegisterEffect(e1,tp)
end
-- 检索筛选条件：卡片必须为雷族、光属性、4星、攻击力1600以下，且可以加入手卡。
function c48049769.filter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4) and c:IsAttackBelow(1600) and c:IsAbleToHand()
end
-- 同名卡筛选：在候选组中排除自身后，至少还存在1张与当前卡卡号相同的卡，以保证能凑成2张同名卡。
function c48049769.filter1(c,g)
	return g:IsExists(Card.IsCode,1,c,c:GetCode())
end
-- 发动时点检查/登记操作信息：检查卡组中是否存在能凑成同名2张的检索候选；若存在，则登记本连锁为从卡组把2张卡加入手卡。
function c48049769.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得自己卡组中所有满足检索条件（雷族·光属性·4星·攻击力1600以下且可加入手卡）的卡。
		local g=Duel.GetMatchingGroup(c48049769.filter,tp,LOCATION_DECK,0,nil)
		return g:IsExists(c48049769.filter1,1,nil,g)
	end
	-- 登记本次效果的操作信息：效果分类为加入手卡，预定处理2张卡，检索范围为发动玩家的卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从满足条件的候选组中筛选出能凑成同名2张的卡；若为空则直接结束，否则让发动玩家选择1张，自动补上其同名卡组成2张，加入手卡并向对方确认。
function c48049769.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己卡组中所有满足检索条件的候选卡。
	local g=Duel.GetMatchingGroup(c48049769.filter,tp,LOCATION_DECK,0,nil)
	local sg=g:Filter(c48049769.filter1,nil,g)
	if sg:GetCount()==0 then return end
	-- 给出选择提示，让发动玩家从候选卡中选择1张要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local hg=sg:Select(tp,1,1,nil)
	local hc=sg:Filter(Card.IsCode,hg:GetFirst(),hg:GetFirst():GetCode()):GetFirst()
	hg:AddCard(hc)
	-- 将选出的两张同名雷族·光属性·4星·攻击力1600以下的卡加入手卡（送到持有者手卡）。
	Duel.SendtoHand(hg,nil,REASON_EFFECT)
	-- 向对方玩家展示确认加入手卡的两张卡，公开检索结果。
	Duel.ConfirmCards(1-tp,hg)
end

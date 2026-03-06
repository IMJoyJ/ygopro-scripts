--幻煌の都 パシフィス
-- 效果：
-- 这张卡的卡名在规则上当作「海」使用。这张卡的效果发动的回合，自己不能把效果怪兽召唤·特殊召唤。
-- ①：1回合1次，自己对通常怪兽1只的召唤·特殊召唤成功的场合发动。从卡组把1张「幻煌龙」卡加入手卡。
-- ②：自己场上没有衍生物存在，对方把魔法·陷阱·怪兽的效果发动的场合才能发动。在自己场上把1只「幻煌龙衍生物」（幻龙族·水·8星·攻/守2000）特殊召唤。
function c2819435.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：1回合1次，自己对通常怪兽1只的召唤·特殊召唤成功的场合发动。从卡组把1张「幻煌龙」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2819435,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c2819435.thcon)
	e2:SetCost(c2819435.cost)
	e2:SetTarget(c2819435.thtg)
	e2:SetOperation(c2819435.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 效果原文内容：②：自己场上没有衍生物存在，对方把魔法·陷阱·怪兽的效果发动的场合才能发动。在自己场上把1只「幻煌龙衍生物」（幻龙族·水·8星·攻/守2000）特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(2819435,1))  --"衍生物"
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e6:SetCondition(c2819435.spcon)
	e6:SetCost(c2819435.cost)
	e6:SetTarget(c2819435.sptg)
	e6:SetOperation(c2819435.spop)
	c:RegisterEffect(e6)
	-- 规则层面操作：为玩家添加召唤次数计数器，用于限制效果发动回合内不能进行召唤。
	Duel.AddCustomActivityCounter(2819435,ACTIVITY_SUMMON,c2819435.counterfilter)
	-- 规则层面操作：为玩家添加特殊召唤次数计数器，用于限制效果发动回合内不能进行特殊召唤。
	Duel.AddCustomActivityCounter(2819435,ACTIVITY_SPSUMMON,c2819435.counterfilter)
end
-- 规则层面操作：计数器过滤函数，排除拥有效果类型的怪兽。
function c2819435.counterfilter(c)
	return not c:IsType(TYPE_EFFECT)
end
-- 规则层面操作：检查玩家在本回合是否已进行过召唤或特殊召唤，若未进行则允许发动效果。
function c2819435.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查玩家在本回合是否已进行过召唤，若未进行则允许发动效果。
	if chk==0 then return Duel.GetCustomActivityCount(2819435,tp,ACTIVITY_SUMMON)==0
		-- 规则层面操作：检查玩家在本回合是否已进行过特殊召唤，若未进行则允许发动效果。
		and Duel.GetCustomActivityCount(2819435,tp,ACTIVITY_SPSUMMON)==0 end
	-- 效果原文内容：这张卡的效果发动的回合，自己不能把效果怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c2819435.splimit)
	-- 规则层面操作：注册一个使玩家不能进行召唤的效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 规则层面操作：注册一个使玩家不能进行特殊召唤的效果。
	Duel.RegisterEffect(e2,tp)
end
-- 规则层面操作：限制效果函数，禁止召唤拥有效果类型的怪兽。
function c2819435.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsType(TYPE_EFFECT)
end
-- 规则层面操作：条件函数，判断是否为玩家自己通常召唤的通常怪兽。
function c2819435.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:IsSummonPlayer(tp) and tc:IsFaceup() and tc:IsType(TYPE_NORMAL)
end
-- 规则层面操作：检索过滤函数，筛选「幻煌龙」卡。
function c2819435.thfilter(c)
	return c:IsSetCard(0xfa) and c:IsAbleToHand()
end
-- 规则层面操作：设置效果处理信息，准备从卡组检索一张「幻煌龙」卡。
function c2819435.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置操作信息，表示将从卡组检索一张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 规则层面操作：向对方提示“对方选择了：卡组检索”。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 规则层面操作：处理效果发动后，选择并加入手牌一张符合条件的「幻煌龙」卡。
function c2819435.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面操作：从卡组中选择一张符合条件的「幻煌龙」卡。
	local g=Duel.SelectMatchingCard(tp,c2819435.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面操作：向对方确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 规则层面操作：条件函数，判断对方发动效果且自己场上没有衍生物。
function c2819435.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断对方发动效果且自己场上没有衍生物。
	return rp==1-tp and not aux.tkfcon(e,tp)
end
-- 规则层面操作：设置效果处理信息，准备特殊召唤衍生物。
function c2819435.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查玩家是否有足够的召唤区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：检查玩家是否可以特殊召唤衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,2819436,0xfa,TYPES_TOKEN_MONSTER,2000,2000,6,RACE_WYRM,ATTRIBUTE_WATER) end
	-- 规则层面操作：设置操作信息，表示将特殊召唤衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 规则层面操作：设置操作信息，表示将特殊召唤衍生物。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 规则层面操作：向对方提示“对方选择了：衍生物”。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 规则层面操作：处理效果发动后，特殊召唤一只幻煌龙衍生物。
function c2819435.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：检查玩家是否有足够的召唤区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面操作：检查玩家是否可以特殊召唤衍生物。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,2819436,0xfa,TYPES_TOKEN_MONSTER,2000,2000,6,RACE_WYRM,ATTRIBUTE_WATER) then return end
	-- 规则层面操作：创建一只幻煌龙衍生物。
	local token=Duel.CreateToken(tp,2819436)
	-- 规则层面操作：将创建的衍生物特殊召唤到场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end

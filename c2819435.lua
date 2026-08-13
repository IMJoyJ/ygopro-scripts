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
	-- 这张卡的卡名在规则上当作「海」使用。这张卡的效果发动的回合，自己不能把效果怪兽召唤·特殊召唤。①：1回合1次，自己对通常怪兽1只的召唤·特殊召唤成功的场合发动。从卡组把1张「幻煌龙」卡加入手卡。
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
	-- 这张卡的效果发动的回合，自己不能把效果怪兽召唤·特殊召唤。②：自己场上没有衍生物存在，对方把魔法·陷阱·怪兽的效果发动的场合才能发动。在自己场上把1只「幻煌龙衍生物」（幻龙族·水·8星·攻/守2000）特殊召唤。
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
	-- 注册自定义活动计数器（代号2819435，类型为召唤），以counterfilter为过滤条件：当玩家进行召唤操作时，若召唤的怪兽是效果怪兽（filter返回false）则计数加1，用于实现“这张卡的效果发动的回合，自己不能把效果怪兽召唤·特殊召唤”的cost检查。
	Duel.AddCustomActivityCounter(2819435,ACTIVITY_SUMMON,c2819435.counterfilter)
	-- 注册自定义活动计数器（代号2819435，类型为特殊召唤），以counterfilter为过滤条件：当玩家进行特殊召唤操作时，若召唤的怪兽是效果怪兽则计数加1，用于实现“这张卡的效果发动的回合，自己不能把效果怪兽召唤·特殊召唤”的cost检查。
	Duel.AddCustomActivityCounter(2819435,ACTIVITY_SPSUMMON,c2819435.counterfilter)
end
-- 定义计数器过滤函数：若怪兽不是效果怪兽则返回true（不计数），若是效果怪兽则返回false（计数）。因此效果怪兽的召唤/特殊召唤会被记录下来，用于自肃限制。
function c2819435.counterfilter(c)
	return not c:IsType(TYPE_EFFECT)
end
-- cost函数（发动代价检查）：chk==0时，检查本回合自定义计数器中召唤和特殊召唤的计数均为0，即本回合尚未召唤或特殊召唤过效果怪兽，才允许发动本卡效果；否则不满足cost。
function c2819435.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查召唤计数器的计数为0，即本回合未进行过被禁止的效果怪兽的通常召唤（含set）。
	if chk==0 then return Duel.GetCustomActivityCount(2819435,tp,ACTIVITY_SUMMON)==0
		-- 检查特殊召唤计数器的计数为0，即本回合未进行过被禁止的效果怪兽的特殊召唤。
		and Duel.GetCustomActivityCount(2819435,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡的效果发动的回合，自己不能把效果怪兽召唤·特殊召唤。实现方式：给玩家注册禁止普通召唤和特殊召唤效果怪兽的限制效果（splimit指定只限制效果怪兽），持续到回合结束；同时包含后面各子函数，其中thcon等为①效果，spcon等为②效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c2819435.splimit)
	-- 将禁止召唤效果怪兽的限制效果e1注册到场上，对当前玩家tp生效，使其不能通常召唤效果怪兽。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	-- 将禁止特殊召唤效果怪兽的限制效果e2注册到场上，对当前玩家tp生效，使其不能特殊召唤效果怪兽。
	Duel.RegisterEffect(e2,tp)
end
-- 定义限制效果的过滤条件：只禁止效果怪兽（TYPE_EFFECT），非效果怪兽不受影响。
function c2819435.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsType(TYPE_EFFECT)
end
-- 效果①的触发条件：本次召唤/特殊召唤成功的怪兽只有1只、是由本方tp玩家召唤、表侧表示、并且是通常怪兽（TYPE_NORMAL）。
function c2819435.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:IsSummonPlayer(tp) and tc:IsFaceup() and tc:IsType(TYPE_NORMAL)
end
-- 效果①的检索过滤器：该卡属于「幻煌龙」系列（setcode 0xfa），且能够加入手牌。
function c2819435.thfilter(c)
	return c:IsSetCard(0xfa) and c:IsAbleToHand()
end
-- 效果①发动时的目标处理：chk==0时直接允许发动；设置操作信息为从卡组将1张卡加入手牌，并向对方提示发动了该效果。
function c2819435.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果将把1张卡从卡组加入持有者手牌（处理时确定具体卡片）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 向对方玩家（1-tp）提示：我方发动了该效果，并显示效果的描述文字。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①处理：提示玩家选择要加入手牌的卡，从卡组选择1张满足条件的「幻煌龙」卡，加入手牌并让对方确认。
function c2819435.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息，内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张满足thfilter（「幻煌龙」系列且能加入手牌）的卡。
	local g=Duel.SelectMatchingCard(tp,c2819435.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的触发条件：本连锁的效果是由对方玩家发起的（rp==1-tp），并且自己场上没有衍生物存在。
function c2819435.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断条件：效果发动者是对方，且自己场上不存在衍生物（aux.tkfcon为真表示存在衍生物，取反后满足“没有衍生物”）。
	return rp==1-tp and not aux.tkfcon(e,tp)
end
-- 效果②发动时的目标处理：检查自己主怪兽区有空位，且玩家能够特殊召唤指定的幻煌龙衍生物，满足则允许发动。
function c2819435.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家tp能否特殊召唤参数指定的衍生物（卡号2819436，幻龙族·水属性·攻击力/守备力2000·等级6·衍生物类型）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,2819436,0xfa,TYPES_TOKEN_MONSTER,2000,2000,6,RACE_WYRM,ATTRIBUTE_WATER) end
	-- 设置操作信息：本次效果将生成1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次效果将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 向对方玩家提示：我方发动了效果②（衍生物特殊召唤）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果②处理：若仍有空位且仍可特殊召唤，则创建幻煌龙衍生物并特殊召唤到自己场上表侧表示。
function c2819435.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己的主怪兽区域没有空位，则效果处理不执行（特殊召唤失败）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 若玩家当前已经不能特殊召唤该衍生物，则效果处理不执行。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,2819436,0xfa,TYPES_TOKEN_MONSTER,2000,2000,6,RACE_WYRM,ATTRIBUTE_WATER) then return end
	-- 创建1只幻煌龙衍生物（卡号2819436），持有者和控制者均为tp。
	local token=Duel.CreateToken(tp,2819436)
	-- 将衍生物以表侧攻击表示特殊召唤到tp的场上（sumtype=0，不检查召唤条件、不检查苏生限制）。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end

--光の波動
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己准备阶段，自己的场地区域没有「光之结界」存在的场合发动。进行1次投掷硬币，里出现的场合，这张卡的②③的效果直到下次的自己准备阶段无效化。
-- ②：自己场上的天使族怪兽的攻击力·守备力上升300。
-- ③：丢弃1张手卡才能发动。把2只卡名不同的「秘仪之力」怪兽从卡组加入手卡。这个回合，自己不是「秘仪之力」怪兽不能特殊召唤。
local s,id,o=GetID()
-- 注册本卡的全部效果：①准备阶段硬币无效化的诱发效果、②己方天使族怪兽攻击力/守备力提升的永续效果、③丢弃手卡检索秘仪之力怪兽并附加自肃的起动效果，以及作为永续魔法卡发动所需的ACTIVATE空效果。
function s.initial_effect(c)
	-- 将73206827（「光之结界」）登记到本卡的关联卡名列表中，用于处理效果中提及「光之结界」的判定与文本显示。
	aux.AddCodeList(c,73206827)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对应①：“自己准备阶段，自己的场地区域没有「光之结界」存在的场合发动。进行1次投掷硬币，里出现的场合，这张卡的②③的效果直到下次的自己准备阶段无效化。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"掷硬币"
	e2:SetCategory(CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 对应②：“自己场上的天使族怪兽的攻击力·守备力上升300。”（此处先实现攻击力提升部分）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.upcon)
	-- 设置②效果的适用对象为持有者自己场上表侧表示的天使族怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FAIRY))
	e3:SetValue(300)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 对应③：“丢弃1张手卡才能发动。把2只卡名不同的「秘仪之力」怪兽从卡组加入手卡。这个回合，自己不是「秘仪之力」怪兽不能特殊召唤。”
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,id)
	e5:SetCost(s.thcost)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
s.toss_coin=true
-- ①效果的发动条件：自己的准备阶段，且自己场地区域没有「光之结界」存在的场合才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是自己，并且以自己视角的场地区域不存在卡号73206827的「光之结界」。
	return Duel.GetTurnPlayer()==tp and not Duel.IsEnvironment(73206827,tp,LOCATION_FZONE)
end
-- ①效果的发动目标：无取对象，仅在发动时设置投硬币的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为“投硬币”，由玩家tp投掷1次，供其他卡牌连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- ①效果的实际处理：进行1次投掷硬币；若为反面，则给本卡挂上无效化标志，使其②③效果在下次自己的准备阶段之前无效。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让玩家tp投1次硬币，coin返回1为正面、0为反面。
	local coin=Duel.TossCoin(tp,1)
	if coin==0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_CLIENT_HINT,3,0,aux.Stringid(id,3))  --"①的效果（这张卡的②③的效果直到下次的自己准备阶段无效化）适用中"
	end
end
-- ②效果（攻击力/守备力提升）的适用条件：本卡没有因①的硬币反面效果被赋予无效化标志。
function s.upcon(e,c)
	return e:GetHandler():GetFlagEffect(id)==0
end
-- ③效果的发动代价：从手卡丢弃1张卡（cost）。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：确认自己手卡中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行cost：从自己手卡选择1张可以丢弃的卡，以cost+丢弃的原因送入墓地。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ③效果的检索过滤条件：卡名属于「秘仪之力」系列、是怪兽、且可以被加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x5) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ③效果的发动目标：检查卡组中是否存在至少2只卡名不同的符合条件的「秘仪之力」怪兽，并设置检索2张加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己卡组中所有满足条件的「秘仪之力」怪兽卡，用于发动合法性判断。
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置当前连锁的操作信息为“从卡组加入手卡”，预计数量为2，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- ③效果处理：若本卡带有①的无效化标志则取消本次效果；否则从卡组选择2只卡名不同的「秘仪之力」怪兽加入手卡，给对方确认并洗切手卡；最后给自己附加本回合不能特殊召唤非「秘仪之力」怪兽的自肃。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)~=0 then
		-- 将当前连锁的最末尾效果无效化（0表示当前连锁），用于被①的无效化标志抵消③效果的情况。
		Duel.NegateEffect(0)
		return
	end
	-- 实际处理时重新取得卡组中所有符合条件的「秘仪之力」怪兽，供玩家选择。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 then
		-- 给玩家tp显示“请选择要加入手牌的卡”的提示，作为检索选择界面的消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从符合条件的卡组中选择2张卡名互不相同的「秘仪之力」怪兽（dncheck用于保证卡名不同）。
		local tg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选中的卡以效果原因送去其持有者的手卡。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 让对方玩家确认被加入手卡的2张卡。
		Duel.ConfirmCards(1-tp,tg)
		-- 检索加入手卡后洗切自己玩家的手卡，使手卡顺序随机化。
		Duel.ShuffleHand(tp)
	end
	-- 对应③的最后一句：“这个回合，自己不是「秘仪之力」怪兽不能特殊召唤。”
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能特殊召唤非秘仪之力怪兽”的玩家自肃效果注册给当前玩家tp，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定函数：若尝试特殊召唤的怪兽不是「秘仪之力」系列，则禁止该特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x5)
end

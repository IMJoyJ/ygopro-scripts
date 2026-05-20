--炎傑の梁山閣
-- 效果：
-- 这个卡名在规则上也当作「炎舞」卡使用。
-- ①：每次「炎星」怪兽召唤·特殊召唤给这张卡放置1个炎星指示物。
-- ②：1回合1次，可以把自己场上的炎星指示物的以下数量取除，那个效果发动。
-- ●2：这个回合，自己的兽战士族怪兽攻击的场合，对方直到伤害步骤结束时卡的效果不能发动。
-- ●6：从卡组把1只兽战士族怪兽加入手卡。
-- ●10：从卡组·额外卡组把1只兽战士族怪兽无视召唤条件特殊召唤。
function c66750703.initial_effect(c)
	c:EnableCounterPermit(0x56)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次「炎星」怪兽召唤·特殊召唤给这张卡放置1个炎星指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(c66750703.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ●2：这个回合，自己的兽战士族怪兽攻击的场合，对方直到伤害步骤结束时卡的效果不能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(66750703,0))  --"2个：效果限制"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCost(c66750703.actcost)
	e4:SetOperation(c66750703.actop)
	c:RegisterEffect(e4)
	-- ●6：从卡组把1只兽战士族怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(66750703,1))  --"6个：卡组检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e5:SetCost(c66750703.thcost)
	e5:SetTarget(c66750703.thtg)
	e5:SetOperation(c66750703.thop)
	c:RegisterEffect(e5)
	-- ●10：从卡组·额外卡组把1只兽战士族怪兽无视召唤条件特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(66750703,2))  --"10个：特殊召唤"
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e6:SetCost(c66750703.spcost)
	e6:SetTarget(c66750703.sptg)
	e6:SetOperation(c66750703.spop)
	c:RegisterEffect(e6)
end
-- 过滤条件：场上表侧表示的「炎星」怪兽
function c66750703.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x79)
end
-- 召唤·特殊召唤成功时，给这张卡放置1个炎星指示物
function c66750703.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c66750703.ctfilter,1,nil) then
		e:GetHandler():AddCounter(0x56,1)
	end
end
-- 2个指示物效果的发动代价：移除场上2个炎星指示物
function c66750703.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能移除2个炎星指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x56,2,REASON_COST) end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 移除自己场上的2个炎星指示物
	Duel.RemoveCounter(tp,1,0,0x56,2,REASON_COST)
end
-- 2个指示物效果的处理：注册一个直到回合结束适用的全局效果，使对方在己方兽战士族怪兽攻击时不能发动卡的效果
function c66750703.actop(e,tp,eg,ep,ev,re,r,rp)
	-- ②：1回合1次，可以把自己场上的炎星指示物的以下数量取除，那个效果发动。●2：这个回合，自己的兽战士族怪兽攻击的场合，对方直到伤害步骤结束时卡的效果不能发动。●6：从卡组把1只兽战士族怪兽加入手卡。●10：从卡组·额外卡组把1只兽战士族怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c66750703.actcon)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制对方发动效果的永续效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制对方发动效果的条件：进行攻击的怪兽是己方场上的兽战士族怪兽
function c66750703.actcon(e)
	-- 获取当前进行攻击的怪兽
	local tc=Duel.GetAttacker()
	local tp=e:GetHandlerPlayer()
	return tc and tc:IsControler(tp) and tc:IsRace(RACE_BEASTWARRIOR)
end
-- 6个指示物效果的发动代价：移除场上6个炎星指示物
function c66750703.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能移除6个炎星指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x56,6,REASON_COST) end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 移除自己场上的6个炎星指示物
	Duel.RemoveCounter(tp,1,0,0x56,6,REASON_COST)
end
-- 过滤条件：卡组中可以加入手卡的兽战士族怪兽
function c66750703.thfilter(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 6个指示物效果的发动准备：检查卡组中是否存在可检索的兽战士族怪兽，并设置检索的操作信息
function c66750703.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c66750703.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 6个指示物效果的处理：从卡组选择1只兽战士族怪兽加入手卡，并给对方确认
function c66750703.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息为“加入手牌”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c66750703.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 10个指示物效果的发动代价：移除场上10个炎星指示物
function c66750703.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能移除10个炎星指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x56,10,REASON_COST) end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 移除自己场上的10个炎星指示物
	Duel.RemoveCounter(tp,1,0,0x56,10,REASON_COST)
end
-- 过滤条件：可以无视召唤条件特殊召唤的兽战士族怪兽，且其出场位置有可用的怪兽区域
function c66750703.spfilter(c,e,tp)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 若卡在卡组，则检查主怪兽区是否有空位
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若卡在额外卡组，则检查额外怪兽区或相关连接区是否有空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 10个指示物效果的发动准备：检查卡组或额外卡组是否存在可特殊召唤的兽战士族怪兽，并设置特殊召唤的操作信息
function c66750703.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组中是否存在至少1张满足特殊召唤过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c66750703.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组或额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 10个指示物效果的处理：从卡组或额外卡组选择1只兽战士族怪兽，无视召唤条件特殊召唤
function c66750703.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息为“特殊召唤”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或额外卡组中选择1张满足特殊召唤过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c66750703.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end

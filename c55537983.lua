--ミミグル・マスター
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「迷拟宝箱鬼·领主」以外的1只「迷拟宝箱鬼」怪兽加入手卡。
-- ②：自己场上有「迷拟宝箱鬼·领主」以外的「迷拟宝箱鬼」怪兽存在的场合或者对方场上有里侧表示怪兽存在的场合，场上的这张卡不会被战斗·效果破坏。
-- ③：对方主要阶段才能发动。场上1只里侧表示怪兽变成表侧攻击表示或表侧守备表示。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含战破/效破抗性、召唤/特召成功时检索同名卡以外的「迷拟宝箱鬼」怪兽、以及对方主要阶段改变场上里侧怪兽表示形式的效果。
function s.initial_effect(c)
	-- ②：自己场上有「迷拟宝箱鬼·领主」以外的「迷拟宝箱鬼」怪兽存在的场合或者对方场上有里侧表示怪兽存在的场合，场上的这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	e1:SetCondition(s.indescon)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「迷拟宝箱鬼·领主」以外的1只「迷拟宝箱鬼」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ③：对方主要阶段才能发动。场上1只里侧表示怪兽变成表侧攻击表示或表侧守备表示。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"改变表示形式"
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+o)
	e5:SetCondition(s.poscon)
	e5:SetTarget(s.postg)
	e5:SetOperation(s.posop)
	c:RegisterEffect(e5)
end
-- 过滤条件：自己场上表侧表示的「迷拟宝箱鬼·领主」以外的「迷拟宝箱鬼」怪兽。
function s.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x1b7) and not c:IsCode(id)
end
-- 过滤条件：里侧表示的卡。
function s.cfilter2(c)
	return c:IsFacedown()
end
-- 破坏抗性效果的启用条件：自己场上有其他「迷拟宝箱鬼」怪兽存在，或者对方场上有里侧表示怪兽存在。
function s.indescon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在「迷拟宝箱鬼·领主」以外的表侧表示「迷拟宝箱鬼」怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 或者检查对方场上是否存在里侧表示怪兽。
		or Duel.IsExistingMatchingCard(s.cfilter2,tp,0,LOCATION_MZONE,1,nil)
end
-- 过滤条件：卡组中「迷拟宝箱鬼·领主」以外的、可以加入手牌的「迷拟宝箱鬼」怪兽。
function s.thfilter(c)
	return c:IsSetCard(0x1b7) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 检索效果的靶向/发动准备函数，检查卡组中是否存在可检索的怪兽，并向对方提示发动效果，设置检索的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动了“检索”效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))  --"检索"
	-- 设置操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，让玩家从卡组选择1只满足条件的「迷拟宝箱鬼」怪兽加入手牌并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 改变表示形式效果的发动条件：对方回合的主要阶段。
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段。
	local ph=Duel.GetCurrentPhase()
	-- 检查当前是否为对方回合的主要阶段1或主要阶段2。
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤条件：场上里侧守备表示的怪兽。
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFacedown() and c:IsDefensePos()
end
-- 改变表示形式效果的靶向/发动准备函数，检查场上是否存在里侧守备表示怪兽，并向对方提示发动效果，设置改变表示形式的操作信息。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的里侧守备表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示发动了“改变表示形式”效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))  --"改变表示形式"
	-- 设置操作信息：改变1张卡的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- 改变表示形式效果的处理函数，让玩家选择场上1只里侧守备表示怪兽，并选择将其变为表侧攻击表示或表侧守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息为“请选择要改变表示形式的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择场上1只满足条件的里侧守备表示怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 选中该怪兽并显示选中动画。
		Duel.HintSelection(g)
		-- 让玩家选择该怪兽变为表侧攻击表示或表侧守备表示。
		local pos=Duel.SelectPosition(tp,tc,POS_FACEUP)
		-- 改变该怪兽的表示形式为玩家选择的形式。
		Duel.ChangePosition(tc,pos)
	end
end

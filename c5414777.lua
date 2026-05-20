--精霊の世界
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②③的效果若非自己场上有7星以上的龙族·光属性同调怪兽存在的场合则不能发动。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把有「古代妖精龙」的卡名记述的1只怪兽加入手卡。
-- ②：每次怪兽攻击表示特殊召唤发动。那些怪兽变成守备表示。
-- ③：自己·对方的结束阶段发动。回合玩家的场上的攻击表示怪兽全部破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片的发动（效果①）、特殊召唤时变守备表示（效果②）以及结束阶段破坏攻击表示怪兽（效果③）的效果注册。
function s.initial_effect(c)
	-- 将「古代妖精龙」的卡片密码（25862681）加入该卡的关联卡片列表中。
	aux.AddCodeList(c,25862681)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把有「古代妖精龙」的卡名记述的1只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：每次怪兽攻击表示特殊召唤发动。那些怪兽变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变成守备表示"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.poscon)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	-- ③：自己·对方的结束阶段发动。回合玩家的场上的攻击表示怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选出卡组中记述有「古代妖精龙」卡名的怪兽。
function s.filter(c)
	-- 检查卡片是否记述有「古代妖精龙」卡名、是否为怪兽卡以及是否能加入手卡。
	return aux.IsCodeListed(c,25862681) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①（卡片发动时效果处理）的执行函数，让玩家选择是否从卡组检索1只记述有「古代妖精龙」卡名的怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足过滤条件的卡片组。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 如果卡组中存在满足条件的卡，则询问玩家是否将其加入手卡。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把卡加入手卡？"
		-- 给玩家发送提示信息，提示选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡因效果加入玩家手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 效果②的触发条件：检查特殊召唤的怪兽中是否存在表侧攻击表示的怪兽。
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPosition,1,nil,POS_FACEUP_ATTACK)
end
-- 过滤函数：筛选出表侧攻击表示的怪兽。
function s.posfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
-- 效果②的靶向/发动检测函数，检查自己场上是否存在7星以上的龙族·光属性同调怪兽，并设置改变表示形式的操作信息。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果②的发动条件检测：若非自己场上有7星以上的龙族·光属性同调怪兽存在的场合则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.acfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end
	local g=eg:Filter(s.posfilter,nil)
	-- 将需要改变表示形式的怪兽设置为效果处理的对象。
	Duel.SetTargetCard(g)
	-- 设置连锁的操作信息，表示此效果将改变指定数量怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果②的执行函数，将特殊召唤的攻击表示怪兽变成守备表示。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中与此效果相关的目标怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将目标怪兽的表示形式改变为守备表示。
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE)
	end
end
-- 效果③的靶向/发动检测函数，检查自己场上是否存在7星以上的龙族·光属性同调怪兽，并设置破坏回合玩家场上所有攻击表示怪兽的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果③的发动条件检测：若非自己场上有7星以上的龙族·光属性同调怪兽存在的场合则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.acfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end
	-- 获取当前回合玩家场上的所有攻击表示怪兽。
	local g=Duel.GetFieldGroup(Duel.GetTurnPlayer(),LOCATION_MZONE,0):Filter(Card.IsPosition,nil,POS_ATTACK)
	-- 设置连锁的操作信息，表示此效果将破坏回合玩家场上的所有攻击表示怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果③的执行函数，破坏回合玩家场上的所有攻击表示怪兽。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取当前回合玩家场上的所有攻击表示怪兽。
	local g=Duel.GetFieldGroup(Duel.GetTurnPlayer(),LOCATION_MZONE,0):Filter(Card.IsPosition,nil,POS_ATTACK)
	-- 因效果破坏这些怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 过滤函数：筛选出自己场上表侧表示的7星以上的龙族·光属性同调怪兽（用于②③效果的发动条件检测）。
function s.acfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevelAbove(7)
end

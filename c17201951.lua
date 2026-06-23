--フルスピード・ウォリアー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。把1只「废品同调士」或者1张有「废品战士」的卡名记述的魔法·陷阱卡从卡组加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己场上的以下怪兽的攻击力只在自己战斗阶段内上升900。
-- ●有「废品战士」的卡名记述的怪兽
-- ●原本卡名包含「战士」的同调怪兽
local s,id,o=GetID()
-- 初始化效果函数，注册三个效果：①检索效果、②召唤/特殊召唤时触发的检索效果、③场上的攻击力提升效果
function s.initial_effect(c)
	-- 记录该卡效果文本上记载着「废品同调士」和「废品战士」的卡名
	aux.AddCodeList(c,63977008,60800381)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。把1只「废品同调士」或者1张有「废品战士」的卡名记述的魔法·陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己场上的以下怪兽的攻击力只在自己战斗阶段内上升900。●有「废品战士」的卡名记述的怪兽●原本卡名包含「战士」的同调怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetValue(900)
	c:RegisterEffect(e3)
end
-- 检索过滤函数，用于筛选满足条件的魔法/陷阱卡或废品同调士
function s.thfilter(c)
	-- 筛选条件：卡名记载有「废品战士」且为魔法/陷阱卡，或卡名为「废品同调士」，并且可以送去手牌
	return (aux.IsCodeListed(c,60800381) and c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsCode(63977008)) and c:IsAbleToHand()
end
-- 检索效果的发动条件判断函数，检查卡组中是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，提示选择卡并执行检索操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 攻击力提升效果的触发条件函数，判断是否处于自己的战斗阶段
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的战斗阶段
	return Duel.IsBattlePhase() and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 攻击力提升效果的目标筛选函数，判断目标怪兽是否满足提升条件
function s.atktg(e,c)
	-- 判断目标怪兽是否记载有「废品战士」或原本卡名包含「战士」的同调怪兽
	return aux.IsCodeListed(c,60800381) or c:IsOriginalSetCard(0x66) and c:IsType(TYPE_SYNCHRO)
end

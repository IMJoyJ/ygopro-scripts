--フルスピード・ウォリアー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。把1只「废品同调士」或者1张有「废品战士」的卡名记述的魔法·陷阱卡从卡组加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己场上的以下怪兽的攻击力只在自己战斗阶段内上升900。
-- ●有「废品战士」的卡名记述的怪兽
-- ●原本卡名包含「战士」的同调怪兽
local s,id,o=GetID()
-- 定义卡片的初始效果注册函数：注册①检索效果（召唤/特殊召唤时检索「废品同调士」或记载「废品战士」的魔法陷阱卡）和②永续攻击力上升效果（自己战斗阶段满足条件的怪兽攻击力上升900）。
function s.initial_effect(c)
	-- 将「废品同调士」(63977008)和「废品战士」(60800381)登记为本卡效果文本记载的卡名，供后续IsCodeListed判断“有「废品战士」卡名记述”等条件使用。
	aux.AddCodeList(c,63977008,60800381)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。把1只「废品同调士」或者1张有「废品战士」的卡名记述的魔法·陷阱卡从卡组加入手卡。
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
	-- ②：只要这张卡在怪兽区域存在，自己场上的以下怪兽的攻击力只在自己战斗阶段内上升900。●有「废品战士」的卡名记述的怪兽 ●原本卡名包含「战士」的同调怪兽
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
-- 定义①效果检索用的卡片过滤器：筛选卡组中满足“是「废品同调士」，或是效果文本记载了「废品战士」的魔法·陷阱卡”，并且能够加入手卡的卡。
function s.thfilter(c)
	-- 过滤条件为：该卡是「废品同调士」(63977008)，或者该卡是效果文本记载了「废品战士」(60800381)的魔法·陷阱卡；同时该卡可以被加入手卡。
	return (aux.IsCodeListed(c,60800381) and c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsCode(63977008)) and c:IsAbleToHand()
end
-- 定义①效果的发动条件与操作信息：效果发动时检查卡组是否存在符合条件的检索目标，并设置本次连锁将进行“从卡组加入手卡”的操作。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：若自己卡组中存在至少1张满足s.thfilter的卡，则①效果满足发动条件，可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次处理的效果分类为加入手卡（并附带检索），预计从卡组将1张卡加入手卡；因为处理时再选择卡，所以目标暂设为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义①效果处理时的操作：发动玩家从卡组选择1张符合条件的卡加入手卡，并让对方确认加入手卡的卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家显示选择提示：“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让发动玩家从自己卡组中选出1张满足s.thfilter的卡（若存在多张则只能选1张）。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡以效果原因送去其持有者的手卡，即从卡组加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示刚刚加入手卡的卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②攻击力上升效果的适用条件：只在战斗阶段且是“自己”的战斗阶段（当前回合玩家为本卡控制者）时，该效果才适用。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为战斗阶段，并且当前回合玩家是本卡的控制者，即“自己战斗阶段”条件。
	return Duel.IsBattlePhase() and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 定义②效果适用的怪兽对象筛选函数：自己场上存在的、效果文本记载了「废品战士」的怪兽，或者原本卡名包含「战士」的同调怪兽，可获得攻击力上升。
function s.atktg(e,c)
	-- 怪兽满足以下任一条件即可：效果文本记载了「废品战士」(60800381)；或者原本卡名包含「战士」字段且是同调怪兽。
	return aux.IsCodeListed(c,60800381) or c:IsOriginalSetCard(0x66) and c:IsType(TYPE_SYNCHRO)
end

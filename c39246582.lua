--ファーニマル・ドッグ
-- 效果：
-- 「毛绒动物·狗」的效果1回合只能使用1次。
-- ①：这张卡从手卡的召唤·特殊召唤成功时才能发动。从卡组把1只「锋利小鬼·剪刀」或者1只「毛绒动物·狗」以外的「毛绒动物」怪兽加入手卡。
function c39246582.initial_effect(c)
	-- 「毛绒动物·狗」的效果1回合只能使用1次。①：这张卡从手卡的召唤·特殊召唤成功时才能发动。从卡组把1只「锋利小鬼·剪刀」或者1只「毛绒动物·狗」以外的「毛绒动物」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39246582,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,39246582)
	e1:SetCondition(c39246582.thcon)
	e1:SetTarget(c39246582.thtg)
	e1:SetOperation(c39246582.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 发动条件判定：效果持有者（这张卡）在召唤或特殊召唤成功之前必须位于手牌，即必须是从手卡的召唤·特殊召唤成功时才能发动。
function c39246582.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 检索过滤条件：满足以下条件之一的卡才能被检索——卡名是「锋利小鬼·剪刀」；或者属于「毛绒动物」字段、是怪兽卡、且不是「毛绒动物·狗」自身，同时该卡能够加入手卡。
function c39246582.filter(c)
	return (c:IsCode(30068120) or (c:IsSetCard(0xa9) and c:IsType(TYPE_MONSTER) and not c:IsCode(39246582)))
		and c:IsAbleToHand()
end
-- 效果发动时的目标设定：在发动时先确认卡组中是否存在满足条件的卡；若存在，则设置本次操作是将1张卡从卡组加入手卡的信息。
function c39246582.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定阶段（chk==0）检查卡组中是否存在至少1张满足检索条件的卡；若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c39246582.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将把1张卡（所属位置为卡组，持有者为操作者tp）加入手卡，供后续相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的操作：让操作者从卡组选择1张符合条件的「锋利小鬼·剪刀」或「毛绒动物」怪兽加入手卡，若有选择则加入手卡并向对方展示。
function c39246582.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者弹出“请选择要加入手牌的卡”的选择提示，供后续选择卡片时显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从操作者自己的卡组中选择1张满足检索条件的卡（不取对象，在处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c39246582.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示被检索加入手卡的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end

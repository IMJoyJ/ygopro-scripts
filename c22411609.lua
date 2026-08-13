--ヴォルカニック・トルーパー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「火山骑兵」以外的1张「火山」卡加入手卡。
-- ②：丢弃1张手卡才能发动。在对方场上把1只「炸弹衍生物」（炎族·炎·1星·攻/守1000）特殊召唤。这衍生物被破坏时那个控制者受到500伤害。
function c22411609.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「火山骑兵」以外的1张「火山」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22411609,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,22411609)
	e1:SetTarget(c22411609.thtg)
	e1:SetOperation(c22411609.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：丢弃1张手卡才能发动。在对方场上把1只「炸弹衍生物」（炎族·炎·1星·攻/守1000）特殊召唤。这衍生物被破坏时那个控制者受到500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22411609,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,22411610)
	e3:SetCost(c22411609.tkcost)
	e3:SetTarget(c22411609.tktg)
	e3:SetOperation(c22411609.tkop)
	c:RegisterEffect(e3)
end
-- 检索的过滤条件：筛选卡组中满足「火山」字段、不是「火山骑兵」本身且能够加入手卡的卡。
function c22411609.thfilter(c)
	return c:IsSetCard(0x32) and not c:IsCode(22411609) and c:IsAbleToHand()
end
-- ①效果的发动目标判定：检查卡组中是否存在满足条件的「火山」卡，并设置本次效果将进行“从卡组加入手卡”的操作信息。
function c22411609.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果合法性检查：确认卡组中存在至少1张满足检索条件的「火山」卡（非「火山骑兵」本身且可加入手卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(c22411609.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，标明本效果为从卡组检索并加入手卡，且预计处理1张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：让发动者从卡组选出1张符合条件的「火山」卡加入手卡，并向对方展示。
function c22411609.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示“请选择要加入手牌的卡”，引导玩家进行卡片选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「火山」卡（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c22411609.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「火山」卡加入其持有者的手卡，原因为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动代价：丢弃1张手卡；先检查是否有可丢弃的手卡，再执行丢弃作为代价。
function c22411609.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认手卡中存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手卡，作为发动②效果的代价（原因同时为COST和DISCARD）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ②效果的目标合法性判定：检查对方主要怪兽区是否有空位，且自己能否在对方场上特殊召唤「炸弹衍生物」（炎族·炎·1星·攻/守1000）。
function c22411609.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方主要怪兽区是否存在可用格子（从发动者视角来看对方场上的空格数要大于0）。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 检查自己是否能够在对方场上以表侧表示特殊召唤「炸弹衍生物」（满足其种族、属性、等级、攻守等参数要求）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,22411610,0,TYPES_TOKEN_MONSTER,1000,1000,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP,1-tp) end
	-- 设置操作信息：本效果涉及衍生物的生成。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本效果涉及特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②效果处理：在对方场上特殊召唤1只「炸弹衍生物」，并给该衍生物注册“被破坏时其控制者受到500伤害”的持续效果。
function c22411609.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认对方主要怪兽区仍有空位，若没有格子则效果不处理。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<=0 then return end
	-- 效果处理时再次确认自己仍能特殊召唤该衍生物到对方场上，若不能则效果不处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,22411610,0,TYPES_TOKEN_MONSTER,1000,1000,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP,1-tp) then return end
	-- 创建1只「炸弹衍生物」的衍生物卡。
	local token=Duel.CreateToken(tp,22411610)
	-- 以分步特殊召唤方式将「炸弹衍生物」以表侧表示特殊召唤到对方场上。
	if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP) then
		-- 这衍生物被破坏时那个控制者受到500伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetOperation(c22411609.damop)
		token:RegisterEffect(e1,true)
	end
	-- 完成分步特殊召唤流程，触发特殊召唤成功时的相关时点。
	Duel.SpecialSummonComplete()
end
-- 衍生物的离场伤害效果：若该衍生物因破坏而离场，则给予其离场前的控制者500点效果伤害；效果处理完毕后自行重置。
function c22411609.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 给予该衍生物被破坏前的控制者500点效果伤害，伤害原因为效果。
		Duel.Damage(c:GetPreviousControler(),500,REASON_EFFECT)
	end
	e:Reset()
end

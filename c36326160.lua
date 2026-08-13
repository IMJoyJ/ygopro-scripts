--Live☆Twin キスキル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，若自己场上没有其他怪兽存在则能发动。从手卡·卡组把1只「璃拉」怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，每次对方怪兽攻击宣言，自己回复500基本分。
function c36326160.initial_effect(c)
	-- 对应①效果：‘这张卡召唤·特殊召唤的场合，若自己场上没有其他怪兽存在则能发动。从手卡·卡组把1只“璃拉”怪兽特殊召唤。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36326160,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e1:SetCountLimit(1,36326160)
	e1:SetCondition(c36326160.spcon)
	e1:SetTarget(c36326160.sptg)
	e1:SetOperation(c36326160.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 对应②效果：‘只要这张卡在怪兽区域存在，每次对方怪兽攻击宣言，自己回复500基本分。’
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c36326160.reccon)
	e3:SetOperation(c36326160.recop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件检测：判断自己场上没有其他怪兽存在（场上怪兽区只有本卡自己）。
function c36326160.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己场上怪兽区怪兽数量是否为1（即场上除本卡外无其他怪兽）。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==1
end
-- 筛选满足特殊召唤条件的「璃拉」怪兽：属于0x153系列且能被当前效果特殊召唤。
function c36326160.spfilter(c,e,tp)
	return c:IsSetCard(0x153) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动时的目标处理：发动时点确认是否有空位和可特殊召唤的「璃拉」怪兽，并设置操作信息。
function c36326160.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查自己场上是否有至少1个可用怪兽区域空格，否则效果不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时点检查手牌·卡组中是否存在至少1只满足spfilter条件的「璃拉」怪兽。
		and Duel.IsExistingMatchingCard(c36326160.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：本次效果为特殊召唤，将从手牌·卡组特殊召唤1只怪兽，具体对象在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果处理时的操作：确认仍有空位后，提示选择，从手牌·卡组选1只「璃拉」怪兽并特殊召唤。
function c36326160.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查可用怪兽区，若无空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示信息，用于后续选择卡牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌·卡组中选择1张满足spfilter条件的「璃拉」怪兽。
	local g=Duel.SelectMatchingCard(tp,c36326160.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上（原控制者不变，并正常检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件判断：当前攻击宣言怪兽的控制者不是自己，即对方怪兽攻击宣言。
function c36326160.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回攻击怪兽的控制者不是本卡控制者tp，以此判定为对方怪兽的攻击。
	return Duel.GetAttacker():GetControler()~=tp
end
-- ②效果处理时的操作：展示本卡发动动画，然后使自己回复500基本分。
function c36326160.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示本卡（36326160）的发动动画，用于不入连锁的回复LP效果提示。
	Duel.Hint(HINT_CARD,0,36326160)
	-- 使自己回复500基本分，回复原因记为效果（REASON_EFFECT）。
	Duel.Recover(tp,500,REASON_EFFECT)
end

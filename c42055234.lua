--ドラゴンメイド・フランメ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「半龙女仆」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升2000。
-- ②：只要自己场上有融合怪兽存在，这张卡不会被效果破坏。
-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只3星「半龙女仆」怪兽特殊召唤。
function c42055234.initial_effect(c)
	-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「半龙女仆」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升2000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42055234,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,42055234)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置①效果的发动条件，使用aux.dscon限制该效果只能在伤害步骤的伤害计算前或非伤害步骤时发动（不能在伤害计算后发动）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c42055234.atkcost)
	e1:SetTarget(c42055234.atktg)
	e1:SetOperation(c42055234.atkop)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有融合怪兽存在，这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c42055234.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只3星「半龙女仆」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42055234,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,42055235)
	e3:SetTarget(c42055234.sptg)
	e3:SetOperation(c42055234.spop)
	c:RegisterEffect(e3)
end
-- 定义①效果的代价函数：发动前必须把这张卡从手卡丢弃；chk==0时检查这张卡是否可以被丢弃。
function c42055234.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 实际执行代价：把这张卡从手卡送去墓地，丢弃原因为COST+REASON_DISCARD。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 定义①效果可选择的对象的过滤条件：表侧表示且是「半龙女仆」（0x133）怪兽。
function c42055234.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x133)
end
-- 定义①效果的发动时选择对象的处理：检查对象合法性、是否存在对象，并让玩家选择自己场上1只表侧「半龙女仆」怪兽。
function c42055234.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42055234.atkfilter(chkc) end
	-- 在效果发动时检查自己场上是否存在至少1只符合条件的表侧「半龙女仆」怪兽，若存在才可发动。
	if chk==0 then return Duel.IsExistingTarget(c42055234.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送选择提示消息，提示选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只符合条件的表侧「半龙女仆」怪兽，并将其设为效果对象。
	Duel.SelectTarget(tp,c42055234.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义①效果处理函数：取得对象，若对象仍表侧且与效果相关，则赋予其攻击力上升2000直到回合结束。
function c42055234.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升2000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 定义②效果条件的过滤函数：表侧表示且是融合怪兽。
function c42055234.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 定义②效果的发动条件：自己场上有表侧表示的融合怪兽存在。
function c42055234.indcon(e)
	-- 检查自己场上是否存在至少1只表侧融合怪兽，若存在则②效果适用。
	return Duel.IsExistingMatchingCard(c42055234.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 定义③效果中可特殊召唤的怪兽过滤条件：手卡中的「半龙女仆」（0x133）且等级为3，并且可以被特殊召唤。
function c42055234.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义③效果的发动条件：这张卡能够返回手卡，返回后自己场上有空位，且手卡中存在符合条件的3星「半龙女仆」怪兽。
function c42055234.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 额外检查：这张卡离开场上返回手卡后，自己场上仍有可用的怪兽区空格。
		and Duel.GetMZoneCount(tp,c)>0
		-- 额外检查：手卡中存在至少1只符合条件的3星「半龙女仆」怪兽可以特殊召唤。
		and Duel.IsExistingMatchingCard(c42055234.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果预计将这张卡返回手卡，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置操作信息：本次效果预计从手卡特殊召唤1只怪兽（目标为自己，位置为手卡）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义③效果处理：若这张卡仍与效果相关且成功返回手卡，并确认已回到手卡且场上有空位，则从手卡选择1只符合条件的3星「半龙女仆」怪兽特殊召唤。
function c42055234.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡与效果仍有关联，并实际将其返回手卡；只有成功返回（返回值不为0）才继续处理。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 确认这张卡已经回到手卡，且自己场上存在可用的怪兽区空格后才继续特殊召唤。
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 给玩家发送选择提示消息，提示选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡中选择1只符合条件的3星「半龙女仆」怪兽。
		local g=Duel.SelectMatchingCard(tp,c42055234.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的那只怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

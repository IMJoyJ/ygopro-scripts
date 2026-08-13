--サイバース・コンバーター
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上的怪兽只有电子界族怪兽的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤成功时，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的种族直到回合结束时变成电子界族。
function c14505685.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上的怪兽只有电子界族怪兽的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,14505685+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c14505685.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤成功时，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的种族直到回合结束时变成电子界族。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14505685,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c14505685.rctg)
	e2:SetOperation(c14505685.rcop)
	c:RegisterEffect(e2)
end
-- 筛选函数：选出里侧表示或不是电子界族的怪兽，用于判断自己场上是否存在不符合“只有电子界族怪兽”条件的怪兽。
function c14505685.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_CYBERSE)
end
-- ①特殊召唤规则的条件函数：检查这张卡是否可以通过①规则从手卡特殊召唤，要求自己主要怪兽区有空位、自己场上有怪兽、且自己场上的怪兽全部为表侧电子界族。
function c14505685.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查控制者主要怪兽区是否有空位，用于决定能否从手卡特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查控制者场上是否存在至少1只怪兽，满足“自己场上有怪兽”的前提。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查场上不存在里侧表示或非电子界族的怪兽，从而确保自己场上的怪兽只有电子界族怪兽。
		and not Duel.IsExistingMatchingCard(c14505685.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 筛选函数：选出自己场上表侧表示且不是电子界族的怪兽，作为②效果可选的对象。
function c14505685.rcfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_CYBERSE)
end
-- ②效果的发动条件和选对象处理：确认自己场上有表侧表示且非电子界族的怪兽可选，然后提示玩家选择1只作为对象。
function c14505685.rctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14505685.rcfilter(chkc) end
	-- 效果发动判定：当为发动确认阶段时，检查是否存在满足条件的对象。
	if chk==0 then return Duel.IsExistingTarget(c14505685.rcfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 发送选择提示信息，让玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 执行对象选择：从自己场上选出1只表侧表示且非电子界族的怪兽作为效果对象。
	Duel.SelectTarget(tp,c14505685.rcfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：取得对象卡，若对象仍表侧且与效果关联，则对其赋予“种族变成电子界族”的效果，持续到回合结束。
function c14505685.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的种族直到回合结束时变成电子界族。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_CYBERSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

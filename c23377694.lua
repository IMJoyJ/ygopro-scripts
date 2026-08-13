--EMオオヤヤドカリ
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，自己的「娱乐伙伴」怪兽被战斗破坏时，以自己的灵摆区域1张「娱乐伙伴」卡或者「异色眼」卡为对象才能发动。那张卡特殊召唤。
-- 【怪兽效果】
-- ①：1回合1次，以自己场上1只灵摆怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升自己场上的「娱乐伙伴」怪兽数量×300。
function c23377694.initial_effect(c)
	-- 为这张灵摆怪兽卡添加灵摆怪兽共同属性（可进行灵摆召唤、灵摆卡发动等）。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只灵摆怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升自己场上的「娱乐伙伴」怪兽数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c23377694.atktg)
	e1:SetOperation(c23377694.atkop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己的「娱乐伙伴」怪兽被战斗破坏时，以自己的灵摆区域1张「娱乐伙伴」卡或者「异色眼」卡为对象才能发动。那张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c23377694.spcon)
	e2:SetTarget(c23377694.sptg)
	e2:SetOperation(c23377694.spop)
	c:RegisterEffect(e2)
end
-- 筛选条件：卡为表侧表示且是灵摆怪兽（用于选择攻击力上升效果的对象）。
function c23377694.filter1(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 起动效果的目标处理：确认存在可选对象时，从自己场上选择1只表侧表示灵摆怪兽作为对象（取对象）。
function c23377694.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c23377694.filter1(chkc) end
	-- 效果发动合法性检查：自己场上不存在表侧表示灵摆怪兽时，该效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c23377694.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示：请选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 实际选择1只自己场上的表侧表示灵摆怪兽，并将其注册为效果对象。
	Duel.SelectTarget(tp,c23377694.filter1,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 筛选条件：表侧表示且属于「娱乐伙伴」系列，用于计算攻击力上升的数量。
function c23377694.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 效果处理：计算自己场上表侧表示「娱乐伙伴」怪兽数量×300，为对象怪兽附加直到回合结束的攻击力上升效果。
function c23377694.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 统计自己场上表侧表示「娱乐伙伴」怪兽的数量，作为攻击力上升的倍数。
	local ct=Duel.GetMatchingGroupCount(c23377694.filter2,tp,LOCATION_MZONE,0,nil)
	if ct>0 and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升自己场上的「娱乐伙伴」怪兽数量×300。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 筛选条件：被战斗破坏的怪兽属于「娱乐伙伴」系列，且其上一个控制者是自己。
function c23377694.cfilter(c,tp)
	return c:IsSetCard(0x9f) and c:IsPreviousControler(tp)
end
-- 发动条件：本次战斗破坏的事件中存在1只以上自己的「娱乐伙伴」怪兽被战斗破坏。
function c23377694.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23377694.cfilter,1,nil,tp)
end
-- 筛选条件：位于灵摆区域、属于「娱乐伙伴」或「异色眼」系列、且可以被特殊召唤。
function c23377694.spfilter(c,e,tp)
	return c:IsSetCard(0x9f,0x99) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 灵摆效果的目标处理：从自己的灵摆区域选择1张可特殊召唤的「娱乐伙伴」或「异色眼」卡为对象，并登记特殊召唤操作信息。
function c23377694.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_PZONE) and c23377694.spfilter(chkc,e,tp) end
	-- 效果发动合法性检查：灵摆区域不存在符合条件的卡时，该效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c23377694.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己灵摆区域选择1张符合条件的卡，并将其注册为效果对象。
	local g=Duel.SelectTarget(tp,c23377694.spfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	-- 登记操作信息：此次效果将特殊召唤1张对象卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若对象卡仍与效果关联，则将其特殊召唤到自己场上。
function c23377694.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得灵摆效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

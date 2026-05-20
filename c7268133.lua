--EMライフ・ソードマン
-- 效果：
-- ①：对方基本分回复时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的攻击力变成和这个时候对方回复的数值相同。
-- ②：把这张卡解放，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。
function c7268133.initial_effect(c)
	-- ①：对方基本分回复时才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的攻击力变成和这个时候对方回复的数值相同。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_RECOVER)
	e1:SetCondition(c7268133.spcon)
	e1:SetTarget(c7268133.sptg)
	e1:SetOperation(c7268133.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c7268133.atkcost)
	e2:SetTarget(c7268133.atktg)
	e2:SetOperation(c7268133.atkop)
	c:RegisterEffect(e2)
end
-- 判定回复生命值的玩家是否为对方（发动条件）
function c7268133.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果①的发动准备与合法性检测（检查怪兽区域是否有空位以及自身是否能特殊召唤）
function c7268133.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的处理信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（将自身特殊召唤，并使其攻击力变成与对方回复数值相同）
function c7268133.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将自身以表侧表示特殊召唤
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡的攻击力变成和这个时候对方回复的数值相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 效果②的发动代价处理（检查并解放自身）
function c7268133.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果②的对象选择与合法性检测（选择自己场上1只表侧表示怪兽为对象）
function c7268133.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在除自身以外的表侧表示怪兽可以作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 给玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的效果处理（使作为对象的怪兽攻击力直到回合结束时上升1000）
function c7268133.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 那只怪兽的攻击力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end

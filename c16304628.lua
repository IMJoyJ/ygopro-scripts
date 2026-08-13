--E・HERO ガイア
-- 效果：
-- 「元素英雄」怪兽＋地属性怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡融合召唤成功的场合，以对方场上1只表侧表示怪兽为对象发动。直到回合结束时，那只怪兽的攻击力变成一半，这张卡的攻击力上升那个数值。
function c16304628.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：以1只「元素英雄」怪兽和1只地属性怪兽作为融合素材进行融合召唤。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x3008),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_EARTH),true)
	-- ①：这张卡融合召唤成功的场合，以对方场上1只表侧表示怪兽为对象发动。直到回合结束时，那只怪兽的攻击力变成一半，这张卡的攻击力上升那个数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16304628,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c16304628.atkcon)
	e2:SetTarget(c16304628.atktg)
	e2:SetOperation(c16304628.atkop)
	c:RegisterEffect(e2)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设定特殊召唤条件的效果值：只有通过融合召唤才能特殊召唤，限制其他特殊召唤方式。
	e3:SetValue(aux.fuslimit)
	c:RegisterEffect(e3)
end
c16304628.material_setcode=0x8
-- 判断触发条件：这张卡是否是以融合召唤的方式特殊召唤成功。
function c16304628.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果发动时的对象指定处理：从对方场上选择1只表侧表示怪兽作为对象，并设置操作信息。
function c16304628.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 向操作者显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作者从对方场上选择1只表侧表示怪兽作为效果对象（取对象效果），并将所选卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果处理涉及攻击力变化，对象为所选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,g:GetCount(),0,0)
end
-- 效果处理：将对象怪兽的攻击力变成一半，并使这张卡的攻击力上升那个数值（向上取整），同时检查各卡是否仍合法。
function c16304628.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		local atk=tc:GetAttack()
		-- 直到回合结束时，那只怪兽的攻击力变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 这张卡的攻击力上升那个数值。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(math.ceil(atk/2))
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e2)
		end
	end
end

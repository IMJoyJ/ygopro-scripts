--E・HERO ガイア
-- 效果：
-- 「元素英雄」怪兽＋地属性怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡融合召唤成功的场合，以对方场上1只表侧表示怪兽为对象发动。直到回合结束时，那只怪兽的攻击力变成一半，这张卡的攻击力上升那个数值。
function c16304628.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用1只「元素英雄」怪兽和1只地属性怪兽作为融合素材
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
	-- 设置该卡的特殊召唤方式必须为融合召唤
	e3:SetValue(aux.fuslimit)
	c:RegisterEffect(e3)
end
c16304628.material_setcode=0x8
-- 效果发动时判断此卡是否为融合召唤方式特殊召唤
function c16304628.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 选择对方场上1只表侧表示的怪兽作为效果对象
function c16304628.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return true end
	-- 提示玩家选择对方场上1只表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，确定将要改变攻击力的怪兽
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,g:GetCount(),0,0)
end
-- 处理效果，将目标怪兽的攻击力减半，并使自身攻击力上升相同数值
function c16304628.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中指定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		local atk=tc:GetAttack()
		-- 使目标怪兽的攻击力变为原来的一半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 使自身攻击力上升目标怪兽攻击力的一半
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

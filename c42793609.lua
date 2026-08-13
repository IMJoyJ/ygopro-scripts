--極星宝ブリージンガ・メン
-- 效果：
-- 选择自己以及对方场上表侧表示存在的怪兽各1只发动。选择的自己怪兽的攻击力直到结束阶段时变成和选择的对方怪兽的原本攻击力相同攻击力。
function c42793609.initial_effect(c)
	-- 选择自己以及对方场上表侧表示存在的怪兽各1只发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置伤害步骤条件限制，使该卡只能在非伤害步骤或伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c42793609.target)
	e1:SetOperation(c42793609.operation)
	c:RegisterEffect(e1)
end
-- 目标函数：在系统进行单卡对象合法性检查时直接返回false（因需同时选择双方怪兽），并在发动时检查双方场上是否各有表侧表示怪兽可作为对象。
function c42793609.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件判断：检查己方场上是否存在至少1只表侧表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		-- 发动条件判断：检查对方场上是否存在至少1只表侧表示怪兽可以作为效果对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择自己场上的表侧表示怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 从自己场上选择1只表侧表示怪兽作为效果对象，并将其记录在效果的LabelObject中以便后续处理。
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择对方场上的表侧表示怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 从对方场上选择1只表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数：获取连锁对象并检查对象是否仍然合法（未里侧表示且与效果保持关联），否则不处理。
function c42793609.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁所选择的两只对象怪兽（自己场上和对方场上各一只）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	local sc=g:GetNext()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e)
		or sc:IsFacedown() or not sc:IsRelateToEffect(e) then return end
	local ac=e:GetLabelObject()
	if tc==ac then tc=sc end
	local atk=tc:GetBaseAttack()
	-- 选择的自己怪兽的攻击力直到结束阶段时变成和选择的对方怪兽的原本攻击力相同攻击力。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	ac:RegisterEffect(e1)
end

--封魔の伝承者
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，宣言和自己墓地存在的「封魔之传承者」同数目的属性。这张卡对宣言属性的怪兽进行攻击的场合，不进行伤害计算直接破坏那只怪兽。
function c15595052.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，宣言和自己墓地存在的「封魔之传承者」同数目的属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15595052,0))  --"宣言属性"
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c15595052.ancop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 处理召唤成功时的诱发效果：统计自己墓地中「封魔之传承者」的数量，若存在且本卡仍在场上表侧表示，则宣言对应数量的属性，并为本卡附加对宣言属性怪兽的战斗破坏效果。
function c15595052.ancop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 统计自己墓地中卡号为15595052的「封魔之传承者」数量，作为需要宣言的属性数目。
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,15595052)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 向玩家发送选择属性的提示信息，准备进行属性宣言。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
		-- 让玩家从全部属性中宣言与墓地同名卡数量相同数目的属性，并返回宣言的属性组合值。
		local att=Duel.AnnounceAttribute(tp,ct,ATTRIBUTE_ALL)
		e:GetHandler():SetHint(CHINT_ATTRIBUTE,att)
		-- 这张卡对宣言属性的怪兽进行攻击的场合，不进行伤害计算直接破坏那只怪兽。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(15595052,1))  --"破坏"
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetTarget(c15595052.destg)
		e1:SetOperation(c15595052.desop)
		e1:SetLabel(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 破坏效果的发动条件：本卡是攻击怪兽，攻击对象存在且表侧表示，并且其属性等于之前宣言的属性；满足时即为可发动状态。
function c15595052.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前战斗中的攻击对象（被攻击的怪兽），不存在则为nil。
	local bc=Duel.GetAttackTarget()
	-- 效果发动判定：仅当本卡是攻击怪兽、攻击对象为表侧表示且属性与所宣言属性一致时才允许发动。
	if chk==0 then return c==Duel.GetAttacker() and bc and bc:IsFaceup() and bc:IsAttribute(e:GetLabel()) end
	-- 设置操作信息：预定将攻击对象破坏，数量为1，使该效果被认定为破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 破坏处理：若攻击对象仍与本次战斗关联且表侧表示，则将其破坏。
function c15595052.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的攻击对象，用于处理时确认要破坏的怪兽。
	local bc=Duel.GetAttackTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
		-- 以效果原因破坏攻击对象，达成不进行伤害计算直接破坏的效果。
		Duel.Destroy(bc,REASON_EFFECT)
	end
end

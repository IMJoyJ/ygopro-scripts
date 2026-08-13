--トリックスター・ホーリーエンジェル
-- 效果：
-- 「淘气仙星」怪兽2只
-- ①：只要这张卡在怪兽区域存在，每次这张卡所连接区有「淘气仙星」怪兽召唤·特殊召唤，给与对方200伤害。
-- ②：这张卡所连接区的「淘气仙星」怪兽不会被战斗·效果破坏。
-- ③：每次「淘气仙星」怪兽的效果让对方受到伤害发动。这张卡的攻击力直到回合结束时上升那次伤害的数值。
function c32448765.initial_effect(c)
	-- 为这张卡添加连接召唤手续：素材为2只「淘气仙星」系列连接怪兽（卡名含有0xfb字段的连接怪兽）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfb),2,2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，每次这张卡所连接区有「淘气仙星」怪兽召唤·特殊召唤，给与对方200伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c32448765.damcon)
	e1:SetOperation(c32448765.damop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡所连接区的「淘气仙星」怪兽不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c32448765.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
	-- ③：每次「淘气仙星」怪兽的效果让对方受到伤害发动。这张卡的攻击力直到回合结束时上升那次伤害的数值。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(32448765,0))  --"上升攻击力"
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_DAMAGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c32448765.atkcon)
	e5:SetOperation(c32448765.atkop)
	c:RegisterEffect(e5)
end
-- 过滤函数：判断怪兽是否属于这张卡所连接区的「淘气仙星」怪兽；若仍在场上则要求表侧表示且位于连接区，若已离场则根据离场前的位置与连接区对应关系进行判定。
function c32448765.cfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsSetCard(0xfb) and c:IsFaceup() and ec:GetLinkedGroup():IsContains(c)
	else
		return c:IsPreviousSetCard(0xfb) and c:IsPreviousPosition(POS_FACEUP)
			and bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- 触发条件：本次召唤/特殊召唤成功的怪兽中存在至少1只满足连接区「淘气仙星」判定条件的怪兽。
function c32448765.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c32448765.cfilter,1,nil,e:GetHandler())
end
-- 效果处理：展示本卡发动动画，并给与对方玩家200点效果伤害。
function c32448765.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示卡号32448765的卡片发动动画，提示该卡效果已发动。
	Duel.Hint(HINT_CARD,0,32448765)
	-- 给与对方玩家（1-tp）200点效果伤害。
	Duel.Damage(1-tp,200,REASON_EFFECT)
end
-- ②的效果对象判定：若该怪兽是「淘气仙星」系列且位于这张卡的连接区，则适用不会被战斗或效果破坏的保护。
function c32448765.indtg(e,c)
	return c:IsSetCard(0xfb) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- ③的触发条件：对方受到效果伤害，且该伤害是由「淘气仙星」怪兽的效果造成的（伤害原因为效果，效果来源为怪兽且属于0xfb系列）。
function c32448765.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and bit.band(r,REASON_EFFECT)~=0 and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0xfb)
end
-- 攻击力上升处理：若本卡仍表侧表示且与效果关联，则给本卡注册一个攻击力上升效果，上升值为本次对方受到的伤害数值，持续到回合结束。
function c32448765.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升那次伤害的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

--トリックスター・ホーリーエンジェル
-- 效果：
-- 「淘气仙星」怪兽2只
-- ①：只要这张卡在怪兽区域存在，每次这张卡所连接区有「淘气仙星」怪兽召唤·特殊召唤，给与对方200伤害。
-- ②：这张卡所连接区的「淘气仙星」怪兽不会被战斗·效果破坏。
-- ③：每次「淘气仙星」怪兽的效果让对方受到伤害发动。这张卡的攻击力直到回合结束时上升那次伤害的数值。
function c32448765.initial_effect(c)
	-- 添加连接召唤手续，要求使用2只以上属于「淘气仙星」的怪兽作为连接素材
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
-- 用于判断召唤或特殊召唤的怪兽是否在该卡的连接区且属于「淘气仙星」
function c32448765.cfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsSetCard(0xfb) and c:IsFaceup() and ec:GetLinkedGroup():IsContains(c)
	else
		return c:IsPreviousSetCard(0xfb) and c:IsPreviousPosition(POS_FACEUP)
			and bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- 判断是否有满足条件的怪兽被召唤或特殊召唤
function c32448765.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c32448765.cfilter,1,nil,e:GetHandler())
end
-- 对对方造成200伤害
function c32448765.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示该卡发动的动画提示
	Duel.Hint(HINT_CARD,0,32448765)
	-- 对对方造成200伤害
	Duel.Damage(1-tp,200,REASON_EFFECT)
end
-- 判断目标怪兽是否在该卡的连接区且属于「淘气仙星」
function c32448765.indtg(e,c)
	return c:IsSetCard(0xfb) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 判断伤害是否由「淘气仙星」怪兽的效果造成且为对方受到
function c32448765.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and bit.band(r,REASON_EFFECT)~=0 and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0xfb)
end
-- 使该卡的攻击力上升对应伤害数值
function c32448765.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 为该卡添加攻击力上升效果，持续到回合结束
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ev)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

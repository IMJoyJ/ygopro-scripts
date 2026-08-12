--ハーピィズペット幻竜
-- 效果：
-- 风属性4星怪兽×3
-- 这张卡的效果若这张卡的超量素材没有则不适用。这张卡可以直接攻击对方玩家。只要这张卡在场上表侧表示存在，对方不能把名字带有「鹰身」的怪兽作为攻击对象，也不能作为卡的效果的对象。每次自己的结束阶段把这张卡1个超量素材取除。
function c85909450.initial_effect(c)
	-- 添加XYZ召唤手续：风属性4星怪兽×3
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND),4,3)
	c:EnableReviveLimit()
	-- 这张卡的效果若这张卡的超量素材没有则不适用。这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c85909450.effcon)
	c:RegisterEffect(e1)
	-- 这张卡的效果若这张卡的超量素材没有则不适用。只要这张卡在场上表侧表示存在，对方不能把名字带有「鹰身」的怪兽作为攻击对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c85909450.effcon)
	e2:SetValue(c85909450.atlimit)
	c:RegisterEffect(e2)
	-- 这张卡的效果若这张卡的超量素材没有则不适用。只要这张卡在场上表侧表示存在，对方不能把名字带有「鹰身」的怪兽作为卡的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c85909450.efftg)
	e3:SetCondition(c85909450.effcon)
	-- 设置不能成为对方卡的效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 每次自己的结束阶段把这张卡1个超量素材取除。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(85909450,0))  --"取除素材"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c85909450.rmcon)
	e4:SetOperation(c85909450.rmop)
	c:RegisterEffect(e4)
end
-- 效果适用条件：这张卡拥有超量素材
function c85909450.effcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 过滤效果对象：名字带有「鹰身」的怪兽
function c85909450.efftg(e,c)
	return c:IsSetCard(0x64) and c:IsType(TYPE_MONSTER)
end
-- 过滤攻击对象：表侧表示存在且名字带有「鹰身」的怪兽
function c85909450.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x64)
end
-- 取除素材效果的发动条件：自己的结束阶段
function c85909450.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 取除素材效果的执行操作：取除这张卡的1个超量素材
function c85909450.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetOverlayCount()>0 then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end

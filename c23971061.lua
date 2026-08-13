--ダブルバイト・ドラゴン
-- 效果：
-- 连接怪兽2只
-- ①：这张卡的攻击力上升作为这张卡的连接素材的怪兽的连接标记合计×300。
-- ②：这张卡只要在怪兽区域存在，不受连接怪兽以外的怪兽的效果影响，不会被和连接怪兽以外的怪兽的战斗破坏。
function c23971061.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：必须且只能用2只连接怪兽作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_LINK),2,2)
	-- ①：这张卡的攻击力上升作为这张卡的连接素材的怪兽的连接标记合计×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c23971061.atkcon)
	e1:SetOperation(c23971061.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡只要在怪兽区域存在，不受连接怪兽以外的怪兽的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(c23971061.efilter)
	c:RegisterEffect(e2)
	-- 不会被和连接怪兽以外的怪兽的战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(c23971061.indval)
	c:RegisterEffect(e3)
end
-- 检查此卡是否以连接召唤方式成功特殊召唤；仅当通过连接召唤出场时，加攻效果才触发。
function c23971061.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果处理时，获取此卡连接召唤所用的素材怪兽，累计所有素材的连接标记数量，将攻击力上升该数量×300。
function c23971061.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	local atk=0
	local tc=g:GetFirst()
	while tc do
		local lk=tc:GetLink()
		atk=atk+lk
		tc=g:GetNext()
	end
	-- ①：这张卡的攻击力上升作为这张卡的连接素材的怪兽的连接标记合计×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk*300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 对将要作用于这张卡的效果进行过滤：该效果必须是怪兽卡效果，且该效果的持有者不是连接怪兽时，此卡不受影响；也就是只免疫非连接怪兽的怪兽效果。
function c23971061.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and not te:GetOwner():IsType(TYPE_LINK)
end
-- 对战斗对象进行判定：战斗对象不是连接怪兽时，此卡不会被那次战斗破坏。
function c23971061.indval(e,c)
	return not c:IsType(TYPE_LINK)
end

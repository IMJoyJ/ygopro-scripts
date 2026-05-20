--マジック・キャンセラー
-- 效果：
-- 只要这张卡在场上表侧表示存在，魔法卡不能发动，场上所有魔法卡的效果无效化。
function c84636823.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，魔法卡不能发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c84636823.aclimit)
	c:RegisterEffect(e1)
	-- 场上所有魔法卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e2:SetTarget(c84636823.distg)
	c:RegisterEffect(e2)
	-- 场上所有魔法卡的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c84636823.disop)
	c:RegisterEffect(e3)
end
-- 定义限制发动效果的过滤条件，限制在场上发动的魔法卡效果或魔法卡本身的发动
function c84636823.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL) and (re:GetHandler():IsOnField() or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 定义无效效果的目标过滤条件，筛选场上魔陷区中属于魔法卡的卡片
function c84636823.distg(e,c)
	return c:IsType(TYPE_SPELL)
end
-- 在连锁处理时，若触发效果的卡片在魔陷区且为魔法卡，则无效该连锁的效果
function c84636823.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁的发动位置
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if bit.band(tl,LOCATION_SZONE)~=0 and re:IsActiveType(TYPE_SPELL) then
		-- 无效当前正在处理的连锁的效果
		Duel.NegateEffect(ev)
	end
end

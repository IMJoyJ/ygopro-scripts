--カオス・マジシャン
-- 效果：
-- ①：只要这张卡在怪兽区域存在，只以这1张卡为对象的怪兽的效果无效化。
function c72630549.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，只以这1张卡为对象的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c72630549.distg)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，只以这1张卡为对象的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c72630549.disop)
	c:RegisterEffect(e2)
end
-- 过滤并确定被无效的怪兽：仅以这张卡为唯一永续对象的怪兽
function c72630549.distg(e,c)
	if c:GetCardTargetCount()~=1 then return false end
	return c:GetFirstCardTarget()==e:GetHandler()
end
-- 在连锁处理时，判断发动的怪兽效果是否仅以这张卡为唯一对象，若是则将其无效
function c72630549.disop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_EFFECT) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前正在处理的连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return end
	if g:GetFirst()==e:GetHandler() then
		-- 使当前正在处理的连锁的效果无效
		Duel.NegateEffect(ev)
	end
end

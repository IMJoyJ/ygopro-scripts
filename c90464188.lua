--黒曜岩竜
-- 效果：
-- 只要这张卡在场上表侧表示存在，自己场上表侧表示存在的1只暗属性怪兽为对象的魔法·陷阱卡的效果无效并破坏。
function c90464188.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，自己场上表侧表示存在的1只暗属性怪兽为对象的魔法·陷阱卡的效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c90464188.distg)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，自己场上表侧表示存在的1只暗属性怪兽为对象的魔法·陷阱卡的效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c90464188.disop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，自己场上表侧表示存在的1只暗属性怪兽为对象的魔法·陷阱卡的效果无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e3:SetTarget(c90464188.distg)
	c:RegisterEffect(e3)
end
-- 过滤出当前有指向对象，且其对象中存在自己场上表侧表示暗属性怪兽的魔法·陷阱卡
function c90464188.distg(e,c)
	if c:GetCardTargetCount()==0 then return false end
	return c:GetCardTarget():IsExists(c90464188.disfilter,1,nil,e:GetHandlerPlayer())
end
-- 检查卡片是否为自己场上表侧表示存在的暗属性怪兽
function c90464188.disfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 在连锁处理时，若该连锁是魔法·陷阱卡且以自己场上表侧表示暗属性怪兽为对象，则将其效果无效并破坏
function c90464188.disop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前正在处理的连锁的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()==0 then return end
	if g:IsExists(c90464188.disfilter,1,nil,tp) then
		-- 若成功使该连锁的效果无效，且该卡仍与该效果相关联
		if Duel.NegateEffect(ev,true) and re:GetHandler():IsRelateToEffect(re) then
			-- 将该魔法·陷阱卡破坏
			Duel.Destroy(re:GetHandler(),REASON_EFFECT)
		end
	end
end

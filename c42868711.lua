--幻影のゴラ亀
-- 效果：
-- 以场上表侧表示的这张卡为对象的，由对方所控制的魔法·陷阱卡的效果无效。
function c42868711.initial_effect(c)
	-- 以场上表侧表示的这张卡为对象的，由对方所控制的魔法·陷阱卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c42868711.distg)
	c:RegisterEffect(e1)
	-- 以场上表侧表示的这张卡为对象的，由对方所控制的魔法·陷阱卡的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c42868711.disop)
	c:RegisterEffect(e2)
	-- 以场上表侧表示的这张卡为对象的，由对方所控制的魔法·陷阱卡的效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e3:SetTarget(c42868711.distg)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选出由对方控制的、且以这张卡为对象的魔法·陷阱卡，作为被无效/赋予自毁效果的目标。
function c42868711.distg(e,c)
	return c:GetControler()~=e:GetHandlerPlayer() and c:IsHasCardTarget(e:GetHandler())
end
-- 在连锁处理时，若对方发动的是取对象的魔法·陷阱卡且其对象包含这张卡，则无效该连锁，并在该魔法·陷阱卡仍与该连锁关联时将其破坏。
function c42868711.disop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not e:GetHandler():IsRelateToEffect(re) then return end
	-- 获取当前连锁中发动效果所选择的取对象卡片组，用于判断这张卡是否被选为对象。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()==0 then return end
	if g:IsContains(e:GetHandler()) then
		-- 尝试无效该连锁效果；若无效成功且发动效果的那张魔法·陷阱卡仍与该连锁关联，则继续执行破坏。
		if Duel.NegateEffect(ev,true) and re:GetHandler():IsRelateToEffect(re) then
			-- 以效果为原因，将发动效果的对方魔法·陷阱卡破坏。
			Duel.Destroy(re:GetHandler(),REASON_EFFECT)
		end
	end
end

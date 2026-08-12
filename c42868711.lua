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
-- 判断目标卡片是否为对方控制且被这张卡作为对象
function c42868711.distg(e,c)
	return c:GetControler()~=e:GetHandlerPlayer() and c:IsHasCardTarget(e:GetHandler())
end
-- 连锁处理时检查是否为对方的魔法或陷阱效果，且该效果有对象，若对象包含此卡则无效该效果并破坏效果来源
function c42868711.disop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not e:GetHandler():IsRelateToEffect(re) then return end
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()==0 then return end
	if g:IsContains(e:GetHandler()) then
		-- 使当前连锁效果无效并判断效果来源是否有效
		if Duel.NegateEffect(ev,true) and re:GetHandler():IsRelateToEffect(re) then
			-- 破坏该效果的来源卡片
			Duel.Destroy(re:GetHandler(),REASON_EFFECT)
		end
	end
end

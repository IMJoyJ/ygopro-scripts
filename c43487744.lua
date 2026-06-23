--ホワイト・ホール
-- 效果：
-- 对方把「黑洞」发动时才能发动。自己场上存在的怪兽不会被那张「黑洞」的效果破坏。
function c43487744.initial_effect(c)
	-- 效果发动时，对方把「黑洞」发动时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c43487744.condition)
	e1:SetOperation(c43487744.activate)
	c:RegisterEffect(e1)
end
-- 检查连锁是否为对方发动的魔法或陷阱卡，且卡号为黑洞（53129443）
function c43487744.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(53129443)
end
-- 创建一个永续效果，使自己场上怪兽不会被该连锁效果破坏
function c43487744.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 注册一个影响我方怪兽区的永续效果，使其不会被特定连锁效果破坏
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetValue(c43487744.indval)
	e1:SetReset(RESET_CHAIN)
	e1:SetLabel(cid)
	-- 将效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断当前连锁ID是否与效果标签中的ID一致
function c43487744.indval(e,re,rp)
	-- 若当前连锁ID等于效果标签ID，则该效果生效
	return Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==e:GetLabel()
end

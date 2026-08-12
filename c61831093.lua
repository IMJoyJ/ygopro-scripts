--ドッペルゲンガー
-- 效果：
-- 反转：选择场上盖放的2张魔法·陷阱卡破坏。
function c61831093.initial_effect(c)
	-- 反转：选择场上盖放的2张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61831093,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c61831093.target)
	e1:SetOperation(c61831093.operation)
	c:RegisterEffect(e1)
end
-- 过滤场上里侧表示且可以成为效果对象的卡片
function c61831093.filter(c,e)
	return c:IsFacedown() and c:IsCanBeEffectTarget(e)
end
-- 效果发动的对象选择与准备阶段，处理取对象逻辑，若场上盖放的魔陷不足2张则不取对象
function c61831093.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c61831093.filter(chkc,e) end
	if chk==0 then return true end
	-- 获取双方魔陷区所有满足过滤条件的里侧表示卡片组
	local g=Duel.GetMatchingGroup(c61831093.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil,e)
	if g:GetCount()<2 then
		g:Clear()
		-- 将空卡片组设为效果处理的对象（用于处理数量不足2张时无法选择对象的情况）
		Duel.SetTargetCard(g)
		return
	end
	-- 给玩家发送选择要破坏的卡片的提示消息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:Select(tp,2,2,nil)
	-- 将玩家选择的2张卡片设为当前连锁的对象
	Duel.SetTargetCard(sg)
	-- 设置当前连锁的操作信息为破坏这2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,2,0,0)
end
-- 过滤出仍与该效果有关联且依然是里侧表示的卡片
function c61831093.dfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFacedown()
end
-- 效果处理阶段，获取对象卡片并破坏其中仍为里侧表示的卡
function c61831093.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg then return end
	local dg=tg:Filter(c61831093.dfilter,nil,e)
	-- 因效果破坏满足条件的卡片
	Duel.Destroy(dg,REASON_EFFECT)
end

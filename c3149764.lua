--ツタン仮面
-- 效果：
-- 场上表侧表示存在的1只不死族怪兽为对象的魔法·陷阱卡的发动无效并破坏。
function c3149764.initial_effect(c)
	-- 场上表侧表示存在的1只不死族怪兽为对象的魔法·陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c3149764.condition)
	e1:SetTarget(c3149764.target)
	e1:SetOperation(c3149764.activate)
	c:RegisterEffect(e1)
end
-- 筛选位于怪兽区域且表侧表示、种族为不死族的怪兽。
function c3149764.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 本卡的发动条件：仅当任一玩家发动以场上表侧表示存在的1只不死族怪兽为对象的魔法·陷阱卡，且该发动能够被无效时，才可以发动。
function c3149764.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取连锁中那张魔法·陷阱卡发动时选择的对象卡（组）。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 确认对象卡组为1张，且该卡是场上表侧表示的不死族怪兽，同时该魔法·陷阱卡的发动可以被无效。
	return tg and tg:GetCount()==1 and c3149764.cfilter(tg:GetFirst()) and Duel.IsChainNegatable(ev)
end
-- 发动时无需再选择额外对象；登记本次效果处理将无效连锁中的那张魔法·陷阱卡，并在其可破坏且仍关联时登记破坏。
function c3149764.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果处理将无效连锁中那张魔法·陷阱卡的发动。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 在该魔法·陷阱卡可被效果破坏且仍与本次效果关联时，设置操作信息将其破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先无效那张魔法·陷阱卡的发动，若无效成功且该卡仍与本次效果关联，则将其破坏。
function c3149764.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效了该魔法·陷阱卡的发动，并确认被无效的魔法·陷阱卡仍与本次效果关联（未离场）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因将那张被无效的魔法·陷阱卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

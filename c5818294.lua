--武神器－ヘツカ
-- 效果：
-- ①：自己场上的「武神」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个效果无效。
function c5818294.initial_effect(c)
	-- ①：自己场上的「武神」怪兽为对象的魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5818294,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c5818294.negcon)
	-- 把墓地的这张卡除外作为发动的代价（Cost）
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c5818294.negtg)
	e1:SetOperation(c5818294.negop)
	c:RegisterEffect(e1)
end
-- 过滤条件：位于自己怪兽区域、由自己控制、表侧表示且卡名含有「武神」的怪兽
function c5818294.tfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x88)
end
-- 判断效果发动条件：该效果必须是取对象的效果，且对象中包含自己场上的「武神」怪兽，并且该效果可以被无效
function c5818294.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果所选择的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断对象中是否存在符合条件的「武神」怪兽，且该连锁效果可以被无效
	return g and g:IsExists(c5818294.tfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 效果发动的目标：设置效果处理分类为无效效果
function c5818294.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，表明该效果的处理包含“使效果无效”
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果处理：使该连锁的效果无效
function c5818294.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前处理的连锁效果无效
	Duel.NegateEffect(ev)
end

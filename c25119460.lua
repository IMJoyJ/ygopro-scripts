--YZ－キャタピラー・ドラゴン
-- 效果：
-- 「Y-龙头」＋「Z-金属履带」
-- 把自己场上的上记卡除外的场合才能从额外卡组特殊召唤。这张卡不能作从墓地的特殊召唤。
-- ①：丢弃1张手卡，以对方场上1只里侧表示怪兽为对象才能发动。那只对方的里侧表示怪兽破坏。
function c25119460.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为65622692和64500000的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,65622692,64500000,true,true)
	-- 添加接触融合特殊召唤规则，要求自己场上的怪兽除外作为召唤条件
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 这张卡不能作从墓地的特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c25119460.splimit)
	c:RegisterEffect(e1)
	-- ①：丢弃1张手卡，以对方场上1只里侧表示怪兽为对象才能发动。那只对方的里侧表示怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25119460,0))  --"怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c25119460.descost)
	e3:SetTarget(c25119460.destg)
	e3:SetOperation(c25119460.desop)
	c:RegisterEffect(e3)
end
-- 限制特殊召唤只能从额外卡组或场上特殊召唤，不能从墓地特殊召唤
function c25119460.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 丢弃1张手卡作为效果发动的代价
function c25119460.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于判断目标怪兽是否为里侧表示
function c25119460.filter(c)
	return c:IsFacedown()
end
-- 设置效果的目标选择逻辑，选择对方场上的里侧表示怪兽
function c25119460.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c25119460.filter(chkc) end
	-- 检查对方场上是否存在满足条件的里侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c25119460.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1只里侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c25119460.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，确定效果将破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行效果破坏操作，将目标怪兽破坏
function c25119460.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsFacedown() then
		-- 以效果原因破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--XYZ－ドラゴン・キャノン
-- 效果：
-- 「X-首领加农」＋「Y-龙头」＋「Z-金属履带」
-- 把自己场上的上记的卡除外的场合才能从额外卡组特殊召唤。这张卡不能从墓地特殊召唤。
-- ①：丢弃1张手卡，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
function c91998119.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置「X-首领加农」＋「Y-龙头」＋「Z-金属履带」为融合素材。
	aux.AddFusionProcCode3(c,62651957,65622692,64500000,true,true)
	-- 设置接触融合召唤手续：将自己场上表侧表示的上述素材卡除外。
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 把自己场上的上记的卡除外的场合才能从额外卡组特殊召唤。这张卡不能从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c91998119.splimit)
	c:RegisterEffect(e1)
	-- ①：丢弃1张手卡，以对方场上1张卡为对象才能发动。那张对方的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91998119,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c91998119.descost)
	e3:SetTarget(c91998119.destg)
	e3:SetOperation(c91998119.desop)
	c:RegisterEffect(e3)
end
-- 限制该卡不能从额外卡组和墓地进行通常的特殊召唤（必须满足其自身召唤条件）。
function c91998119.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 破坏效果的发动代价（Cost）判定与执行函数。
function c91998119.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手牌作为发动代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 破坏效果的发动条件、对象选择与操作信息注册函数。
function c91998119.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1张可以作为对象的目标卡片。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 注册效果处理信息，表明该连锁将要破坏选中的卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的实际处理函数。
function c91998119.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 因效果将目标卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--YZ－キャタピラー・ドラゴン
-- 效果：
-- 「Y-龙头」＋「Z-金属履带」
-- 把自己场上的上记卡除外的场合才能从额外卡组特殊召唤。这张卡不能作从墓地的特殊召唤。
-- ①：丢弃1张手卡，以对方场上1只里侧表示怪兽为对象才能发动。那只对方的里侧表示怪兽破坏。
function c25119460.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册以「Y-龙头」（65622692）和「Z-金属履带」（64500000）为融合素材的融合召唤手续，并允许使用代用素材、不需要融合魔法。
	aux.AddFusionProcCode2(c,65622692,64500000,true,true)
	-- 为这张卡注册接触融合手续：以自己场上能作为除外代价的卡为素材，将素材除外（表侧表示除外、作为COST）后从额外卡组进行融合特殊召唤。
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 这张卡不能作从墓地的特殊召唤。
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
-- 特殊召唤条件判定：当这张卡不在额外卡组或墓地时才允许被特殊召唤，即禁止从额外卡组或墓地特殊召唤这张卡。
function c25119460.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 效果的发动代价处理：先确认手牌存在可丢弃的卡，然后丢弃1张手卡作为COST。
function c25119460.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方手牌是否存在至少1张可以丢弃的卡，用于满足丢弃手卡的发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：从己方手牌选择丢弃1张手卡，丢弃原因标记为代价丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义可选择的怪兽为里侧表示怪兽，用作效果对象过滤器。
function c25119460.filter(c)
	return c:IsFacedown()
end
-- 效果发动时的目标处理：从对方场上选择1只里侧表示怪兽作为对象，并设置破坏的操作信息。
function c25119460.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c25119460.filter(chkc) end
	-- 检查对方场上是否存在至少1只里侧表示怪兽可以作为效果的对象。
	if chk==0 then return Duel.IsExistingTarget(c25119460.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示“请选择要破坏的卡”，用于选择对象时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只里侧表示怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c25119460.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的破坏操作信息：将已选择的对象作为破坏目标，数量为其数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：取得对象卡，若对象卡仍与效果相关、仍在对方场上且为里侧表示，则将其破坏。
function c25119460.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果处理中第一个选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsFacedown() then
		-- 以效果破坏该对象卡，破坏后送入墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

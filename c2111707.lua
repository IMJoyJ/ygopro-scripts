--XY－ドラゴン・キャノン
-- 效果：
-- 「X-首领加农」＋「Y-龙头」
-- 把自己场上的上记卡除外的场合才能从额外卡组特殊召唤。这张卡不能作从墓地的特殊召唤。
-- ①：丢弃1张手卡，以对方场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张对方的表侧表示的卡破坏。
function c2111707.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册以『X-首领加农』和『Y-龙头』为融合素材的融合召唤手续，使其可以通过融合召唤从额外卡组出场。
	aux.AddFusionProcCode2(c,62651957,65622692,true,true)
	-- 为这张卡注册接触融合特殊召唤手续：把自己场上的上述融合素材怪兽表侧表示除外作为代价（REASON_COST），从额外卡组特殊召唤这张卡。
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 『这张卡不能作从墓地的特殊召唤。』
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c2111707.splimit)
	c:RegisterEffect(e1)
	-- 『①：丢弃1张手卡，以对方场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张对方的表侧表示的卡破坏。』
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2111707,0))  --"魔陷破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c2111707.descost)
	e3:SetTarget(c2111707.destg)
	e3:SetOperation(c2111707.desop)
	c:RegisterEffect(e3)
end
-- 特殊召唤限制条件的判定函数：通过检查卡片所在位置，实现禁止此卡从墓地特殊召唤（若在墓地则判定不通过，不允许特殊召唤）。
function c2111707.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA+LOCATION_GRAVE)
end
-- ①效果发动代价的处理：检查并执行从手卡丢弃1张卡作为COST。
function c2111707.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己手卡中是否存在至少1张可丢弃的卡，否则不能发动该效果。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从自己手卡选择1张卡丢弃，丢弃原因设为COST+丢弃（REASON_COST+REASON_DISCARD）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果对象筛选条件：对方场上表侧表示的魔法·陷阱卡（用于选择要破坏的目标）。
function c2111707.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①效果的发动目标选择处理：检查对方场上是否有符合条件的表侧魔法·陷阱卡，若有则选择其中1张作为对象，并设置破坏的处理信息。
function c2111707.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c2111707.filter(chkc) end
	-- 目标检查阶段：确认对方场上有1张符合条件的表侧魔法·陷阱卡可以被选为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c2111707.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发出HINTMSG_DESTROY选择提示，即『请选择要破坏的卡』，用于目标选择时的提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张符合条件的表侧魔法·陷阱卡，并将其登记为本次效果的对象（取对象）。
	local g=Duel.SelectTarget(tp,c2111707.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁处理信息：本连锁将执行破坏效果，要破坏的目标为该组卡片，数量为组内卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理阶段：取得效果对象，若该卡仍与效果关联且仍在对方场上表侧表示，则将其破坏。
function c2111707.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁中登记的第一张效果对象卡（此效果只有1张对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsFaceup() then
		-- 以效果（REASON_EFFECT）为破坏原因，将目标卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--XZ－キャタピラー・キャノン
-- 效果：
-- 「X-首领加农」＋「Z-金属履带」
-- 把自己场上的上记卡除外的场合才能从额外卡组特殊召唤。这张卡不能作从墓地的特殊召唤。
-- ①：丢弃1张手卡，以对方场上1张里侧表示的魔法·陷阱卡为对象才能发动。那张对方的里侧表示的卡破坏。
function c99724761.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册融合召唤手续：融合素材为「X-首领加农」（62651957）和「Z-金属履带」（64500000），并允许素材替代。
	aux.AddFusionProcCode2(c,62651957,64500000,true,true)
	-- 注册接触融合手续：无需融合魔法，把自己场上的上述融合素材卡除外（表侧表示、作为COST），即可从额外卡组特殊召唤这张卡。
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- 「X-首领加农」＋「Z-金属履带」 把自己场上的上记卡除外的场合才能从额外卡组特殊召唤。这张卡不能作从墓地的特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c99724761.splimit)
	c:RegisterEffect(e1)
	-- ①：丢弃1张手卡，以对方场上1张里侧表示的魔法·陷阱卡为对象才能发动。那张对方的里侧表示的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99724761,0))  --"魔陷破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c99724761.descost)
	e3:SetTarget(c99724761.destg)
	e3:SetOperation(c99724761.desop)
	c:RegisterEffect(e3)
end
-- 特殊召唤条件判定函数：当这张卡位于额外卡组或墓地时返回 false，不允许从这些区域被特殊召唤，用于实现“不能作从墓地的特殊召唤”等限制。
function c99724761.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 效果发动代价函数：检查并执行丢弃1张手牌作为发动代价。
function c99724761.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认发动者手牌中至少有1张可丢弃的卡，用来支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际从手牌选择并丢弃1张卡，丢弃理由为代价和丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 对象筛选函数：判断卡片是否为里侧表示，用于筛选对方场上的里侧表示魔法·陷阱卡。
function c99724761.filter(c)
	return c:IsFacedown()
end
-- 效果目标选择函数：选择对方场上1张里侧表示的魔法·陷阱卡作为对象，并登记破坏信息。
function c99724761.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c99724761.filter(chkc) end
	-- 目标检查：确认对方场上有符合条件的里侧表示魔法·陷阱卡且能成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c99724761.filter,tp,0,LOCATION_SZONE,1,nil) end
	-- 显示选择提示：“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动者从对方场上选择1张里侧表示的魔法·陷阱卡，将其设为效果对象。
	local g=Duel.SelectTarget(tp,c99724761.filter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设置连锁操作信息，登记本次效果将破坏所选对象，供相关效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数：取出对象卡，若该卡仍受此效果影响且仍在对方场上里侧表示，则将其破坏。
function c99724761.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中作为效果对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsFacedown() then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

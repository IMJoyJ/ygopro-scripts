--タイフーン
-- 效果：
-- 对方场上有魔法·陷阱卡2张以上存在，自己场上没有魔法·陷阱卡存在的场合，这张卡的发动从手卡也能用。
-- ①：以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
function c14883228.initial_effect(c)
	-- ①：以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c14883228.target)
	e1:SetOperation(c14883228.activate)
	c:RegisterEffect(e1)
	-- 对方场上有魔法·陷阱卡2张以上存在，自己场上没有魔法·陷阱卡存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14883228,0))  --"适用「台风」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c14883228.handcon)
	c:RegisterEffect(e2)
end
-- 定义筛选魔法·陷阱卡的过滤器，匹配类型为魔法或陷阱的卡。
function c14883228.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 手卡发动条件的判定：自己场上没有魔法·陷阱卡，且对方场上有2张以上魔法·陷阱卡。
function c14883228.handcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在0张魔法·陷阱卡（即不存在魔法·陷阱卡）。
	return not Duel.IsExistingMatchingCard(c14883228.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 同时检查对方场上是否存在至少2张魔法·陷阱卡。
		and Duel.IsExistingMatchingCard(c14883228.cfilter,tp,0,LOCATION_ONFIELD,2,nil)
end
-- 定义可被选择为对象的过滤器：场上的表侧表示魔法·陷阱卡。
function c14883228.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动时选择对象并设置破坏效果：从双方场上的表侧表示魔法·陷阱卡中选择1张作为对象（不能选自身），并记录破坏信息。
function c14883228.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c14883228.filter(chkc) and chkc~=e:GetHandler() end
	-- 发动条件检查：场上是否存在1张符合条件的表侧表示魔法·陷阱卡可作为对象（且不是本卡）。
	if chk==0 then return Duel.IsExistingTarget(c14883228.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家显示“请选择要破坏的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张表侧表示魔法·陷阱卡作为对象，并登记为效果对象。
	local g=Duel.SelectTarget(tp,c14883228.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置即将进行的破坏操作信息（分类为破坏、对象为g、数量1），供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得对象卡，若仍与效果相关联则将其破坏。
function c14883228.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

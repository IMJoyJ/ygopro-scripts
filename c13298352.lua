--冑の忍者－櫓丸
-- 效果：
-- 种族不同的「忍者」怪兽×2
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把自己场上的上记卡解放的场合可以从额外卡组特殊召唤。
-- ①：这张卡特殊召唤·反转的场合，从自己的手卡·墓地以及自己场上的表侧表示的卡之中把这张卡以外的1张「忍者」卡或者「忍法」卡除外，以场上1张卡为对象才能发动。那张卡除外。这个卡名的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化怪兽效果：为这张卡添加苏生限制、融合召唤手续、接触融合手续、额外卡组特殊召唤条件限制，以及特殊召唤/反转时触发的除外效果（含同名卡效果1回合1次限制）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤手续：使用2只满足s.mfilter条件的怪兽作为融合素材（即2只种族不同的「忍者」怪兽），进行融合召唤。
	aux.AddFusionProcFunRep(c,s.mfilter,2,true)
	-- 追加接触融合手续：可以将自己场上可解放的怪兽（不经过融合魔法）以解放的形式作为融合素材，从额外卡组特殊召唤这张卡。
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	-- 对应效果原文：这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- 对应效果原文：①：这张卡特殊召唤的场合，从自己的手卡·墓地以及自己场上的表侧表示的卡之中把这张卡以外的1张「忍者」卡或者「忍法」卡除外，以场上1张卡为对象才能发动。那张卡除外。这个卡名的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
end
-- 融合素材过滤函数：素材必须是「忍者」字段（0x2b）的怪兽，且任意两只素材的种族不能相同，以保证2只素材种族各不相同。
function s.mfilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x2b) and (not sg or not sg:IsExists(Card.IsRace,1,c,c:GetRace()))
end
-- 特殊召唤条件限制函数：该卡只能通过融合召唤（或等价的上记卡解放接触融合召唤）从额外卡组特殊召唤，其他特殊召唤方式不允许。
function s.splimit(e,se,sp,st)
	-- 若此卡当前不在额外卡组（例如在手牌/墓地等）则不限制；若在额外卡组，则召唤类型必须是融合召唤（aux.fuslimit检查），否则不能特殊召唤。
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- 除外代价过滤函数：用于筛选从手牌、墓地以及自己场上表侧表示的卡中，除自身以外的1张「忍者」（0x2b）或「忍法」（0x61）卡，且可以除外作为代价，同时场上必须存在能够被除外的对象卡。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x2b,0x61) and c:IsAbleToRemoveAsCost()
		-- 额外条件：在可以成为效果对象的卡中，检查场上是否存在至少1张能够被除外的卡，作为效果的目标候选。
		and Duel.IsExistingTarget(Card.IsAbleToRemove,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 效果发动代价处理：确认有满足条件的「忍者」/「忍法」卡可用于除外代价后，从上述范围内选择1张卡表侧表示除外，作为发动COST，然后进入目标选择。
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动代价检查：从手牌、墓地以及自己场上表侧表示的卡中，是否存在1张除这张卡以外且满足s.cfilter的「忍者」/「忍法」卡，可被除外作为发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_ONFIELD,0,1,c) end
	-- 给玩家显示选择提示，提示文字为『请选择要除外的卡』，用于选择要除外的代价卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己的手牌、墓地、场上表侧表示的卡中，选择1张满足s.cfilter且不是这张卡自身的卡，作为发动代价。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c)
	-- 将选中的代价卡以表侧表示除外，作为效果的发动COST。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果目标选择处理：以场上任意1张能够被除外的卡为对象发动，并设置操作信息，准备在效果处理时将其除外。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 目标检查：确认场上（双方合计）存在至少1张能够被效果除外的卡，可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示选择提示，提示文字为『请选择要除外的卡』，用于选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从场上选择1张能够被除外的卡作为效果对象，同时将该卡登记为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，声明本效果要执行的是除外1张卡的操作，供后续时点/连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理函数：效果结算时，取出对象卡，若它仍与当前连锁相关，则将那张卡表侧表示除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡与当前效果仍有联系（没有脱离场上或发生其他解除联系的情况），则将其表侧表示除外。
	if tc:IsRelateToEffect(e) then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
end

--冑の忍者－櫓丸
-- 效果：
-- 种族不同的「忍者」怪兽×2
-- 这张卡用融合召唤以及以下方法才能从额外卡组特殊召唤。
-- ●把自己场上的上记卡解放的场合可以从额外卡组特殊召唤。
-- ①：这张卡特殊召唤·反转的场合，从自己的手卡·墓地以及自己场上的表侧表示的卡之中把这张卡以外的1张「忍者」卡或者「忍法」卡除外，以场上1张卡为对象才能发动。那张卡除外。这个卡名的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，需要2个满足条件的融合素材
	aux.AddFusionProcFunRep(c,s.mfilter,2,true)
	-- 添加接触融合程序，通过解放场上符合条件的卡从额外卡组特殊召唤
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	-- 这张卡只能通过融合召唤以及接触融合方式从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- 特殊召唤成功时发动的效果，将场上一张卡除外
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
-- 融合素材过滤函数，筛选种族不同的「忍者」怪兽
function s.mfilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x2b) and (not sg or not sg:IsExists(Card.IsRace,1,c,c:GetRace()))
end
-- 特殊召唤条件限制函数
function s.splimit(e,se,sp,st)
	-- 判断是否为融合召唤或接触融合召唤
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- 除外费用过滤函数，筛选场上表侧表示的「忍者」或「忍法」卡
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x2b,0x61) and c:IsAbleToRemoveAsCost()
		-- 检查是否存在可以作为除外对象的场上卡
		and Duel.IsExistingTarget(Card.IsAbleToRemove,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 除外费用处理函数
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足除外费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_ONFIELD,0,1,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择满足条件的卡进行除外
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_ONFIELD,0,1,1,c)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 除外效果的目标选择函数
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 检查是否存在可以除外的场上卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的场上卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择场上一张卡作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，记录将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 除外效果的处理函数
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 如果目标卡存在则将其除外
	if tc:IsRelateToEffect(e) then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
end

--影六武衆－リハン
-- 效果：
-- 属性不同的「六武众」怪兽×3
-- 把自己场上的上记卡送去墓地的场合才能从额外卡组特殊召唤（不需要「融合」）。这张卡不能作为融合素材。
-- ①：1回合1次，从手卡以及自己场上的表侧表示的卡之中把1张「六武众」卡除外，以场上1张卡为对象才能发动。那张卡除外。
-- ②：自己场上的「六武众」怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c33964637.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用3个满足条件的「六武众」怪兽进行融合召唤
	aux.AddFusionProcFunRep(c,c33964637.ffilter,3,true)
	-- 添加接触融合特殊召唤规则，需要将自己场上的怪兽送去墓地才能特殊召唤
	aux.AddContactFusionProcedure(c,Card.IsAbleToGraveAsCost,LOCATION_MZONE,0,Duel.SendtoGrave,REASON_COST)
	-- ①：1回合1次，从手卡以及自己场上的表侧表示的卡之中把1张「六武众」卡除外，以场上1张卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c33964637.splimit)
	c:RegisterEffect(e1)
	-- 这张卡不能作为融合素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ①：1回合1次，从手卡以及自己场上的表侧表示的卡之中把1张「六武众」卡除外，以场上1张卡为对象才能发动。那张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(33964637,0))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c33964637.rmcost)
	e4:SetTarget(c33964637.rmtg)
	e4:SetOperation(c33964637.rmop)
	c:RegisterEffect(e4)
	-- ②：自己场上的「六武众」怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetTarget(c33964637.reptg)
	e5:SetValue(c33964637.repval)
	e5:SetOperation(c33964637.repop)
	c:RegisterEffect(e5)
end
-- 限制该卡不能从额外卡组特殊召唤，除非是通过接触融合方式
function c33964637.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 融合素材过滤函数，确保融合使用的怪兽属性各不相同
function c33964637.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x103d) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 除外费用过滤函数，检查手牌或场上的「六武众」卡是否可以作为除外费用
function c33964637.costfilter(c,tp)
	return c:IsSetCard(0x103d) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		-- 检查是否存在可以作为除外对象的场上卡
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 起动效果的除外费用处理，选择一张符合条件的卡除外
function c33964637.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足除外费用条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c33964637.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足除外费用条件的卡
	local g=Duel.SelectMatchingCard(tp,c33964637.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil,tp)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的目标选择处理，选择一张场上卡除外
function c33964637.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上一张可除外的卡作为目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，确定将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果的处理函数，将目标卡除外
function c33964637.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 代替破坏的过滤函数，判断是否为「六武众」怪兽且因战斗或效果被破坏
function c33964637.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的目标判定函数，检查是否可以发动代替破坏效果
function c33964637.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c33964637.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的值函数，返回是否满足代替破坏条件
function c33964637.repval(e,c)
	return c33964637.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的处理函数，将自身除外
function c33964637.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身除外作为代替破坏的效果处理
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

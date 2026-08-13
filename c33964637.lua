--影六武衆－リハン
-- 效果：
-- 属性不同的「六武众」怪兽×3
-- 把自己场上的上记卡送去墓地的场合才能从额外卡组特殊召唤（不需要「融合」）。这张卡不能作为融合素材。
-- ①：1回合1次，从手卡以及自己场上的表侧表示的卡之中把1张「六武众」卡除外，以场上1张卡为对象才能发动。那张卡除外。
-- ②：自己场上的「六武众」怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c33964637.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：用3只满足条件的「六武众」怪兽作为融合素材（ffilter保证素材为「六武众」且属性各不相同）。
	aux.AddFusionProcFunRep(c,c33964637.ffilter,3,true)
	-- 为这张卡添加接触融合手续：把自己场上的素材怪兽送去墓地，即可从额外卡组特殊召唤（不需要「融合」）。
	aux.AddContactFusionProcedure(c,Card.IsAbleToGraveAsCost,LOCATION_MZONE,0,Duel.SendtoGrave,REASON_COST)
	-- 把自己场上的上记卡送去墓地的场合才能从额外卡组特殊召唤（不需要「融合」）。
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
-- 该判定限制这张卡只能从额外卡组特殊召唤：当它不在额外卡组时（如在墓地、手卡、除外等），不允许被特殊召唤。
function c33964637.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 融合素材过滤器：素材必须是「六武众」怪兽，且与已选素材属性均不相同（确保3只素材属性互异）。
function c33964637.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x103d) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- ①的代价过滤器：选择除外的手卡或自己场上表侧表示的「六武众」卡，同时要求场上存在1张能被除外的卡作为效果对象。
function c33964637.costfilter(c,tp)
	return c:IsSetCard(0x103d) and c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		-- 检查场上是否存在1张可以被除外的卡作为效果对象，确保发动①时能够选取对象。
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- ①的代价处理：从手卡和自己场上表侧表示的卡中选择1张「六武众」卡除外作为发动代价。
function c33964637.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查（chk==0）：确认存在符合条件的「六武众」卡可以作为代价，且场上存在可除外的对象卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c33964637.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil,tp) end
	-- 向玩家发送选择提示，提示内容是请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡和自己场上表侧表示的卡中挑选1张符合costfilter的「六武众」卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c33964637.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil,tp)
	-- 将选中的代价卡表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①的目标选择与发动条件判定：选择场上1张可以除外的卡作为效果对象，并设置除外相关的操作信息。
function c33964637.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	-- 向玩家发送选择提示，提示内容是请选择要除外的对象卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从场上选择1张可以被除外的卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果将把1张卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①的效果处理：取得对象后，若对象仍与效果关联，则将其除外。
function c33964637.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①所选择的场上对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡表侧表示除外，完成①的效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②的代替破坏过滤器：被保护怪兽须是自己场上的表侧「六武众」怪兽，且即将被战斗或效果破坏（且不是已被代替的破坏）。
function c33964637.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- ②的发动判定：墓地中的这张卡可以被除外，并且本次破坏事件中存在符合条件的己方「六武众」怪兽时，询问玩家是否发动代替破坏。
function c33964637.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c33964637.repfilter,1,nil,tp) end
	-- 弹出是否发动的选择框（选择是则除外墓地这张卡代替破坏）。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏判定：判断被破坏的怪兽是否满足保护条件（己方表侧「六武众」且被战破/效破）。
function c33964637.repval(e,c)
	return c33964637.repfilter(c,e:GetHandlerPlayer())
end
-- ②的代替破坏处理：把墓地中的这张卡除外，作为己方「六武众」怪兽被破坏的代替。
function c33964637.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地中的这张卡表侧表示除外，完成代替破坏。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

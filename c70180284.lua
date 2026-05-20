--影六武衆－ドウジ
-- 效果：
-- ①：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的「六武众」怪兽召唤·特殊召唤时才能发动。从卡组把1张「六武众」卡送去墓地。
-- ②：只让自己场上的「六武众」怪兽1只被效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c70180284.initial_effect(c)
	-- ①：这张卡已在怪兽区域存在的状态，自己场上有这张卡以外的「六武众」怪兽召唤·特殊召唤时才能发动。从卡组把1张「六武众」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70180284,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c70180284.tgcon)
	e1:SetTarget(c70180284.tgtg)
	e1:SetOperation(c70180284.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只让自己场上的「六武众」怪兽1只被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(c70180284.reptg)
	e3:SetValue(c70180284.repval)
	e3:SetOperation(c70180284.repop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「六武众」怪兽
function c70180284.tgcfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x103d) and c:IsControler(tp)
end
-- 发动条件：自己场上有这张卡以外的「六武众」怪兽召唤·特殊召唤成功
function c70180284.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(c70180284.tgcfilter,1,e:GetHandler(),tp)
end
-- 过滤条件：卡组中可送去墓地的「六武众」卡
function c70180284.tgfilter(c)
	return c:IsSetCard(0x103d) and c:IsAbleToGrave()
end
-- 效果发动：检查卡组中是否存在可送去墓地的「六武众」卡，并设置送去墓地的操作信息
function c70180284.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以送去墓地的「六武众」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c70180284.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张「六武众」卡送去墓地
function c70180284.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张「六武众」卡
	local g=Duel.SelectMatchingCard(tp,c70180284.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上因效果破坏（且非代替破坏）的表侧表示「六武众」怪兽
function c70180284.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏的目标检查：此卡在墓地可除外，且被破坏的怪兽仅有1只满足条件的「六武众」怪兽
function c70180284.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c70180284.repfilter,1,nil,tp)
		and eg:GetCount()==1 end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的价值函数：确定被代替破坏的怪兽符合过滤条件
function c70180284.repval(e,c)
	return c70180284.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的效果处理：将墓地的这张卡除外
function c70180284.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

--Kozmo－ランドウォーカー
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己场上的「星际仙踪」卡被战斗或者对方的效果破坏的场合，可以作为代替把自己场上1张「星际仙踪」卡破坏。
-- ②：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只5星以下的「星际仙踪」怪兽特殊召唤。
function c59496924.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己场上的「星际仙踪」卡被战斗或者对方的效果破坏的场合，可以作为代替把自己场上1张「星际仙踪」卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c59496924.reptg)
	e1:SetValue(c59496924.repval)
	e1:SetOperation(c59496924.repop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合，把墓地的这张卡除外才能发动。从卡组把1只5星以下的「星际仙踪」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59496924,1))  --"从卡组把「星际仙踪」怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c59496924.spcon)
	e2:SetCost(c59496924.spcost)
	e2:SetTarget(c59496924.sptg)
	e2:SetOperation(c59496924.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上因战斗或对方效果破坏的「星际仙踪」卡
function c59496924.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0xd2)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 过滤自己场上可以作为代替破坏的「星际仙踪」卡
function c59496924.desfilter(c,e,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField() and c:IsSetCard(0xd2)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的靶向/条件检查：检查是否有符合条件的被破坏卡，以及自己场上是否有可代替破坏的卡
function c59496924.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c59496924.repfilter,1,nil,tp)
		-- 检查自己场上是否存在至少1张可以代替破坏的「星际仙踪」卡
		and Duel.IsExistingMatchingCard(c59496924.desfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 设置选择代替破坏卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家选择1张自己场上的「星际仙踪」卡作为代替破坏的对象
		local g=Duel.SelectMatchingCard(tp,c59496924.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
-- 确定哪些卡片被破坏时可以适用此代替破坏效果
function c59496924.repval(e,c)
	return c59496924.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的具体执行：将选中的代替卡破坏
function c59496924.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示对方玩家发动了此卡（不入连锁的代替破坏效果）
	Duel.Hint(HINT_CARD,0,59496924)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 破坏选中的代替卡
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
-- 检查此卡是否因战斗或效果破坏
function c59496924.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 效果发动代价：将墓地的此卡除外
function c59496924.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() and e:GetHandler():IsLocation(LOCATION_GRAVE) end
	-- 将墓地的此卡除外作为发动的代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤卡组中5星以下的「星际仙踪」怪兽
function c59496924.spfilter(c,e,tp)
	return c:IsSetCard(0xd2) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶向/条件检查：检查怪兽区域是否有空位，以及卡组中是否有符合条件的怪兽
function c59496924.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的5星以下「星际仙踪」怪兽
		and Duel.IsExistingMatchingCard(c59496924.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤操作的信息（从卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的具体执行：从卡组选择并特殊召唤1只5星以下的「星际仙踪」怪兽
function c59496924.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 设置选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只符合条件的「星际仙踪」怪兽
	local g=Duel.SelectMatchingCard(tp,c59496924.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

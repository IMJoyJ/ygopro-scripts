--ジェムナイト・ヴォイドルーツ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把1只「宝石骑士」通常怪兽或1张「宝石骑士融合」从卡组送去墓地才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：自己场上有「宝石骑士」融合怪兽存在，对方把效果发动时，从自己墓地把包含这张卡的3张「宝石骑士」卡除外才能发动。那个效果无效。那之后，自己场上的全部「宝石骑士」怪兽的攻击力上升1000。
local s,id,o=GetID()
-- 注册卡片效果：①手卡起动特召效果，②墓地诱发即时无效并加攻效果。
function s.initial_effect(c)
	-- 记录卡片效果中记载了「宝石骑士融合」（卡号1264319）。
	aux.AddCodeList(c,1264319)
	-- ①：把1只「宝石骑士」通常怪兽或1张「宝石骑士融合」从卡组送去墓地才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「宝石骑士」融合怪兽存在，对方把效果发动时，从自己墓地把包含这张卡的3张「宝石骑士」卡除外才能发动。那个效果无效。那之后，自己场上的全部「宝石骑士」怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可作为特召代价送去墓地的「宝石骑士」通常怪兽或「宝石骑士融合」。
function s.costfilter(c)
	return (c:IsSetCard(0x1047) and c:IsType(TYPE_NORMAL) or c:IsCode(1264319)) and c:IsAbleToGraveAsCost()
end
-- 特召效果的Cost：从卡组将1张符合条件的卡送去墓地。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张符合条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 特召效果的Target：检查怪兽区域空格以及自身是否能特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤自身的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特召效果的Operation：将自身从手卡守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以守备表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤自己场上表侧表示的「宝石骑士」融合怪兽。
function s.tfilter(c,tp)
	return c:IsSetCard(0x1047) and c:IsType(TYPE_FUSION) and c:IsFaceup()
end
-- 无效效果的Condition：对方发动效果时，且自己场上有表侧表示的「宝石骑士」融合怪兽存在。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动效果，且该效果可以被无效。
	return rp==1-tp and Duel.IsChainDisablable(ev)
		-- 检查自己场上是否存在表侧表示的「宝石骑士」融合怪兽。
		and Duel.IsExistingMatchingCard(s.tfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤墓地中可作为代价除外的「宝石骑士」卡。
function s.costfilter2(c)
	return c:IsSetCard(0x1047) and c:IsAbleToRemoveAsCost()
end
-- 无效效果的Cost：从自己墓地将包含这张卡在内的3张「宝石骑士」卡除外。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己墓地中除这张卡以外的所有「宝石骑士」卡。
	local g=Duel.GetMatchingGroup(s.costfilter2,tp,LOCATION_GRAVE,0,c)
	if chk==0 then return c:IsAbleToRemoveAsCost() and c:IsSetCard(0x1047) and g:GetCount()>=2 end
	local sg
	if #g==2 then
		sg=g
	else
		-- 提示玩家选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		sg=g:Select(tp,2,2,nil)
	end
	sg:AddCard(c)
	-- 将选中的卡（包含自身共3张）作为发动代价除外。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 过滤自己场上表侧表示且不受当前效果影响的「宝石骑士」怪兽。
function s.atkfilter(c,e)
	return c:IsSetCard(0x1047) and c:IsFaceup() and (not e or not c:IsImmuneToEffect(e))
end
-- 无效效果的Target：检查场上是否存在符合条件的「宝石骑士」怪兽，并设置无效操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的「宝石骑士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置使对方发动效果无效的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 无效效果的Operation：使对方发动的效果无效，之后自己场上全部「宝石骑士」怪兽攻击力上升1000。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使该连锁的效果无效，若成功则执行后续处理。
	if Duel.NegateEffect(ev) then
		-- 获取自己场上所有表侧表示且不免疫此效果的「宝石骑士」怪兽。
		local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil,e)
		if g:GetCount()>0 then
			-- 遍历所有符合条件的「宝石骑士」怪兽。
			for tc in aux.Next(g) do
				-- 自己场上的全部「宝石骑士」怪兽的攻击力上升1000。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(1000)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end

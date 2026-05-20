--Jade Dragon Mech
-- 效果：
-- 调整+调整以外的怪兽1只以上
-- 这张卡特殊召唤的场合：可以从卡组把1只机械族调整送去墓地。自己场上有持有和原本等级不同等级的怪兽的场合，也能作为代替特殊召唤。「翠铁之机龙」的这个效果1回合只能使用1次。
-- 同调召唤的这张卡被效果破坏送去墓地的场合：可以从自己墓地把调整任意数量除外，以那个数量的场上的卡为对象；那些卡破坏。
local s,id,o=GetID()
-- 初始化效果注册函数，包含同调召唤手续、特殊召唤成功时的诱发效果、以及被破坏送墓时的诱发效果。
function s.initial_effect(c)
	-- 设置同调召唤手续：调整+调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡特殊召唤的场合：可以从卡组把1只机械族调整送去墓地。自己场上有持有和原本等级不同等级的怪兽的场合，也能作为代替特殊召唤。「翠铁之机龙」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- 同调召唤的这张卡被效果破坏送去墓地的场合：可以从自己墓地把调整任意数量除外，以那个数量的场上的卡为对象；那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.descon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中满足条件的机械族调整怪兽（可送去墓地，或在满足代替条件时可特殊召唤）。
function s.tgfilter(c,e,tp,check)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_TUNER) and c:IsRace(RACE_MACHINE)
		and (c:IsAbleToGrave() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 过滤自己场上表侧表示且当前等级与原本等级不同的怪兽。
function s.cfilter(c)
	local lv=c:GetOriginalLevel()
	return c:IsFaceup() and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- 特殊召唤成功时效果的发动准备与可行性检查。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否存在等级与原本等级不同的怪兽。
		local check=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
			-- 并且检查自己场上是否有空余的怪兽区域。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以送去墓地（或在满足代替条件时特殊召唤）的机械族调整怪兽。
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
end
-- 特殊召唤成功时效果的处理：将卡组的机械族调整送去墓地，或者作为代替特殊召唤。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在等级与原本等级不同的怪兽，以判断是否满足代替特殊召唤的条件。
	local check=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查自己场上是否有空余的怪兽区域以进行特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 提示玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组选择1只满足条件的机械族调整怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check)
	local tc=g:GetFirst()
	if tc then
		if check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 若满足代替特殊召唤的条件，且该卡不能送去墓地或玩家选择将其特殊召唤（1191为送去墓地，1152为特殊召唤）。
			and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1191,1152)==1) then
			-- 将选择的怪兽在自己场上表侧表示特殊召唤。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		elseif tc:IsAbleToGrave() then
			-- 将选择的怪兽送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- 检查发动条件：此卡必须是同调召唤的、在怪兽区域被效果破坏并送去墓地。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤自己墓地中可以作为Cost除外的调整怪兽。
function s.costfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动Cost处理：从自己墓地除外任意数量的调整怪兽，并记录除外数量。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地中是否存在至少1只可以除外的调整怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取场上可以成为效果对象的卡片总数，作为除外数量的上限。
	local rt=Duel.GetTargetCount(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张至rt张调整怪兽。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,rt,nil)
	-- 将选择的墓地怪兽表侧表示除外，并获取实际除外的数量。
	local ct=Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(ct)
end
-- 效果发动时的对象选择：以与除外数量相同的场上的卡为对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以成为对象的卡片。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择与除外数量相同数量的场上的卡作为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置效果处理信息为破坏这些选中的卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- 效果处理：破坏作为对象的场上的卡片。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍存在于场上的、与该连锁相关的对象卡片。
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if #tg>0 then
		-- 破坏这些对象卡片。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end

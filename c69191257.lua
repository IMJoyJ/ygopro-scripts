--翠鋁の機竜
-- 效果：
-- 调整+调整以外的怪兽1只以上
-- 这张卡特殊召唤的场合：可以从卡组把1只机械族调整送去墓地。自己场上有持有和原本等级不同等级的怪兽的场合，也能作为代替特殊召唤。「翠铁之机龙」的这个效果1回合只能使用1次。
-- 同调召唤的这张卡被效果破坏送去墓地的场合：可以从自己墓地把调整任意数量除外，以那个数量的场上的卡为对象；那些卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册同调召唤手续、①特召成功卡组机械族调整送墓/特召效果、②同调召唤被破坏送墓除外墓地调整破坏卡片效果
function s.initial_effect(c)
	-- 同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合：可以从卡组把1只机械族调整送去墓地。自己场上有持有和原本等级不同等级的怪兽的场合，也能作为代替特殊召唤。「翠铁之机龙」的这个效果1回合只能使用1次。
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
	-- ②：同调召唤的这张卡被效果破坏送去墓地的场合：可以从自己墓地把调整任意数量除外，以那个数量的场上的卡为对象；那些卡破坏。
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
-- 卡组过滤条件：机械族调整怪兽且可送去墓地（若满足条件也可特召）
function s.tgfilter(c,e,tp,check)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_TUNER) and c:IsRace(RACE_MACHINE)
		and (c:IsAbleToGrave() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 代替特召判定过滤：表侧表示且当前等级与原本等级不同的怪兽
function s.cfilter(c)
	local lv=c:GetOriginalLevel()
	return c:IsFaceup() and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- ①效果发动条件检查：检查卡组是否存在满足条件的机械族调整怪兽
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否存在等级发生变化的怪兽
		local check=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
			-- 检查自己主要怪兽区域是否有空位
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在可送去墓地或特殊召唤的机械族调整怪兽
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
end
-- ①效果处理：从卡组选1只机械族调整送去墓地或特殊召唤
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在等级发生变化的怪兽
	local check=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己主要怪兽区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择1只满足条件的机械族调整怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check)
	local tc=g:GetFirst()
	if tc then
		if check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断是否选择将该卡特殊召唤而非送去墓地
			and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1191,1152)==1) then
			-- 将选中的机械族调整怪兽表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		elseif tc:IsAbleToGrave() then
			-- 将选中的机械族调整怪兽送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- ②效果触发条件：同调召唤的此卡在怪兽区被效果破坏送去墓地
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- Cost过滤条件：墓地中可除外作为Cost的调整怪兽
function s.costfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- ②效果发动Cost：除外墓地任意数量的调整怪兽并记录除外数量
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在至少1只可除外的调整怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取场上可作为破坏对象的卡片数量上限
	local rt=Duel.GetTargetCount(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择任意数量（不超过场上目标上限）的调整怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,rt,nil)
	-- 除外选中的调整怪兽作为Cost，并记录实际除外张数
	local ct=Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(ct)
end
-- ②效果发动准备：选择等同于除外数量的场上卡片作为对象，设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可作为破坏对象的卡片
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local ct=e:GetLabel()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择数量等于Cost除外张数的场上卡片作为对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置连锁操作信息：破坏选中的场上卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- ②效果处理：将选中的对象卡片破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中关联且仍存在于场上的对象卡片
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsOnField,nil)
	if #tg>0 then
		-- 破坏选中的目标卡片
		Duel.Destroy(tg,REASON_EFFECT)
	end
end

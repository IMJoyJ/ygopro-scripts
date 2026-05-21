--魁炎星王－ソウコ
-- 效果：
-- 兽战士族4星怪兽×2
-- ①：这张卡超量召唤成功时才能发动。从卡组把1张「炎舞」魔法·陷阱卡盖放。
-- ②：1回合1次，把这张卡1个超量素材取除才能发动。兽战士族以外的场上的全部效果怪兽的效果直到对方回合结束时无效化。
-- ③：这张卡从场上送去墓地时，把自己场上3张表侧表示的「炎舞」魔法·陷阱卡送去墓地才能发动。4星以下而相同攻击力的2只兽战士族怪兽从卡组守备表示特殊召唤。
function c96381979.initial_effect(c)
	-- 添加XYZ召唤手续：兽战士族4星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEASTWARRIOR),4,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功时才能发动。从卡组把1张「炎舞」魔法·陷阱卡盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96381979,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c96381979.setcon)
	e1:SetTarget(c96381979.settg)
	e1:SetOperation(c96381979.setop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除才能发动。兽战士族以外的场上的全部效果怪兽的效果直到对方回合结束时无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96381979,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c96381979.discost)
	e2:SetTarget(c96381979.distg)
	e2:SetOperation(c96381979.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地时，把自己场上3张表侧表示的「炎舞」魔法·陷阱卡送去墓地才能发动。4星以下而相同攻击力的2只兽战士族怪兽从卡组守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(96381979,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c96381979.spcon)
	e3:SetCost(c96381979.spcost)
	e3:SetTarget(c96381979.sptg)
	e3:SetOperation(c96381979.spop)
	c:RegisterEffect(e3)
end
-- 定义效果①的发动条件：此卡超量召唤成功
function c96381979.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤卡组中可盖放的「炎舞」魔法·陷阱卡
function c96381979.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 定义效果①的靶向与检测：检查卡组中是否存在可盖放的「炎舞」魔法·陷阱卡
function c96381979.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检测卡组中是否存在至少1张可盖放的「炎舞」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c96381979.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 定义效果①的处理：从卡组选择1张「炎舞」魔法·陷阱卡在场上盖放
function c96381979.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「炎舞」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c96381979.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 定义效果②的代价：取除此卡的1个超量素材
function c96381979.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤场上表侧表示的、兽战士族以外的效果怪兽
function c96381979.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsRace(RACE_BEASTWARRIOR)
end
-- 定义效果②的靶向与检测：检查场上是否存在兽战士族以外的表侧表示效果怪兽
function c96381979.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检测双方场上是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96381979.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 定义效果②的处理：使场上所有兽战士族以外的表侧表示效果怪兽的效果直到对方回合结束时无效
function c96381979.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c96381979.dfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	while tc do
		-- 效果直到对方回合结束时无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		-- 效果直到对方回合结束时无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 定义效果③的发动条件：此卡从场上送去墓地
function c96381979.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤自己场上表侧表示、且能送去墓地作为代价的「炎舞」魔法·陷阱卡
function c96381979.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- 定义效果③的代价：将自己场上3张表侧表示的「炎舞」魔法·陷阱卡送去墓地（若「炎星仙-鹫真人」效果适用则可免除代价）
function c96381979.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检测自己场上是否存在至少3张满足条件的「炎舞」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c96381979.cfilter,tp,LOCATION_ONFIELD,0,3,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		or Duel.IsPlayerAffectedByEffect(tp,46241344) end
	-- 如果自己场上存在至少3张满足条件的「炎舞」魔法·陷阱卡
	if Duel.IsExistingMatchingCard(c96381979.cfilter,tp,LOCATION_ONFIELD,0,3,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		and (not Duel.IsPlayerAffectedByEffect(tp,46241344) or not Duel.SelectYesNo(tp,aux.Stringid(46241344,0))) then  --"是否不把卡送去墓地发动？"
		-- 提示玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家选择3张表侧表示的「炎舞」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c96381979.cfilter,tp,LOCATION_ONFIELD,0,3,3,nil)
		-- 将选择的卡片送去墓地作为发动代价
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- 过滤卡组中4星以下、可特殊召唤的兽战士族怪兽
function c96381979.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_BEASTWARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 辅助过滤函数：检查怪兽组中是否存在另一只与其攻击力相同的怪兽
function c96381979.afilter1(c,g)
	return g:IsExists(c96381979.afilter2,1,c,c:GetAttack())
end
-- 辅助过滤函数：检查怪兽的攻击力是否等于指定数值
function c96381979.afilter2(c,atk)
	return c:IsAttack(atk)
end
-- 定义效果③的靶向与检测：检查是否能从卡组守备表示特殊召唤2只4星以下且相同攻击力的兽战士族怪兽
function c96381979.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有满足特殊召唤条件的兽战士族怪兽
		local g=Duel.GetMatchingGroup(c96381979.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查自己场上是否有2个以上的怪兽空位，且卡组中存在至少一对相同攻击力的怪兽
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and g:IsExists(c96381979.afilter1,1,nil,g)
	end
	-- 设置特殊召唤的操作信息：从卡组特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 定义效果③的处理：从卡组将2只4星以下且相同攻击力的兽战士族怪兽守备表示特殊召唤
function c96381979.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若自己场上的怪兽空位不足2个，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有满足特殊召唤条件的兽战士族怪兽
	local g=Duel.GetMatchingGroup(c96381979.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local dg=g:Filter(c96381979.afilter1,nil,g)
	if dg:GetCount()>=1 then
		-- 提示玩家选择第一只要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc1=dg:Select(tp,1,1,nil):GetFirst()
		-- 提示玩家选择第二只要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc2=dg:FilterSelect(tp,c96381979.afilter2,1,1,tc1,tc1:GetAttack()):GetFirst()
		-- 将第一只怪兽以表侧守备表示放入特殊召唤的准备队列
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 将第二只怪兽以表侧守备表示放入特殊召唤的准备队列
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 完成所有准备队列中怪兽的特殊召唤
		Duel.SpecialSummonComplete()
	end
end

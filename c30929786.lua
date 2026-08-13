--立炎星－トウケイ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡用「炎星」怪兽的效果特殊召唤成功时才能发动。从卡组把1只「炎星」怪兽加入手卡。
-- ②：1回合1次，把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地才能发动。从卡组选1张「炎舞」魔法·陷阱卡在自己场上盖放。
function c30929786.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡用「炎星」怪兽的效果特殊召唤成功时才能发动。从卡组把1只「炎星」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30929786,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,30929786)
	e1:SetCondition(c30929786.thcon)
	e1:SetTarget(c30929786.thtg)
	e1:SetOperation(c30929786.thop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把自己场上1张表侧表示的「炎舞」魔法·陷阱卡送去墓地才能发动。从卡组选1张「炎舞」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30929786,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c30929786.setcost)
	e2:SetTarget(c30929786.settg)
	e2:SetOperation(c30929786.setop)
	c:RegisterEffect(e2)
end
-- 确认这张卡是否满足「用「炎星」怪兽的效果特殊召唤成功」的发动条件：检查此次特殊召唤的信息为怪兽效果，且进行特殊召唤的卡拥有「炎星」字段。
function c30929786.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x79)
end
-- 检索过滤器：卡组中持有「炎星」字段的怪兽卡，且能够加入手卡。
function c30929786.thfilter(c)
	return c:IsSetCard(0x79) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动时点检查：若卡组存在符合条件的「炎星」怪兽则满足发动条件，并设置本效果为从卡组将1张卡加入手卡的操作信息。
function c30929786.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在至少1张满足thfilter过滤条件的「炎星」怪兽，用于①的发动条件判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c30929786.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：标记本效果将处理从卡组把1张「炎星」怪兽加入手卡的分类，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1张「炎星」怪兽加入手卡，并向对方展示确认。
function c30929786.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中筛选并选择1张满足thfilter条件的「炎星」怪兽。
	local g=Duel.SelectMatchingCard(tp,c30929786.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 代价过滤器：己方场上表侧表示且持有「炎舞」字段的魔法·陷阱卡，并可作为代价送入墓地。
function c30929786.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
-- ②效果的代价处理：计算魔陷区可用空格；若通常代价不满足，但鹫真人效果适用且有空格可盖放也可发动；实际支付代价时选择1张表侧「炎舞」卡送去墓地，或在鹫真人适用时选择不送卡发动。
function c30929786.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上魔陷区（含场地区）当前可用的空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 若卡组中存在可盖放的「炎舞」场地魔法卡，则将可用空格数加1（因为场地魔法卡可盖放在场地区，不占用通常魔陷区空格）。
	if Duel.IsExistingMatchingCard(c30929786.filter2,tp,LOCATION_DECK,0,1,nil) then ft=ft+1 end
	-- 在代价检查阶段（chk==0）判定：存在至少1张表侧「炎舞」魔法·陷阱卡可作为代价，或者鹫真人效果适用且有空位可盖放，则满足②的发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c30929786.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		or (Duel.IsPlayerAffectedByEffect(tp,46241344) and ft>0) end
	-- 实际支付代价时判断是否存在可送墓的表侧「炎舞」魔法·陷阱卡，以决定是否必须送墓。
	if Duel.IsExistingMatchingCard(c30929786.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		and (not Duel.IsPlayerAffectedByEffect(tp,46241344) or ft<=0 or not Duel.SelectYesNo(tp,aux.Stringid(46241344,0))) then  --"是否不把卡送去墓地发动？"
		-- 显示选择提示：请选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择1张满足cfilter条件的表侧「炎舞」魔法·陷阱卡作为代价。
		local g=Duel.SelectMatchingCard(tp,c30929786.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 将选择的卡以代价原因送入墓地。
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- 盖放对象过滤器：卡组中的「炎舞」魔法·陷阱卡且可以盖放；chk参数表示是否忽略魔陷区空格限制（发动检查时用true，实际执行时用false）。
function c30929786.filter(c,chk)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(chk)
end
-- 判断是否为可盖放的「炎舞」场地魔法卡，用于计算场地区可用空格。
function c30929786.filter2(c)
	return c30929786.filter(c,false) and c:IsType(TYPE_FIELD)
end
-- ②效果发动目标检查：卡组中是否存在至少1张可以盖放的「炎舞」魔法·陷阱卡（检查时忽略区域限制以判断能否发动）。
function c30929786.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时判断卡组是否存在满足盖放条件的「炎舞」卡，用于决定②是否可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c30929786.filter,tp,LOCATION_DECK,0,1,nil,true) end
end
-- ②效果处理：从卡组选择1张「炎舞」魔法·陷阱卡在自己场上盖放。
function c30929786.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张满足盖放条件的「炎舞」魔法·陷阱卡（选择时检查实际能否盖放）。
	local g=Duel.SelectMatchingCard(tp,c30929786.filter,tp,LOCATION_DECK,0,1,1,nil,false)
	if g:GetCount()>0 then
		-- 将选择的卡以里侧表示盖放到自己的魔法与陷阱区域（或场地区域）。
		Duel.SSet(tp,g:GetFirst())
	end
end

--星宵竜転
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上1只融合·同调·超量·连接怪兽为对象才能发动。那只表侧表示怪兽回到额外卡组。那之后，可以把回去的怪兽种类（融合·同调·超量·连接）对应的1只以下怪兽从自己·对方的墓地往自己场上特殊召唤。
-- ●融合：和回去的怪兽相同属性的怪兽
-- ●同调：比回去的怪兽等级低的怪兽
-- ●超量：持有和回去的怪兽的阶级相同数值的等级的怪兽
-- ●连接：和回去的怪兽相同种族的怪兽
local s,id,o=GetID()
-- 注册卡片效果：此卡名的卡在1回合只能发动1张，①效果为自由时点发动的魔法卡效果，涉及回额外卡组、特殊召唤及墓地特殊召唤。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以场上1只融合·同调·超量·连接怪兽为对象才能发动。那只表侧表示怪兽回到额外卡组。那之后，可以把回去的怪兽种类（融合·同调·超量·连接）对应的1只以下怪兽从自己·对方的墓地往自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示且可以回到额外卡组的融合、同调、超量、连接怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:IsAbleToExtra()
end
-- 效果发动时的目标选择与处理：检查并选择场上一只符合条件的融合、同调、超量或连接怪兽作为对象，并设置操作信息为回额外卡组。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查场上是否存在至少1只符合条件的融合、同调、超量或连接怪兽作为可选对象。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回额外卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择场上1只表侧表示的融合、同调、超量或连接怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果包含将选中的1张卡送回额外卡组的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- 过滤墓地中满足特定条件（由参数f决定）且可以被特殊召唤的怪兽。
function s.sfilter(c,e,tp,f)
	return f(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：获取对象怪兽，若其仍适用效果则将其送回额外卡组，并检查是否满足后续特殊召唤的场地条件。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用效果，并将其送回额外卡组。
	if not (tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)>0
		-- 确认对象怪兽已回到额外卡组，且自己场上有可用的怪兽区域，否则结束效果处理。
		and tc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) then return end
	-- 初始化用于筛选特殊召唤怪兽的过滤函数，默认不匹配任何卡片。
	local f=aux.FALSE
	local typ=tc:GetType()&TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK
	-- 若回去的怪兽是融合怪兽，则筛选与其相同属性的怪兽。
	if typ==TYPE_FUSION then f=aux.FilterEqualFunction(Card.GetAttribute,tc:GetAttribute())
	-- 若回去的怪兽是同调怪兽，则筛选比其等级低的怪兽。
	elseif typ==TYPE_SYNCHRO then f=aux.FilterBoolFunction(Card.IsLevelBelow,tc:GetLevel()-1)
	-- 若回去的怪兽是超量怪兽，则筛选等级与其阶级数值相同的怪兽。
	elseif typ==TYPE_XYZ then f=aux.FilterBoolFunction(Card.IsLevel,tc:GetRank())
	-- 若回去的怪兽是连接怪兽，则筛选与其相同种族的怪兽。
	elseif typ==TYPE_LINK then f=aux.FilterEqualFunction(Card.GetRace,tc:GetRace()) end
	-- 获取双方墓地中满足对应过滤条件且可以特殊召唤的怪兽。
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,f)
	-- 若存在符合条件的怪兽，询问玩家是否进行特殊召唤。
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 中断当前效果处理，使后续的特殊召唤不与回额外卡组视为同时处理。
		Duel.BreakEffect()
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end

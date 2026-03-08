--同胞の絆
-- 效果：
-- 这张卡发动的回合，自己不能进行战斗阶段。
-- ①：支付2000基本分，以自己场上1只4星以下的怪兽为对象才能发动。和那只怪兽是卡名不同并是种族·属性·等级相同的2只怪兽从卡组特殊召唤（同名卡最多1张）。这张卡的发动后，直到回合结束时自己不能把怪兽特殊召唤。
function c40450317.initial_effect(c)
	-- 效果定义：此卡发动时，自身不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c40450317.cost)
	e1:SetTarget(c40450317.target)
	e1:SetOperation(c40450317.activate)
	c:RegisterEffect(e1)
end
-- 支付2000基本分，以自己场上1只4星以下的怪兽为对象才能发动。
function c40450317.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2000基本分且当前回合未进入战斗阶段。
	if chk==0 then return Duel.CheckLPCost(tp,2000) and Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 支付2000基本分。
	Duel.PayLPCost(tp,2000)
	-- 将效果注册给玩家，使该玩家在本回合不能进入战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能进入战斗阶段的效果。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：检查目标怪兽是否满足条件（4星以下且卡组中有符合条件的怪兽）。
function c40450317.filter(c,e,tp)
	if c:IsFacedown() or not c:IsLevelBelow(4) then return false end
	-- 获取满足条件的卡组怪兽集合。
	local g=Duel.GetMatchingGroup(c40450317.filter2,tp,LOCATION_DECK,0,nil,e,tp,c)
	return g:GetClassCount(Card.GetCode)>1
end
-- 过滤函数：检查卡组中的怪兽是否与目标怪兽种族、属性、等级相同且卡名不同。
function c40450317.filter2(c,e,tp,tc)
	return c:IsLevel(tc:GetLevel()) and c:IsRace(tc:GetRace()) and c:IsAttribute(tc:GetAttribute())
		and not c:IsCode(tc:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标：选择场上1只满足条件的怪兽作为对象。
function c40450317.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40450317.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有足够的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查场上是否存在满足条件的怪兽作为对象。
		and Duel.IsExistingTarget(c40450317.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只满足条件的怪兽作为对象。
	Duel.SelectTarget(tp,c40450317.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：准备特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：检索满足条件的怪兽并特殊召唤。
function c40450317.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取满足条件的卡组怪兽集合。
	local g=Duel.GetMatchingGroup(c40450317.filter2,tp,LOCATION_DECK,0,nil,e,tp,tc)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and ft>1 and g:GetClassCount(Card.GetCode)>1 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从符合条件的怪兽中选择2张卡名不同的怪兽。
		local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 发动后，直到回合结束时自己不能把怪兽特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(1,0)
		-- 注册不能特殊召唤的效果。
		Duel.RegisterEffect(e1,tp)
	end
end

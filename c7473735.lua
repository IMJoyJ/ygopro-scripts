--異界共鳴－シンクロ・フュージョン
--not fully implemented
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是融合·同调怪兽不能从额外卡组特殊召唤。
-- ①：把自己场上的表侧表示的调整和调整以外的怪兽各1只送去墓地才能发动。以下怪兽各1只从额外卡组特殊召唤。
-- ●墓地的那2只怪兽为素材可以同调召唤的同调怪兽
-- ●墓地的那2只怪兽为素材可以融合召唤的融合怪兽
local s,id,o=GetID()
-- 定义卡片效果初始化函数，创建并注册魔法卡的发动效果，并添加自定义特殊召唤计数器。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，①：把自己场上的表侧表示的调整和调整以外的怪兽各1只送去墓地才能发动。以下怪兽各1只从额外卡组特殊召唤。●墓地的那2只怪兽为素材可以同调召唤的同调怪兽●墓地的那2只怪兽为素材可以融合召唤的融合怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 添加自定义活动计数器，用于检测本回合是否进行了非融合·同调怪兽从额外卡组的特殊召唤。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.rfilter)
end
-- 过滤函数：判断怪兽是否不是从额外卡组特殊召唤，或者是融合·同调怪兽。
function s.rfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION+TYPE_SYNCHRO)
end
-- 过滤函数：选择自己场上表侧表示且能作为代价送去墓地的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
-- 过滤函数：选择额外卡组中可以被特殊召唤的融合或同调怪兽。
function s.filter(c,e,tp)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数：判断怪兽是否为非调整怪兽。
function s.xfilter(c)
	return not c:IsType(TYPE_TUNER)
end
-- 检查选定的2只怪兽是否包含调整和非调整，且额外怪兽区域是否足够，并能作为素材同调召唤和融合召唤对应的怪兽。
function s.chk(g,e,tp)
	if not (g:IsExists(Card.IsType,1,nil,TYPE_TUNER) and g:IsExists(s.xfilter,1,nil)
		-- 检查在将这2只怪兽送去墓地后，额外卡组的融合怪兽是否有可用的特殊召唤区域。
		and Duel.GetLocationCountFromEx(tp,tp,g,TYPE_FUSION)
		-- 并且额外卡组的同调怪兽也有可用区域，且总共可用的额外怪兽区域数量大于1（因为要同时特召2只）。
		&Duel.GetLocationCountFromEx(tp,tp,g,TYPE_SYNCHRO)>1) then return false end
	-- 获取额外卡组中所有满足特殊召唤条件的融合和同调怪兽。
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	return sg:IsExists(Card.CheckFusionMaterial,1,nil,g)
		and sg:IsExists(Card.IsSynchroSummonable,1,nil,nil,g)
end
-- 代价处理函数：检查场上是否存在符合条件的怪兽作为代价，以及本回合是否满足额外卡组特殊召唤限制。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有表侧表示且能送去墓地的怪兽。
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return mg:CheckSubGroup(s.chk,2,2,e,tp)
		-- 检查本回合自己是否没有从额外卡组特殊召唤过融合·同调以外的怪兽。
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=mg:SelectSubGroup(tp,s.chk,false,2,2,e,tp)
	-- 将选中的2只怪兽作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	g:KeepAlive()
	e:SetLabelObject(g)
	-- 这张卡发动的回合，自己不是融合·同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制效果，使玩家在本回合不能从额外卡组特殊召唤融合·同调以外的怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 限制过滤函数：阻止从额外卡组特殊召唤非融合且非同调的怪兽。
function s.limit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION+TYPE_SYNCHRO)
end
-- 目标处理函数：保存作为代价送去墓地的怪兽信息，并设置特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return e:IsCostChecked() and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	local g=e:GetLabelObject()
	-- 将作为代价送去墓地的2只怪兽设为效果处理的对象。
	Duel.SetTargetCard(g)
	g:DeleteGroup()
	-- 设置特殊召唤的操作信息，表示将从额外卡组特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_EXTRA)
end
-- 效果处理函数：从额外卡组特殊召唤符合条件的融合怪兽和同调怪兽各1只。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在墓地中与当前连锁相关的素材怪兽。
	local mg=Duel.GetTargetsRelateToChain()
	-- 检查素材怪兽是否仍有2只，以及额外卡组怪兽的特殊召唤区域是否足够。
	if #mg<2 or Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)&Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_SYNCHRO)<2
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取额外卡组中所有可以特殊召唤的融合和同调怪兽。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的融合怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local fg=g:FilterSelect(tp,Card.CheckFusionMaterial,1,1,nil,mg)
	-- 提示玩家选择要特殊召唤的同调怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:FilterSelect(tp,Card.IsSynchroSummonable,1,1,fg,nil,mg)
	if #fg>0 and #sg>0 then
		-- 将选中的融合怪兽和同调怪兽在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(fg+sg,0,tp,tp,false,false,POS_FACEUP)
	end
end

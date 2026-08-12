--希望の天啓
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示的龙族·8星怪兽送去墓地才能发动。把1只龙族·8阶的超量怪兽当作超量召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化效果：创建魔法卡发动效果e1，设置描述为「发动」，分类为特殊召唤，类型为魔法卡发动，自由时点，设置同名卡1回合1次（誓约），并绑定代价、目标、处理函数后注册到卡片上
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只表侧表示的龙族·8星怪兽送去墓地才能发动。把1只龙族·8阶的超量怪兽当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 特召过滤器：判断卡片是否为龙族·8阶的超量怪兽，且能以超量召唤方式特殊召唤，并且从额外卡组特殊召唤时有可用的怪兽区空格
function s.spfilter(c,e,tp,lc)
	return c:IsType(TYPE_XYZ) and c:IsRace(RACE_DRAGON)
		-- 判断卡片是否为8阶、能否被此效果以超量召唤方式特殊召唤，以及在让指定卡离场后从额外卡组特召该卡是否有可用的怪兽区空格
		and c:IsRank(8) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,lc,c)>0
end
-- 代价过滤器：判断怪兽是否为表侧表示的龙族·8星怪兽、能否作为代价送去墓地，且其离场后额外卡组存在满足条件的可特召超量怪兽
function s.costfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsLevel(8)
		and c:IsAbleToGraveAsCost()
		-- 确认自己额外卡组存在至少1只在送去该怪兽后能以超量召唤方式特殊召唤的龙族·8阶超量怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 代价处理：检查场上是否存在满足条件的龙族·8星怪兽，提示玩家选择并选择1只送去墓地作为发动代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检测：确认自己主要怪兽区存在至少1只满足代价条件的表侧表示龙族·8星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家「请选择要送去墓地的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己主要怪兽区选择1只满足条件的表侧表示龙族·8星怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 把选择的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标函数：发动前检测是否没有必须作为超量素材的限制影响，且代价已确认或额外卡组存在满足条件的可特召超量怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检测：确认玩家没有受到「必须作为超量素材」类效果的影响
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 确认代价已检测，或额外卡组存在至少1只满足条件的可超量召唤特殊召唤的龙族·8阶超量怪兽
		and (e:IsCostChecked() or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)) end
	-- 设置操作信息：本次连锁将执行从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：确认没有超量素材限制后，提示并让玩家从额外卡组选择1只龙族·8阶超量怪兽，将其以超量召唤方式表侧表示特殊召唤并完成正规召唤手续
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认玩家没有受到「必须作为超量素材」类效果的影响，否则中止处理
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 提示玩家「请选择要特殊召唤的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的龙族·8阶超量怪兽，并取出该卡
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 把该怪兽当作超量召唤以表侧表示特殊召唤到自己场上，成功后完成正规召唤手续
	if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end

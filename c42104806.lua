--希望の天啓
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示的龙族·8星怪兽送去墓地才能发动。把1只龙族·8阶的超量怪兽当作超量召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片发动、送墓场上龙族8星怪兽作为Cost、并从额外卡组超量召唤龙族8阶超量怪兽的效果
function s.initial_effect(c)
	-- ①：把自己场上1只表侧表示的龙族·8星怪兽送去墓地才能发动。把1只龙族·8阶的超量怪兽当作超量召唤从额外卡组特殊召唤。
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
-- 额外卡组中可作为超量召唤特殊召唤的龙族·8阶超量怪兽的过滤与区域判断条件
function s.spfilter(c,e,tp,lc)
	return c:IsType(TYPE_XYZ) and c:IsRace(RACE_DRAGON)
		-- 检查自己额外卡组是否有龙族8阶超量怪兽且该区域是否有空闲怪兽格
		and c:IsRank(8) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,lc,c)>0
end
-- 场上表侧表示存在的、可作为发动Cost送去墓地的龙族·8星怪兽的过滤条件
function s.costfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsLevel(8)
		and c:IsAbleToGraveAsCost()
		-- 且要求卡组存在可用此卡送墓后超量召唤的目标怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 送墓场上1只表侧表示龙族8星怪兽作为效果发动的代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在符合Cost条件的龙族·8星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送提示，请选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1只龙族·8星怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选中的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 魔法卡发动时的可行性检查与必须材料检测
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否受到必须超量素材限制效果的影响
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否拥有可特殊召唤的龙族·8阶超量怪兽
		and (e:IsCostChecked() or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)) end
	-- 设置操作信息为从额外卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 从额外卡组将龙族·8阶超量怪兽当作超量召唤特殊召唤效果的执行
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认是否符合玩家的必须超量素材限制
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 向玩家提示选择需要从额外卡组召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合条件的龙族·8阶超量怪兽
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 若该超量怪兽特殊召唤成功，则为其注册正规的超量召唤召唤状态完毕手续
	if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end

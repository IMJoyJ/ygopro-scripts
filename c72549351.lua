--ドラゴニック・タクティクス
-- 效果：
-- 把自己场上存在的2只龙族怪兽解放发动。从自己卡组把1只8星的龙族怪兽特殊召唤。
function c72549351.initial_effect(c)
	-- 把自己场上存在的2只龙族怪兽解放发动。从自己卡组把1只8星的龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c72549351.cost)
	e1:SetTarget(c72549351.target)
	e1:SetOperation(c72549351.activate)
	c:RegisterEffect(e1)
end
-- 过滤可解放的龙族怪兽（自己场上的龙族怪兽，或者对方场上表侧表示的龙族怪兽，用于兼容类似暗影敌托邦的代替解放效果）
function c72549351.rfilter(c,tp)
	return c:IsRace(RACE_DRAGON) and (c:IsControler(tp) or c:IsFaceup())
end
-- 发动代价：解放自己场上的2只龙族怪兽
function c72549351.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 获取玩家可解放的卡片组，并过滤出符合条件的龙族怪兽
	local rg=Duel.GetReleaseGroup(tp):Filter(c72549351.rfilter,nil,tp)
	-- 检查是否存在2只解放后能空出足够怪兽区域用于特殊召唤的怪兽
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择2只满足解放后有空位条件的怪兽
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 扣除类似暗影敌托邦等代替解放效果的使用次数
	aux.UseExtraReleaseCount(g,tp)
	-- 将选中的怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 过滤卡组中可以特殊召唤的8星龙族怪兽
function c72549351.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标确认与操作信息设置
function c72549351.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有空位（如果是刚支付了解放代价，则视为已有空位）
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查卡组中是否存在可以特殊召唤的8星龙族怪兽
		return res and Duel.IsExistingMatchingCard(c72549351.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置当前处理的连锁的操作信息为“从卡组特殊召唤1只怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组特殊召唤1只8星龙族怪兽
function c72549351.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只符合条件的8星龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c72549351.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

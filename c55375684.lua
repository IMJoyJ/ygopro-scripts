--召喚雲
-- 效果：
-- 自己场上没有怪兽存在的场合，可以从自己的手卡或者墓地把1只4星以下的名字带有「云魔物」的怪兽特殊召唤。这个效果1回合只有1次在自己的主要阶段才能使用。从墓地特殊召唤的场合这张卡破坏。
function c55375684.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上没有怪兽存在的场合，可以从自己的手卡或者墓地把1只4星以下的名字带有「云魔物」的怪兽特殊召唤。这个效果1回合只有1次在自己的主要阶段才能使用。从墓地特殊召唤的场合这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55375684,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c55375684.condition)
	e2:SetTarget(c55375684.target)
	e2:SetOperation(c55375684.operation)
	c:RegisterEffect(e2)
end
-- 定义效果发动条件：自己场上没有怪兽存在
function c55375684.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤条件：手卡或墓地中等级4以下且名字带有「云魔物」的可特殊召唤的怪兽
function c55375684.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x18) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果发动的目标选择与合法性检测
function c55375684.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或墓地是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c55375684.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为：从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 定义效果处理：从手卡或墓地特殊召唤1只「云魔物」怪兽，若从墓地特殊召唤则破坏此卡
function c55375684.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时，若自己场上已存在怪兽则不处理
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的怪兽（适用王家长眠之谷的过滤效果）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c55375684.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local grav=g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 如果特殊召唤的怪兽原本存在于墓地，则将这张卡破坏
		if grav then Duel.Destroy(e:GetHandler(),REASON_EFFECT) end
	end
end

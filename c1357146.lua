--粋カエル
-- 效果：
-- 这张卡不能作为同调素材。
-- ①：这张卡只要在怪兽区域存在，卡名当作「死亡青蛙」使用。
-- ②：这张卡在墓地存在的场合，从自己墓地把1只「青蛙」怪兽除外才能发动。这张卡特殊召唤。
function c1357146.initial_effect(c)
	-- 注册卡片在怪兽区卡名当作「死亡青蛙」使用的永续效果。
	aux.EnableChangeCode(c,84451804)
	-- ②：这张卡在墓地存在的场合，从自己墓地把1只「青蛙」怪兽除外才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1357146,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c1357146.cost)
	e2:SetTarget(c1357146.target)
	e2:SetOperation(c1357146.operation)
	c:RegisterEffect(e2)
	-- 这张卡不能作为同调素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 用于筛选墓地中可作为发动代价除外的「青蛙」怪兽卡的过滤函数。
function c1357146.costfilter(c)
	return c:IsSetCard(0x12) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动代价处理函数，用于从自己墓地除外1只「青蛙」怪兽。
function c1357146.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己墓地是否存在至少1张可以作为发动代价除外的「青蛙」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c1357146.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发送系统提示信息，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地中选择1张符合过滤条件的「青蛙」怪兽。
	local g=Duel.SelectMatchingCard(tp,c1357146.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡作为发动代价表侧表示除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动判定与目标确认函数，检查自己场上是否有空怪兽区域以及此卡能否特殊召唤。
function c1357146.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家的怪兽区是否还有可用的格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，声明当前效果的处理包含特殊召唤此卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，若此卡在效果处理时仍与当前连锁相关联，则将其在自己场上表侧表示特殊召唤。
function c1357146.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到玩家自己的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

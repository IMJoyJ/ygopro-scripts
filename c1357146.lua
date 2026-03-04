--粋カエル
-- 效果：
-- 这张卡不能作为同调素材。
-- ①：这张卡只要在怪兽区域存在，卡名当作「死亡青蛙」使用。
-- ②：这张卡在墓地存在的场合，从自己墓地把1只「青蛙」怪兽除外才能发动。这张卡特殊召唤。
function c1357146.initial_effect(c)
	-- 使该卡在怪兽区域存在时卡号视为「死亡青蛙」（84451804）
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
	-- ①：这张卡只要在怪兽区域存在，卡名当作「死亡青蛙」使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 定义用于判断除外代价的卡片过滤器，筛选墓地中的青蛙族怪兽
function c1357146.costfilter(c)
	return c:IsSetCard(0x12) and c:IsAbleToRemoveAsCost()
end
-- 定义效果的除外代价处理函数，检查并选择1只青蛙族怪兽除外
function c1357146.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家墓地是否存在至少1只青蛙族怪兽可作为除外代价
	if chk==0 then return Duel.IsExistingMatchingCard(c1357146.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择1只满足条件的青蛙族怪兽作为除外代价
	local g=Duel.SelectMatchingCard(tp,c1357146.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的青蛙族怪兽从墓地除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义效果的目标选择处理函数，判断是否可以发动特殊召唤
function c1357146.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，指定本次效果将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果的发动处理函数，执行特殊召唤操作
function c1357146.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以正面表示特殊召唤到玩家场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

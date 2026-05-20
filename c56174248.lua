--魔導鬼士 ディアール
-- 效果：
-- 这张卡在墓地存在的场合，把自己墓地3张名字带有「魔导书」的魔法卡从游戏中除外才能发动。这张卡从墓地特殊召唤。
function c56174248.initial_effect(c)
	-- 这张卡在墓地存在的场合，把自己墓地3张名字带有「魔导书」的魔法卡从游戏中除外才能发动。这张卡从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56174248,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(c56174248.spcost)
	e1:SetTarget(c56174248.sptg)
	e1:SetOperation(c56174248.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为名字带有「魔导书」的魔法卡，且可以作为代价除外
function c56174248.rfilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：从自己墓地选择3张「魔导书」魔法卡除外
function c56174248.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己墓地是否存在至少3张满足条件的「魔导书」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c56174248.rfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 发送提示信息，要求玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择3张满足条件的「魔导书」魔法卡
	local g=Duel.SelectMatchingCard(tp,c56174248.rfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 将选中的卡片作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 发动目标：检查自身是否可以特殊召唤，并设置特殊召唤的操作信息
function c56174248.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，将1张自身卡片作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身从墓地特殊召唤到场上
function c56174248.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域，若没有则不进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

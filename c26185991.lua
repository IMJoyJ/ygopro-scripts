--代打バッター
-- 效果：
-- ①：这张卡从自己场上送去墓地时才能发动。从手卡把1只昆虫族怪兽特殊召唤。
function c26185991.initial_effect(c)
	-- ①：这张卡从自己场上送去墓地时才能发动。从手卡把1只昆虫族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26185991,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c26185991.condition)
	e1:SetTarget(c26185991.target)
	e1:SetOperation(c26185991.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：确认触发效果的这张卡在送去墓地之前，其控制者为发动玩家，且所在位置为场上。
function c26185991.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousControler(tp) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 特殊召唤候选过滤：从手卡中筛选出昆虫族怪兽，且该怪兽能够被当前效果特殊召唤。
function c26185991.filter(c,e,sp)
	return c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果发动时的合法条件检查：只有在自己的主要怪兽区存在可用空格，且手卡中存在至少1只满足条件的昆虫族怪兽时，效果才能发动。
function c26185991.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只昆虫族且可被特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c26185991.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设定效果处理信息：本次连锁将进行1只昆虫族怪兽从手卡的特殊召唤，操作者为发动玩家，来源区域为手卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若场上仍有可用怪兽区，则选择手卡中的1只昆虫族怪兽并将其特殊召唤。
function c26185991.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认主要怪兽区仍有空格；若没有空位则效果处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向发动玩家弹出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足条件的昆虫族怪兽作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c26185991.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

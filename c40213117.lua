--魔導弓士 ラムール
-- 效果：
-- 1回合1次，把手卡1张名字带有「魔导书」的魔法卡给对方观看才能发动。从手卡把1只4星以下的魔法师族怪兽特殊召唤。
function c40213117.initial_effect(c)
	-- 1回合1次，把手卡1张名字带有「魔导书」的魔法卡给对方观看才能发动。从手卡把1只4星以下的魔法师族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40213117,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c40213117.spcost)
	e1:SetTarget(c40213117.sptg)
	e1:SetOperation(c40213117.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：从手卡中筛选出名字带有「魔导书」的魔法卡，且该卡当前不是公开状态，作为展示代价的候选。
function c40213117.cffilter(c)
	return c:IsSetCard(0x106e) and c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 效果的发动代价（Cost）：需要玩家从手卡选择1张满足过滤条件的「魔导书」魔法卡，给对方玩家确认，然后洗切手卡。
function c40213117.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：在效果发动时（chk==0）检查自己手卡中是否至少存在1张满足cffilter的「魔导书」魔法卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c40213117.cffilter,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家显示选择提示：请选择给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从自己的手卡中选出1张满足cffilter的「魔导书」魔法卡，作为展示给对方确认的代价。
	local g=Duel.SelectMatchingCard(tp,c40213117.cffilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选出的手卡展示给对方玩家确认，完成“给对方观看”这一发动条件。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切自己的手卡，使对方无法凭借展示过程确定手牌顺序。
	Duel.ShuffleHand(tp)
end
-- 特殊召唤对象的过滤函数：判断手卡中的卡是否为4星以下、魔法师族，并且可以被当前效果特殊召唤。
function c40213117.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标选择函数：在发动时确认自己场上是否有空余怪兽区，且手卡中存在满足条件的可特殊召唤的魔法师族怪兽。
function c40213117.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检测：检查自己的主要怪兽区是否存在可用的空格，只有存在空格才可发动/处理特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 目标检测：检查手卡中是否存在至少1只满足filter条件的魔法师族怪兽（4星以下且可被特殊召唤）。
		and Duel.IsExistingMatchingCard(c40213117.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：将本次连锁的操作类别标记为特殊召唤，预定从手卡特殊召唤1只怪兽，目标玩家为自己。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：实际执行特殊召唤操作，包括再次确认空位、选择手卡中的怪兽并以表侧表示特殊召唤。
function c40213117.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次检查自己场上是否有空余怪兽区，若没有空位则本次效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡中选择1只满足filter条件的怪兽（4星以下魔法师族且可特殊召唤），作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c40213117.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的怪兽区，完成特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

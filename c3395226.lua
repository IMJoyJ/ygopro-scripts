--幻奏の音姫プロディジー・モーツァルト
-- 效果：
-- 这张卡的效果发动的回合，自己不能把光属性以外的怪兽特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。从手卡把1只天使族·光属性怪兽特殊召唤。
function c3395226.initial_effect(c)
	-- 这张卡的效果发动的回合，自己不能把光属性以外的怪兽特殊召唤。①：1回合1次，自己主要阶段才能发动。从手卡把1只天使族·光属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3395226,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c3395226.spcost)
	e1:SetTarget(c3395226.sptg)
	e1:SetOperation(c3395226.spop)
	c:RegisterEffect(e1)
	-- 注册一个特殊召唤活动计数器，用于统计己方本回合特殊召唤的非光属性怪兽（若特殊召唤的怪兽不是光属性则计数加1），以便发动时检查是否已触发过自肃。
	Duel.AddCustomActivityCounter(3395226,ACTIVITY_SPSUMMON,c3395226.counterfilter)
end
-- 计数器过滤函数：若怪兽是光属性则返回true（不计数），否则返回false（计数增加），用于实现“光属性以外的怪兽特殊召唤”的计数。
function c3395226.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 发动①的代价处理：检查本回合尚未特殊召唤过非光属性怪兽；若满足，则给己方场上注册一个持续到结束阶段的誓约自肃效果，禁止自己特殊召唤光属性以外的怪兽。
function c3395226.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：若己方本回合特殊召唤非光属性怪兽的次数为0，则允许发动该效果。
	if chk==0 then return Duel.GetCustomActivityCount(3395226,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡的效果发动的回合，自己不能把光属性以外的怪兽特殊召唤。①：1回合1次，自己主要阶段才能发动。从手卡把1只天使族·光属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c3395226.splimit)
	-- 将创建的自肃效果注册到对局中，使己方玩家在本回合内受到“不能特殊召唤光属性以外怪兽”的限制。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制判定函数：当要被特殊召唤的怪兽属性不是光属性时返回true（禁止召唤），从而禁止非光属性怪兽特殊召唤。
function c3395226.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetAttribute()~=ATTRIBUTE_LIGHT
end
-- 选择/检索条件：手卡中的怪兽需同时满足天使族、光属性，且能够被当前效果特殊召唤（符合苏生限制和召唤条件）。
function c3395226.filter(c,e,tp)
	return c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时点（目标函数）：检查己方主要怪兽区是否有空位，并且手卡中存在至少1只满足filter的怪兽，以此决定效果能否发动；发动后设置特殊召唤的处理信息。
function c3395226.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有可用空格，无空格则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1张满足 filter（天使族·光属性且可特殊召唤）的怪兽卡。
		and Duel.IsExistingMatchingCard(c3395226.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：声明该效果为特殊召唤类别，预计从手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若仍有主要怪兽区空格，则从手卡选择1只满足filter的怪兽，将其表侧表示特殊召唤到自己场上。
function c3395226.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若己方主要怪兽区已无空位，则不再进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给出选择提示，提示玩家从手卡选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手卡中恰好1张满足filter条件的怪兽（天使族·光属性且可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c3395226.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--黒炎の剣士－ブラック・フレア・ソードマン－
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把1只「炎之剑士」或者有那个卡名记述的怪兽从额外卡组送去墓地才能发动。这张卡从手卡特殊召唤。这个回合，自己不用战士族怪兽不能攻击宣言。
-- ②：这张卡的战斗发生的对自己的战斗伤害变成0。
-- ③：自己·对方回合，把这张卡解放才能发动。把6星以外的有「炎之剑士」的卡名记述的1只怪兽从卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 注册该卡记述了「炎之剑士」的卡片密码
	aux.AddCodeList(c,45231177)
	-- ①：把1只「炎之剑士」或者有那个卡名记述的怪兽从额外卡组送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合，把这张卡解放才能发动。把6星以外的有「炎之剑士」的卡名记述的1只怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"从卡组特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.spcost1)
	e3:SetTarget(s.sptg1)
	e3:SetOperation(s.spop1)
	c:RegisterEffect(e3)
end
-- 过滤额外卡组中「炎之剑士」或记述了该卡名的、且能作为代价送去墓地的怪兽
function s.costfilter(c)
	-- 检查卡片是否为「炎之剑士」或记述了该卡名，且能作为代价送去墓地
	return (c:IsCode(45231177) or aux.IsCodeListed(c,45231177)) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价处理函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在满足条件的卡作为发动代价
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从额外卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的发动检测处理函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域，且手牌中的这张卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不用战士族怪兽不能攻击宣言。自己·对方回合，把这张卡解放才能发动。把6星以外的有「炎之剑士」的卡名记述的1只怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在玩家身上注册不能攻击宣言的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤非战士族的怪兽，使其不能进行攻击宣言
function s.atktg(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
-- 效果③的发动代价处理函数
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查这张卡是否可以解放，且解放后是否有空余的怪兽区域用于特殊召唤
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 解放这张卡作为发动代价
	Duel.Release(c,REASON_COST)
end
-- 过滤卡组中记述了「炎之剑士」且非6星、可以特殊召唤的怪兽
function s.filter(c,e,tp)
	-- 检查卡片是否记述了「炎之剑士」，且可以特殊召唤，且等级不是6星
	return aux.IsCodeListed(c,45231177) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsLevel(6)
end
-- 效果③的发动检测处理函数
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足特殊召唤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向对方玩家提示本效果的发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理函数
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

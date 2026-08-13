--コート・オブ・ジャスティス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只天使族怪兽特殊召唤。这个效果在自己场上有1星天使族怪兽存在的场合才能发动和处理。
function c24449083.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。从手卡把1只天使族怪兽特殊召唤。这个效果在自己场上有1星天使族怪兽存在的场合才能发动和处理。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24449083,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,24449083)
	e2:SetCondition(c24449083.condition)
	e2:SetTarget(c24449083.target)
	e2:SetOperation(c24449083.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为表侧表示的1星天使族，用于检查自己场上是否存在符合发动条件的怪兽。
function c24449083.cfilter(c)
	return c:IsFaceup() and c:IsLevel(1) and c:IsRace(RACE_FAIRY)
end
-- ①效果的发动条件：自己场上有表侧表示的1星天使族怪兽存在的场合才能发动。
function c24449083.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在1只以上满足cfilter的怪兽（表侧表示、等级1、天使族）。
	return Duel.IsExistingMatchingCard(c24449083.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：判断手卡怪兽是否为天使族，且能否被当前效果特殊召唤（需满足召唤条件与苏生限制）。
function c24449083.filter(c,e,sp)
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 发动时的合法检测与信息登记：确认手卡有可特殊召唤的天使族怪兽且自己主要怪兽区有空位；随后登记本次操作将从手卡特殊召唤1只怪兽。
function c24449083.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk=0）从手卡查找是否存在至少1张可被本效果特殊召唤的天使族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24449083.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 同时要求自己主要怪兽区有空格（至少1个可用怪兽区域）才能发动。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 登记连锁的操作信息：声明本效果处理时从手卡特殊召唤1只怪兽（数量1，持有者tp，位置手卡），供其他效果/时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：再次确认空位及自己场上仍有1星天使族怪兽，然后让玩家从手卡选择1只天使族怪兽，以表侧攻击表示特殊召唤到自己场上。
function c24449083.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次检查自己主要怪兽区是否有空位，若无则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理前再次确认自己场上仍有表侧表示的1星天使族怪兽（满足“存在场合才能处理”），若已没有则终止处理。
	if not Duel.IsExistingMatchingCard(c24449083.cfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	-- 发送“请选择要特殊召唤的卡”的选择提示，将选择消息缓存供下一步选卡使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1张满足filter（天使族且可特殊召唤）的怪兽，选择结果存入g，若没有可选卡则g为空组。
	local g=Duel.SelectMatchingCard(tp,c24449083.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区（不忽略召唤条件与苏生限制检查）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

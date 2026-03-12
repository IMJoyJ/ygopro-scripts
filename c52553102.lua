--ジュラック・アステロ
-- 效果：
-- 调整＋调整以外的恐龙族怪兽1只以上
-- ①：这张卡同调召唤的场合才能发动。从自己的卡组·墓地把1张「朱罗纪」魔法·陷阱卡在自己场上盖放。
-- ②：1回合1次，对方把怪兽特殊召唤之际，从自己墓地把2只恐龙族怪兽除外才能发动。那个无效，那些怪兽破坏。
-- ③：对方回合，从自己墓地把包含这张卡的2只「朱罗纪」怪兽除外才能发动。从额外卡组把1只「朱罗纪陨石兽」当作同调召唤作特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，注册同调召唤手续并设置三个诱发效果
function s.initial_effect(c)
	-- 为该卡添加编号17548456的卡片代码列表，用于识别其关联卡片
	aux.AddCodeList(c,17548456)
	-- 设置该卡的同调召唤条件为调整+调整以外的恐龙族怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_DINOSAUR),1)
	c:EnableReviveLimit()
	-- 效果①：这张卡同调召唤成功的场合才能发动。从自己的卡组·墓地把1张「朱罗纪」魔法·陷阱卡在自己场上盖放
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- 效果②：1回合1次，对方把怪兽特殊召唤之际，从自己墓地把2只恐龙族怪兽除外才能发动。那个无效，那些怪兽破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"无效并破坏"
	e2:SetCategory(CATEGORY_DISABLE_SUMMON|CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- 效果③：对方回合，从自己墓地把包含这张卡的2只「朱罗纪」怪兽除外才能发动。从额外卡组把1只「朱罗纪陨石兽」当作同调召唤作特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：确认该卡是否为同调召唤成功
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 盖放效果的过滤函数，筛选满足条件的「朱罗纪」魔法·陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x22) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果①的发动准备阶段，检查场上是否存在满足条件的卡片
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「朱罗纪」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 效果①的发动处理阶段，选择并盖放一张符合条件的卡
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的「朱罗纪」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行盖放操作
		Duel.SSet(tp,tc)
	end
end
-- 效果②的发动条件：确认是否为对方特殊召唤且当前无连锁处理中
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认是否为对方特殊召唤且当前无连锁处理中
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 除外费用的过滤函数，筛选满足条件的恐龙族怪兽
function s.discfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动准备阶段，检查场上是否存在满足条件的除外费用
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的除外费用
	if chk==0 then return Duel.IsExistingMatchingCard(s.discfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的恐龙族怪兽作为除外费用
	local g=Duel.SelectMatchingCard(tp,s.discfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 执行除外操作
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备阶段，设置操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 效果②的发动处理阶段，使召唤无效并破坏目标怪兽
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使召唤无效
	Duel.NegateSummon(eg)
	-- 破坏目标怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 效果③的发动条件：确认是否为对方回合
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 特殊召唤费用的过滤函数，筛选满足条件的「朱罗纪」怪兽
function s.cfilter(c)
	return c:IsSetCard(0x22) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果③的发动准备阶段，检查场上是否存在满足条件的除外费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在满足条件的除外费用
	if chk==0 then return s.cfilter(c) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 选择满足条件的「朱罗纪」怪兽作为除外费用
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 执行除外操作
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤目标的过滤函数，筛选「朱罗纪陨石兽」并确认可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCode(17548456) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 确认额外卡组是否有足够的位置进行特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果③的发动准备阶段，检查场上是否存在满足条件的特殊召唤目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足必须成为素材的条件
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查场上是否存在满足条件的特殊召唤目标
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果③的发动处理阶段，选择并特殊召唤目标怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足必须成为素材的条件
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「朱罗纪陨石兽」作为特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 执行特殊召唤操作
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
		end
	end
end

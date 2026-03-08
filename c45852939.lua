--蝕の双仔
-- 效果：
-- 4星怪兽×2
-- 这张卡超量召唤的场合，可以让自己场上的4阶怪兽作为4星怪兽来成为素材。这个卡名的②的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ②：这张卡被送去墓地的场合，以自己墓地2只其他的4阶以下的超量怪兽为对象才能发动。那2只之内的1只特殊召唤，另1只作为那只怪兽的超量素材。
local s,id,o=GetID()
-- 初始化效果函数，添加XYZ召唤手续并注册两个效果
function s.initial_effect(c)
	-- 为该卡添加XYZ召唤手续，允许使用满足条件的怪兽作为2个超量素材
	aux.AddXyzProcedureLevelFree(c,s.mfilter,nil,2,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"2次攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.xatkcon)
	e1:SetCost(s.xatkcost)
	e1:SetTarget(s.xatktg)
	e1:SetOperation(s.xatkop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以自己墓地2只其他的4阶以下的超量怪兽为对象才能发动。那2只之内的1只特殊召唤，另1只作为那只怪兽的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 超量素材过滤函数，判断怪兽是否为4星等级或4星阶级
function s.mfilter(c,xyzc)
	return c:IsXyzLevel(xyzc,4) or c:IsRank(4)
end
-- 效果发动条件，判断是否能进入战斗阶段
function s.xatkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否能进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 效果发动费用，扣除1个超量素材
function s.xatkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动时的处理，判断是否已拥有额外攻击次数
function s.xatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsHasEffect(EFFECT_EXTRA_ATTACK_MONSTER) end
end
-- 效果发动时的处理，为该卡添加额外攻击次数效果
function s.xatkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 为该卡添加额外攻击次数效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	end
end
-- 目标过滤函数，筛选可作为效果对象且等级不超过4的怪兽
function s.tgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsRankBelow(4)
		and (c:IsCanOverlay() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 特殊召唤过滤函数，筛选可特殊召唤且能作为叠放卡的怪兽
function s.spfilter(c,g,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:IsExists(Card.IsCanOverlay,1,c)
end
-- 子组选择函数，判断是否存在满足特殊召唤条件的怪兽组合
function s.fselect(g,e,tp)
	return g:IsExists(s.spfilter,1,nil,g,e,tp)
end
-- 特殊召唤效果的发动处理，选择2只怪兽作为目标并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取满足条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e,tp)
	if chkc then return false end
	-- 判断是否满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:CheckSubGroup(s.fselect,2,2,e,tp) end
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,2,2,e,tp)
	-- 设置当前连锁的目标卡
	Duel.SetTargetCard(sg)
	-- 设置操作信息，准备特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 特殊召唤效果的处理函数，选择1只怪兽特殊召唤并将其余怪兽叠放
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁相关的卡组
	local g=Duel.GetTargetsRelateToChain()
	if #g~=2 then return end
	local exg=nil
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 筛选不能被特殊召唤的怪兽
		exg=g:Filter(aux.NOT(Card.IsCanBeSpecialSummoned),nil,e,0,tp,false,false)
		if #exg==2 then exg=nil end
	end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local dc=g:FilterSelect(tp,aux.NecroValleyFilter(s.spfilter),1,1,exg,g,e,tp):GetFirst()
	if not dc then return end
	-- 执行特殊召唤操作
	if Duel.SpecialSummon(dc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		g:RemoveCard(dc)
		-- 将剩余怪兽叠放至特殊召唤的怪兽上
		Duel.Overlay(dc,g)
	end
end

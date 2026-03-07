--R－ACEインパルス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。选对方场上1只攻击力最高的效果怪兽。这个回合，双方不能把那只表侧表示怪兽的场上发动的效果发动。
-- ②：对方把怪兽的效果在场上发动时，把手卡·场上的这张卡解放才能发动。从卡组把1只机械族「救援ACE队」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册两个效果，①为起动效果，②为诱发即时效果
function s.initial_effect(c)
	-- ①：自己主要阶段才能发动。选对方场上1只攻击力最高的效果怪兽。这个回合，双方不能把那只表侧表示怪兽的场上发动的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.ntg)
	e1:SetOperation(s.nop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果在场上发动时，把手卡·场上的这张卡解放才能发动。从卡组把1只机械族「救援ACE队」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，判断是否为表侧表示的效果怪兽
function s.nfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- ①效果的发动条件判断，检查对方场上是否存在表侧表示的效果怪兽
function s.ntg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在表侧表示的效果怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.nfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- ①效果的处理，选择对方场上攻击力最高的效果怪兽并使其本回合不能发动效果
function s.nop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有表侧表示的效果怪兽
	local g=Duel.GetMatchingGroup(s.nfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMaxGroup(Card.GetAttack)
		local tc
		if tg:GetCount()>1 then
			-- 提示玩家选择一张表侧表示的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 显示所选卡被选为对象的动画效果
			Duel.HintSelection(sg)
			tc=sg:GetFirst()
		else
			-- 显示所选卡被选为对象的动画效果
			Duel.HintSelection(tg)
			tc=tg:GetFirst()
		end
		-- 使目标怪兽本回合不能发动效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
-- ②效果的发动条件，判断是否为对方在场上发动的怪兽效果
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
-- ②效果的解放费用处理，判断是否可以解放此卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否可以解放此卡
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 执行解放此卡的操作
	Duel.Release(c,REASON_COST)
end
-- 过滤函数，判断是否为「救援ACE队」机械族怪兽且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18b) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件判断，检查卡组中是否存在符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，提示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理，从卡组选择1只符合条件的怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有可用怪兽区
	if Duel.GetMZoneCount(tp)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只符合条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

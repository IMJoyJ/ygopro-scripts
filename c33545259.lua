--戦華の孟－曹徳
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：对方场上的卡被战斗·效果破坏的场合，把这张卡以外的自己的手卡·场上1张卡送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：只要自己场上有其他的「战华」怪兽存在，这张卡不会成为对方的效果的对象，不会被对方的效果破坏。
-- ③：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽在自己场上守备表示特殊召唤。
function c33545259.initial_effect(c)
	-- ①：对方场上的卡被战斗·效果破坏的场合，把这张卡以外的自己的手卡·场上1张卡送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33545259,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+33545259)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,33545259)
	e1:SetCondition(c33545259.spcon1)
	e1:SetCost(c33545259.spcost1)
	e1:SetTarget(c33545259.sptg1)
	e1:SetOperation(c33545259.spop1)
	c:RegisterEffect(e1)
	-- 只要自己场上有其他的「战华」怪兽存在，这张卡不会成为对方的效果的对象，不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c33545259.tgcon)
	-- 设置效果值为过滤函数aux.tgoval，用于判断是否不会成为对方的卡的效果对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果值为过滤函数aux.indoval，用于判断是否不会被对方的卡的效果破坏
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ③：这张卡战斗破坏对方怪兽送去墓地时才能发动。那只怪兽在自己场上守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(33545259,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetCountLimit(1,33545260)
	-- 设置效果条件为aux.bdogcon，用于检测是否为战斗破坏对方怪兽送去墓地的场合
	e4:SetCondition(aux.bdogcon)
	e4:SetTarget(c33545259.sptg2)
	e4:SetOperation(c33545259.spop2)
	c:RegisterEffect(e4)
	if not c33545259.global_check then
		c33545259.global_check=true
		-- 注册一个全局持续效果，用于监听卡片被破坏的事件并触发自定义事件
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c33545259.regcon)
		ge1:SetOperation(c33545259.regop)
		-- 将全局效果ge1注册给玩家0（即所有玩家）
		Duel.RegisterEffect(ge1,0)
	end
end
-- 定义regfilter函数，用于判断卡片是否因战斗或效果被破坏且之前在对方场上
function c33545259.regfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义regcon函数，用于检测被破坏的卡片是否满足regfilter条件并设置标签
function c33545259.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c33545259.regfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c33545259.regfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 定义regop函数，用于触发EVENT_CUSTOM+33545259事件并传递标签信息
function c33545259.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 以eg为对象，触发EVENT_CUSTOM+33545259事件，传递相关信息
	Duel.RaiseEvent(eg,EVENT_CUSTOM+33545259,re,r,rp,ep,e:GetLabel())
end
-- 定义spcon1函数，用于判断是否为对方场上的卡被破坏的场合
function c33545259.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return ev==1-tp or ev==PLAYER_ALL
end
-- 定义costfilter函数，用于筛选可以送去墓地作为费用的卡
function c33545259.costfilter(c,tp)
	-- 返回卡片可以送去墓地作为费用且玩家场上存在可用怪兽区
	return c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 定义spcost1函数，用于处理特殊召唤的费用，选择并送去墓地一张卡
function c33545259.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足costfilter条件，即存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c33545259.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,c,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足costfilter条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c33545259.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义sptg1函数，用于设置特殊召唤的处理信息
function c33545259.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义spop1函数，用于执行特殊召唤操作
function c33545259.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到玩家场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义cfilter函数，用于筛选场上存在的「战华」怪兽
function c33545259.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- 定义tgcon函数，用于判断是否满足条件（自己场上有其他「战华」怪兽）
function c33545259.tgcon(e)
	-- 检查自己场上是否存在其他「战华」怪兽
	return Duel.IsExistingMatchingCard(c33545259.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
-- 定义sptg2函数，用于设置战斗破坏后特殊召唤的处理信息
function c33545259.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 检查玩家场上是否有可用怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置目标卡为被战斗破坏的对方怪兽
	Duel.SetTargetCard(bc)
	-- 设置操作信息为特殊召唤，目标为被战斗破坏的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 定义spop2函数，用于执行战斗破坏后特殊召唤的操作
function c33545259.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以守备表示特殊召唤到玩家场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

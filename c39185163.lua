--死霊王 ドーハスーラ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「死灵王 恶眼」以外的不死族怪兽的效果发动时才能发动（同一连锁上最多1次）。从以下效果让1个适用。这个回合，自己的「死灵王 恶眼」的效果不能有相同效果适用。
-- ●那个效果无效。
-- ●自己或对方的场上·墓地1只怪兽除外。
-- ②：场地区域有表侧表示卡存在的场合，自己·对方的准备阶段才能发动。这张卡从墓地守备表示特殊召唤。
function c39185163.initial_effect(c)
	-- ①：「死灵王 恶眼」以外的不死族怪兽的效果发动时才能发动（同一连锁上最多1次）。从以下效果让1个适用。这个回合，自己的「死灵王 恶眼」的效果不能有相同效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39185163,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c39185163.disrmcon)
	e1:SetTarget(c39185163.disrmtg)
	e1:SetOperation(c39185163.disrmop)
	c:RegisterEffect(e1)
	-- ②：场地区域有表侧表示卡存在的场合，自己·对方的准备阶段才能发动。这张卡从墓地守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39185163,3))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1,39185163)
	e2:SetCondition(c39185163.spcon)
	e2:SetTarget(c39185163.sptg)
	e2:SetOperation(c39185163.spop)
	c:RegisterEffect(e2)
end
-- 检查连锁效果是否为怪兽类型且种族为不死族，并且不是死灵王恶眼自身。
function c39185163.disrmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的种族、主卡号和副卡号信息。
	local race,code1,code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return re:IsActiveType(TYPE_MONSTER) and race&RACE_ZOMBIE>0 and code1~=39185163 and code2~=39185163
end
-- 判断是否可以无效连锁效果或选择除外怪兽。
function c39185163.disrmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前连锁效果是否可以被无效且未使用过效果①。
	local b1=Duel.IsChainDisablable(ev) and Duel.GetFlagEffect(tp,39185163)==0
	-- 判断场上或墓地是否存在可除外的怪兽。
	local b2=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
		-- 判断未使用过效果②。
		and Duel.GetFlagEffect(tp,39185164)==0
	if chk==0 then return b1 or b2 end
end
-- 过滤函数，用于筛选可除外的怪兽。
function c39185163.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 处理效果选择逻辑，根据条件显示选项。
function c39185163.disrmop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁效果是否可以被无效且未使用过效果①。
	local b1=Duel.IsChainDisablable(ev) and Duel.GetFlagEffect(tp,39185163)==0
	-- 判断场上或墓地是否存在可除外的怪兽。
	local b2=Duel.IsExistingMatchingCard(c39185163.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
		-- 判断未使用过效果②。
		and Duel.GetFlagEffect(tp,39185164)==0
	local op=0
	-- 当两个选项都可用时，让玩家选择效果无效或除外怪兽。
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(39185163,1),aux.Stringid(39185163,2))  --"效果无效/怪兽除外"
	-- 当只有效果无效可用时，让玩家选择效果无效。
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(39185163,1))  --"效果无效"
	-- 当只有除外怪兽可用时，让玩家选择除外怪兽。
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(39185163,2))+1  --"怪兽除外"
	else return end
	if op==0 then
		-- 使当前连锁效果无效。
		Duel.NegateEffect(ev)
		-- 注册效果①已使用标识，于回合结束时重置。
		Duel.RegisterFlagEffect(tp,39185163,RESET_PHASE+PHASE_END,0,1)
	else
		-- 提示玩家选择要除外的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从场上或墓地选择一张可除外的怪兽。
		local g=aux.SelectCardFromFieldFirst(tp,c39185163.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
		-- 将选中的怪兽除外。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		-- 注册效果②已使用标识，于回合结束时重置。
		Duel.RegisterFlagEffect(tp,39185164,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 检查场地区域是否存在表侧表示的卡。
function c39185163.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场地区域是否存在表侧表示的卡。
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 判断是否满足特殊召唤条件。
function c39185163.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位可特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作。
function c39185163.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身特殊召唤到场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end

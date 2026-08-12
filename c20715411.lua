--DDD零死王ゼロ・マキナ
-- 效果：
-- ←0 【灵摆】 0→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：这张卡发动的回合的自己主要阶段才能发动。从卡组把1张「契约书」永续魔法·永续陷阱卡在自己场上表侧表示放置。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：这张卡在额外卡组表侧存在的状态，「DDD 零死王 零·机降神」以外的自己场上的表侧表示的「DDD」卡或「契约书」卡被破坏的场合才能发动（伤害步骤也能发动）。这张卡特殊召唤。那之后，可以把场上1张卡破坏。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 初始化卡片效果，注册灵摆属性和三个效果
function s.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，不注册灵摆卡发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：这张卡发动的回合的自己主要阶段才能发动。从卡组把1张「契约书」永续魔法·永续陷阱卡在自己场上表侧表示放置。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(1160)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetRange(LOCATION_HAND)
	e0:SetCost(s.reg)
	c:RegisterEffect(e0)
	-- ①：这张卡在额外卡组表侧存在的状态，「DDD 零死王 零·机降神」以外的自己场上的表侧表示的「DDD」卡或「契约书」卡被破坏的场合才能发动（伤害步骤也能发动）。这张卡特殊召唤。那之后，可以把场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置「契约书」卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的灵摆效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"放置到灵摆区域"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	c:RegisterEffect(e3)
end
-- 设置灵摆效果的使用标志，用于判断是否可以发动
function s.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 判断是否可以发动灵摆效果，检查是否有使用标志
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
-- 过滤函数，用于筛选可以放置的「契约书」卡
function s.pfilter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0xae)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 设置灵摆效果的目标，检查是否有足够的场地和可放置的卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的灵摆区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在符合条件的「契约书」卡
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 执行灵摆效果，选择并放置「契约书」卡
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的灵摆区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择符合条件的「契约书」卡
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	-- 将选中的卡放置到灵摆区域
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
-- 过滤函数，用于筛选被破坏的「DDD」或「契约书」卡
function s.cfilter(c,tp)
	return c:IsPreviousSetCard(0x10af,0xae) and c:GetPreviousCodeOnField()~=id
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- 判断是否满足特殊召唤条件，检查是否有符合条件的被破坏卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler(),tp) and e:GetHandler():IsFaceup() and not eg:IsContains(e:GetHandler())
end
-- 设置特殊召唤效果的目标，检查是否有足够的召唤场地
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:IsLocation(LOCATION_EXTRA) then
			-- 检查额外卡组特殊召唤的场地是否足够
			return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		else
			-- 检查怪兽区域是否有足够的召唤场地
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		end
	end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤效果，特殊召唤自身并可选择破坏一张卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否可以特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查场上是否有卡且玩家选择是否破坏
		and Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否破坏？"
		-- 选择场上一张卡作为破坏目标
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
		if #g>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 显示选中卡的动画效果
			Duel.HintSelection(g)
			-- 破坏选中的卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 判断是否满足灵摆区域放置条件，检查是否从怪兽区域被破坏
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 设置灵摆区域放置效果的目标，检查是否有可用的灵摆区域
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可用的灵摆区域
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) then
		-- 设置灵摆区域放置效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- 执行灵摆区域放置效果，将自身移动到灵摆区域
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否可以移动到灵摆区域
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身移动到灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

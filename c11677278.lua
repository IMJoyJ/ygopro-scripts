--ミミグル・アーマー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。对方场上有怪兽存在的场合，也能作为代替在自己场上表侧表示特殊召唤。
-- ②：这张卡在主要阶段反转的场合发动。以下效果各适用。
-- ●这个回合中，「迷拟宝箱鬼」怪兽不会被战斗破坏。
-- ●这张卡的控制权移给对方。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- ②：这张卡在主要阶段反转的场合发动。以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	-- 反转效果触发条件检查
	e1:SetCondition(aux.MimighoulFlipCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。对方场上有怪兽存在的场合，也能作为代替在自己场上表侧表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 设置反转效果的目标函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 反转效果的处理函数
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中，「迷拟宝箱鬼」怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.ptfilter)
	e1:SetValue(1)
	-- 注册控制权改变效果
	Duel.RegisterEffect(e1,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 使该卡的控制权移给对方
		Duel.GetControl(c,1-tp)
	end
end
-- 判断是否为迷拟宝箱鬼族怪兽的过滤函数
function s.ptfilter(e,c)
	return c:IsSetCard(0x1b7)
end
-- 判断是否可以特殊召唤到己方场上的过滤函数
function s.sspfilter(c,tp,e)
	-- 检查对方场上是否存在怪兽
	return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 判断是否可以特殊召唤到对方场上的过滤函数
function s.ospfilter(c,tp,e)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
end
-- 设置特殊召唤效果的目标函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足特殊召唤到己方场上的条件
	if chk==0 then return s.sspfilter(c,tp,e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足特殊召唤到对方场上的条件
		or s.ospfilter(c,tp,e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 设置操作信息：特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or (not s.sspfilter(c,tp,e) and not s.ospfilter(c,tp,e)) then return end
	-- 判断是否可以特殊召唤到己方场上的布尔值
	local b1=s.sspfilter(c,tp,e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 判断是否可以特殊召唤到对方场上的布尔值
	local b2=s.ospfilter(c,tp,e) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	-- 让玩家选择将卡特殊召唤到哪一方场上
	local toplayer=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),tp},
		{b2,aux.Stringid(id,3),1-tp})
	if toplayer==tp then
		-- 将卡特殊召唤到己方场上
		Duel.SpecialSummon(c,0,tp,toplayer,false,false,POS_FACEUP)
	elseif toplayer==1-tp then
		-- 将卡特殊召唤到对方场上
		Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 确认对方场上特殊召唤的卡
		Duel.ConfirmCards(tp,c)
	else
		-- 检查双方场上是否都没有空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then
			-- 将卡送入墓地
			Duel.SendtoGrave(c,REASON_RULE)
		end
	end
end

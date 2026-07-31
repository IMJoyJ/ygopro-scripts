--D－バースト
local s,id,o=GetID()
-- 定义卡片初始效果函数
function s.initial_effect(c)
	-- 将该卡加入到代码列表，用于识别同名卡。
	aux.AddCodeList(c,17132130)
	-- 将该卡注册为系列怪兽的成员，方便后续效果判定。
	aux.AddSetNameMonsterList(c,0xc008)
	-- 创建并注册一个激活效果，实现破坏、抽牌和特殊召唤的效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 创建并注册一个触发效果，在伤害步骤结束时发动，用于从墓地特殊召唤怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.atkcon)
	-- 设置除外作为cost的条件
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 定义一个过滤函数，用于筛选场上表侧表示的魔法卡。
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 目标选择函数，检查目标是否在场上、属于玩家控制且是魔法卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp)
		and s.desfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查当前玩家是否可以抽牌。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查是否存在满足条件的魔法卡作为目标。
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 向玩家提示选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择一张魔法卡作为目标。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 设置当前连锁的目标玩家为tp。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息，表示要进行破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，表示要进行抽牌效果。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义一个过滤函数，用于筛选表侧表示的系列怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc008)
end
-- 定义一个过滤函数，用于筛选可以特殊召唤的系列怪兽。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0xc008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 激活效果的处理函数，实现破坏、抽牌和特殊召唤的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 获取连锁相关的目标卡组。
	local dg=Duel.GetTargetsRelateToChain()
	-- 如果存在目标卡且成功破坏，则继续执行后续操作。
	if dg:GetCount()>0 and Duel.Destroy(dg,REASON_EFFECT)>0
		-- 检查是否成功抽牌。
		and Duel.Draw(p,d,REASON_EFFECT)~=0
		-- 检查是否存在满足条件的系列怪兽在怪兽区域。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查玩家的怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌、墓地或除外区是否存在可以特殊召唤的系列怪兽，并且不受王家长眠之谷的影响。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		-- 询问玩家是否要进行特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 向玩家提示选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手牌、墓地或除外区选择一张系列怪兽作为目标。
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 中断当前效果，防止与其他效果同时处理。
			Duel.BreakEffect()
			-- 将选定的系列怪兽特殊召唤到场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 定义一个条件函数，用于判断是否可以发动连锁攻击。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击者。
	local at=Duel.GetAttacker()
	return (at:GetEquipCount()>0 or at:IsCode(17132130)) and at:IsChainAttackable()
end
-- 目标选择函数，返回true表示允许选择
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 定义一个操作函数，用于使攻击卡可以再次进行攻击。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 使攻击卡可以再进行1次攻击。
	Duel.ChainAttack()
end

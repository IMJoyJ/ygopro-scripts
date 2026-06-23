--磁石の戦士マグネット・テルスリオン
-- 效果：
-- 这张卡不能通常召唤。把自己的手卡·场上（表侧表示）·墓地的「磁石战士Σ+」「磁石战士Σ-」各1只除外的场合才能从墓地特殊召唤。
-- ①：1回合1次，对方把效果发动时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。以地属性怪兽为对象发动的场合，也能作为代替而得到那只怪兽的控制权。
-- ②：对方回合，把这张卡解放才能发动。自己的除外状态的2只「磁石战士Σ」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册需要除外的卡号，启用特殊召唤限制，创建特殊召唤条件、特殊召唤程序、破坏效果和特殊召唤效果
function s.initial_effect(c)
	-- 记录该卡与「磁石战士Σ+」「磁石战士Σ-」的关联
	aux.AddCodeList(c,51826619,87814728)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己的手卡·场上（表侧表示）·墓地的「磁石战士Σ+」「磁石战士Σ-」各1只除外的场合才能从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 特殊召唤时需要除外「磁石战士Σ+」「磁石战士Σ-」各1只，满足条件时才能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，对方把效果发动时，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。以地属性怪兽为对象发动的场合，也能作为代替而得到那只怪兽的控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ②：对方回合，把这张卡解放才能发动。自己的除外状态的2只「磁石战士Σ」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(s.spcon2)
	e4:SetCost(s.spcost2)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
end
-- 过滤满足条件的卡（表侧表示、可除外、为指定卡号）
function s.spcostfilter(c)
	return c:IsFaceupEx() and c:IsAbleToRemoveAsCost() and c:IsCode(51826619,87814728)
end
-- 检查卡组中是否存在两张满足条件的卡，并且场上存在空位
function s.gcheck(g,tp)
	-- 检查卡组中是否存在两张满足条件的卡
	return aux.gfcheck(g,Card.IsCode,51826619,87814728)
		-- 检查场上是否存在空位
		and Duel.GetMZoneCount(tp,g)>0
end
-- 判断特殊召唤条件是否满足，即是否能除外两张指定卡
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足除外条件的卡组
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_GRAVE+LOCATION_MZONE+LOCATION_HAND,0,c)
	return g:CheckSubGroup(s.gcheck,2,2,tp)
end
-- 选择满足条件的两张卡并设置为除外对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足除外条件的卡组
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_GRAVE+LOCATION_MZONE+LOCATION_HAND,0,c)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的除外操作
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选中的卡除外
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 判断是否为对方发动效果
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 设置破坏效果的目标选择
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 判断是否能选择目标
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	e:SetLabel(0)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if not tc:IsAttribute(ATTRIBUTE_EARTH) or tc:IsFacedown() then
			-- 设置破坏效果的处理信息
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		else
			e:SetLabel(1)
		end
	end
end
-- 执行破坏效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsLocation(LOCATION_MZONE) then
		if e:GetLabel()==1 and tc:IsControlerCanBeChanged()
			-- 提示玩家是否获取控制权
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否获取控制权？"
			-- 获得目标怪兽的控制权
			Duel.GetControl(tc,tp)
		else
			-- 破坏目标怪兽
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- 判断是否为对方回合
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 设置特殊召唤效果的费用
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤费用条件
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>1 end
	-- 解放自身作为费用
	Duel.Release(c,REASON_COST)
end
-- 过滤满足特殊召唤条件的卡
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x6066) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 判断是否满足特殊召唤条件
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,2,nil,e,tp)
	end
	-- 设置特殊召唤效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_REMOVED)
end
-- 执行特殊召唤效果
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 判断场上是否满足特殊召唤条件
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取满足特殊召唤条件的卡组
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选中的卡特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end

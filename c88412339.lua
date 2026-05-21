--魔界劇団－エキストラ
-- 效果：
-- ←3 【灵摆】 3→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：对方场上有怪兽存在的场合才能发动。灵摆区域的这张卡特殊召唤。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：把这张卡解放才能发动。从卡组选1只「魔界剧团」灵摆怪兽在自己的灵摆区域放置。这个效果的发动后，直到回合结束时自己不是「魔界剧团」怪兽不能特殊召唤，不能把「魔界剧团-临时演员」的灵摆效果发动。
function c88412339.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动等基本规则）
	aux.EnablePendulumAttribute(c)
	-- ①：对方场上有怪兽存在的场合才能发动。灵摆区域的这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88412339,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,88412339)
	e1:SetCondition(c88412339.spcon)
	e1:SetTarget(c88412339.sptg)
	e1:SetOperation(c88412339.spop)
	c:RegisterEffect(e1)
	-- ①：把这张卡解放才能发动。从卡组选1只「魔界剧团」灵摆怪兽在自己的灵摆区域放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88412339,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,88412340)
	e2:SetCost(c88412339.pencost)
	e2:SetTarget(c88412339.pentg)
	e2:SetOperation(c88412339.penop)
	c:RegisterEffect(e2)
end
-- 灵摆效果特殊召唤的发动条件函数
function c88412339.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在怪兽
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 灵摆效果特殊召唤的目标与检测函数
function c88412339.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区域是否有空位，以及自身是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 灵摆效果特殊召唤的执行函数
function c88412339.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身特殊召唤到自己的场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 怪兽效果的发动代价（Cost）检测与执行函数
function c88412339.pencost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中「魔界剧团」灵摆怪兽的条件函数
function c88412339.penfilter(c)
	return c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
-- 怪兽效果的目标与检测函数
function c88412339.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「魔界剧团」灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c88412339.penfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查自己的灵摆区域是否有空位
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
end
-- 怪兽效果的执行函数
function c88412339.penop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查灵摆区域是否有空位
	if Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) then
		-- 提示玩家选择要放置到场上的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从卡组选择1张满足条件的「魔界剧团」灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c88412339.penfilter,tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的怪兽表侧表示放置到自己的灵摆区域
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己不是「魔界剧团」怪兽不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c88412339.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤「魔界剧团」以外怪兽的玩家限制效果
	Duel.RegisterEffect(e1,tp)
	-- 不能把「魔界剧团-临时演员」的灵摆效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(c88412339.aclimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能发动「魔界剧团-临时演员」灵摆效果的玩家限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制特殊召唤的怪兽必须是「魔界剧团」怪兽的过滤函数
function c88412339.splimit(e,c)
	return not c:IsSetCard(0x10ec)
end
-- 限制不能发动场上的「魔界剧团-临时演员」灵摆效果的过滤函数
function c88412339.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return rc:IsOnField() and rc:IsCode(88412339) and re:GetActiveType()==TYPE_PENDULUM+TYPE_SPELL
end

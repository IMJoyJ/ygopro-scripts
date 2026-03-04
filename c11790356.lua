--破戒蛮竜－バスター・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：对方场上的怪兽只要这张卡表侧表示存在变成龙族。
-- ②：自己场上没有「破坏之剑士」怪兽存在的场合，1回合1次，以自己墓地1只「破坏之剑士」为对象才能发动。那只怪兽特殊召唤。
-- ③：对方回合1次，以自己场上1只「破坏之剑士」怪兽为对象才能发动。自己墓地1只「破坏剑」怪兽当作装备卡使用给作为对象的怪兽装备。
function c11790356.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对方场上的怪兽只要这张卡表侧表示存在变成龙族
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(RACE_DRAGON)
	c:RegisterEffect(e1)
	-- 自己场上没有「破坏之剑士」怪兽存在的场合，1回合1次，以自己墓地1只「破坏之剑士」为对象才能发动。那只怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11790356,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c11790356.spcon)
	e2:SetTarget(c11790356.sptg)
	e2:SetOperation(c11790356.spop)
	c:RegisterEffect(e2)
	-- 对方回合1次，以自己场上1只「破坏之剑士」怪兽为对象才能发动。自己墓地1只「破坏剑」怪兽当作装备卡使用给作为对象的怪兽装备
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11790356,1))  --"装备"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c11790356.condition)
	e3:SetTarget(c11790356.target)
	e3:SetOperation(c11790356.operation)
	c:RegisterEffect(e3)
end
-- 判断是否为表侧表示的「破坏之剑士」怪兽
function c11790356.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd7)
end
-- 判断自己场上是否没有「破坏之剑士」怪兽
function c11790356.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有「破坏之剑士」怪兽则满足条件
	return not Duel.IsExistingMatchingCard(c11790356.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤满足条件的「破坏之剑士」怪兽
function c11790356.filter(c,e,tp)
	return c:IsCode(78193831) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的处理函数
function c11790356.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c11790356.filter(chkc,e,tp) end
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否在墓地存在满足条件的「破坏之剑士」怪兽
		and Duel.IsExistingTarget(c11790356.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c11790356.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 设置特殊召唤效果的执行函数
function c11790356.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为对方回合
function c11790356.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前回合不是自己则满足条件
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤满足条件的「破坏剑」怪兽
function c11790356.filter2(c)
	return c:IsSetCard(0xd6) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 设置装备效果的处理函数
function c11790356.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c11790356.cfilter(chkc) end
	-- 检查是否有足够的魔法区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在「破坏之剑士」怪兽
		and Duel.IsExistingTarget(c11790356.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查墓地是否存在「破坏剑」怪兽
		and Duel.IsExistingMatchingCard(c11790356.filter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择要装备的「破坏之剑士」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择目标「破坏之剑士」怪兽
	Duel.SelectTarget(tp,c11790356.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息为装备
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- 设置装备效果的执行函数
function c11790356.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若魔法区域不足则返回
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 提示选择要装备的「破坏剑」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择目标「破坏剑」怪兽
	local sg=Duel.SelectMatchingCard(tp,c11790356.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
	local sc=sg:GetFirst()
	if sc then
		-- 将目标怪兽装备给目标怪兽
		if not Duel.Equip(tp,sc,tc) then return end
		-- 设置装备限制效果，防止被其他装备卡替换
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c11790356.eqlimit)
		e1:SetLabelObject(tc)
		sc:RegisterEffect(e1)
	end
end
-- 设置装备限制效果的判断函数
function c11790356.eqlimit(e,c)
	return e:GetLabelObject()==c
end

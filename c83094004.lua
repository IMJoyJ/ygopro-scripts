--エアロピΞ
-- 效果：
-- ①：1回合1次，以和这张卡相同纵列1只对方的表侧表示怪兽为对象才能发动。自己场上的这张卡的位置向其他的自己的主要怪兽区域移动，作为对象的对方怪兽的位置向这张卡的正对面的对方的主要怪兽区域移动。那之后，给那只对方怪兽放置1个燃烧指示物。这个效果在对方回合也能发动。
-- ②：只要这张卡在怪兽区域存在，有燃烧指示物放置的怪兽的攻击力·守备力下降那数量×200。
function c83094004.initial_effect(c)
	-- ①：1回合1次，以和这张卡相同纵列1只对方的表侧表示怪兽为对象才能发动。自己场上的这张卡的位置向其他的自己的主要怪兽区域移动，作为对象的对方怪兽的位置向这张卡的正对面的对方的主要怪兽区域移动。那之后，给那只对方怪兽放置1个燃烧指示物。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83094004,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c83094004.seqtg)
	e1:SetOperation(c83094004.seqop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，有燃烧指示物放置的怪兽的攻击力·守备力下降那数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(c83094004.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 过滤与此卡相同纵列、可以放置燃烧指示物的对方表侧表示怪兽，并检查是否存在可供双方移动的合法位置
function c83094004.seqfilter(c,e,tp)
	local g=e:GetHandler():GetColumnGroup()
	if not (c:IsFaceup() and g:IsContains(c) and c:IsCanAddCounter(0x105c,1)) then return false end
	for i=0,4 do
		-- 检查自己场上主要怪兽区域序号为i的格子是否可用
		local s1=Duel.CheckLocation(tp,LOCATION_MZONE,i)
		-- 检查对方场上与自己序号i正对面的主要怪兽区域格子（序号为4-i）是否可用
		local s2=Duel.CheckLocation(1-tp,LOCATION_MZONE,4-i)
		if s1 and s2 then return true end
	end
	return false
end
-- 效果①的发动准备与合法性检查
function c83094004.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c83094004.seqfilter(chkc,e,tp) end
	-- 在发动检查时，确认自己场上是否有至少一个可用的主要怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
		-- 确认对方场上是否有至少一个可用的主要怪兽区域
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)>0
		-- 确认对方场上是否存在满足条件的、与此卡在相同纵列且可以移动和放置指示物的表侧表示怪兽
		and Duel.IsExistingTarget(c83094004.seqfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只满足条件的表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,c83094004.seqfilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
end
-- 效果①的执行处理，获取自身和对象怪兽，并确认它们是否仍存在于场上且不受效果影响
function c83094004.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e)
		or not tc:IsRelateToEffect(e) or tc:IsControler(tp) or tc:IsImmuneToEffect(e) then return end
	local filter=0
	for i=0,4 do
		-- 在效果处理时，检查自己场上主要怪兽区域序号为i的格子是否可用
		local s1=Duel.CheckLocation(tp,LOCATION_MZONE,i)
		-- 在效果处理时，检查对方场上与自己序号i正对面的主要怪兽区域格子（序号为4-i）是否可用
		local s2=Duel.CheckLocation(1-tp,LOCATION_MZONE,4-i)
		if s1 and s2 then
			filter=filter|2^i
		end
	end
	if filter==0 then return end
	-- 提示玩家选择要移动到的位置
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家选择一个自己可用的主要怪兽区域（该区域正对面的对方区域也必须可用），返回其位置标记
	local flag=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~filter)
	local seq1=math.log(flag,2)
	local seq2=4-math.log(flag,2)
	-- 将自己场上的这张卡移动到选择的主要怪兽区域
	Duel.MoveSequence(c,seq1)
	if c:GetSequence()==seq1 then
		-- 将作为对象的对方怪兽移动到这张卡正对面的对方的主要怪兽区域
		Duel.MoveSequence(tc,seq2)
		if tc:IsFaceup() then
			-- 中断当前效果处理，使之后的放置指示物处理不与移动位置同时进行
			Duel.BreakEffect()
			tc:AddCounter(0x105c,1)
		end
	end
end
-- 计算攻击力/守备力下降的数值，为该怪兽放置的燃烧指示物数量乘以-200
function c83094004.atkval(e,c)
	return c:GetCounter(0x105c)*-200
end

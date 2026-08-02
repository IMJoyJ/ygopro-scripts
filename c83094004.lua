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
c83094004.mentioned_counter={
	[0x105c]=true,
}
-- 对象过滤条件：和这张卡同纵列且能放置燃烧指示物的对方表侧怪兽，且存在可以使双方同时移动到正对面的空区域
function c83094004.seqfilter(c,e,tp)
	local g=e:GetHandler():GetColumnGroup()
	if not (c:IsFaceup() and g:IsContains(c) and c:IsCanAddCounter(0x105c,1)) then return false end
	for i=0,4 do
		-- 检查自己场上的第 i 个主要怪兽区域是否为空且可用
		local s1=Duel.CheckLocation(tp,LOCATION_MZONE,i)
		-- 检查对方场上与自己第 i 个区域正对面的主要怪兽区域是否为空且可用
		local s2=Duel.CheckLocation(1-tp,LOCATION_MZONE,4-i)
		if s1 and s2 then return true end
	end
	return false
end
-- 效果目标设置：检查区域空位并选择同纵列的对方怪兽作为对象
function c83094004.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c83094004.seqfilter(chkc,e,tp) end
	-- 条件检查：确认自己的主要怪兽区域有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
		-- 条件检查：确认对方的主要怪兽区域有可用的空位
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)>0
		-- 条件检查：确认对方场上存在可以作为对象的符合移动条件的怪兽
		and Duel.IsExistingTarget(c83094004.seqfilter,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 向玩家发送提示“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只符合条件的对方怪兽作为对象
	Duel.SelectTarget(tp,c83094004.seqfilter,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
end
-- 效果处理：检查怪兽状态，计算有效移动区域，进行位置移动并放置指示物
function c83094004.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为对象的对方怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e)
		or not tc:IsRelateToEffect(e) or tc:IsControler(tp) or tc:IsImmuneToEffect(e) then return end
	local filter=0
	for i=0,4 do
		-- 检查自己场上的第 i 个主要怪兽区域是否有空位
		local s1=Duel.CheckLocation(tp,LOCATION_MZONE,i)
		-- 检查对方场上与自己第 i 个区域正对面的主要怪兽区域是否有空位
		local s2=Duel.CheckLocation(1-tp,LOCATION_MZONE,4-i)
		if s1 and s2 then
			filter=filter|2^i
		end
	end
	if filter==0 then return end
	-- 向玩家发送提示“请选择要移动到的位置”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
	-- 让玩家选择1个符合条件的自己的主要怪兽区域格子，返回对应的位置标记
	local flag=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~filter)
	local seq1=math.log(flag,2)
	local seq2=4-math.log(flag,2)
	-- 将这张卡移动到玩家选择的新的主要怪兽区域格子
	Duel.MoveSequence(c,seq1)
	if c:GetSequence()==seq1 then
		-- 将作为对象的对方怪兽移动到对应正对面的主要怪兽区域格子
		Duel.MoveSequence(tc,seq2)
		if tc:IsFaceup() then
			-- 中断效果处理，使后续放置指示物的操作与移动卡片视为不同时发生
			Duel.BreakEffect()
			tc:AddCounter(0x105c,1)
		end
	end
end
-- 数值计算函数：根据怪兽身上燃烧指示物的数量乘以-200来降低攻击力或守备力
function c83094004.atkval(e,c)
	return c:GetCounter(0x105c)*-200
end

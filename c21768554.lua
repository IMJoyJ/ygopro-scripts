--集団催眠
-- 效果：
-- 自己场上有名字带有「外星」的怪兽存在时才能发动。选择对方场上存在的最多3只放置有A指示物的怪兽得到控制权。这张卡在发动回合的结束阶段时破坏。
function c21768554.initial_effect(c)
	-- 自己场上有名字带有「外星」的怪兽存在时才能发动。选择对方场上存在的最多3只放置有A指示物的怪兽得到控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCondition(c21768554.condition)
	e1:SetTarget(c21768554.target)
	e1:SetOperation(c21768554.operation)
	c:RegisterEffect(e1)
	-- 这张卡在发动回合的结束阶段时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21768554,0))  --"破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c21768554.descon)
	e2:SetOperation(c21768554.desop)
	c:RegisterEffect(e2)
	-- 选择对方场上存在的最多3只放置有A指示物的怪兽得到控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c21768554.cttg)
	e3:SetValue(c21768554.ctval)
	c:RegisterEffect(e3)
end
c21768554.mentioned_counter={
	[0x100e]=true,
}
-- 过滤函数：表侧表示且名字带有「外星」的怪兽（0xc为「外星」系列字段）。
function c21768554.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc)
end
-- 发动条件：确认自己怪兽区域存在至少1只表侧表示的「外星」怪兽。
function c21768554.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区域是否存在至少1只满足条件的「外星」怪兽。
	return Duel.IsExistingMatchingCard(c21768554.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：放置有A指示物且控制权可以变更的怪兽。
function c21768554.filter(c)
	return c:GetCounter(0x100e)>0 and c:IsControlerCanBeChanged()
end
-- 取对象阶段：确认对方场上存在可夺取控制权的怪兽，计算自己怪兽区可用空格数（上限3只），选择1~该数量的对方怪兽作为对象，并设置改变控制权的操作信息。
function c21768554.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c21768554.filter(chkc) end
	-- 发动时检查对方场上是否存在至少1只可作为对象的、放置有A指示物的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c21768554.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得因控制权变更而需要的自己怪兽区可用空格数（从对方视角判定）。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,1-tp,LOCATION_REASON_CONTROL)
	if ft>3 then ft=3 end
	-- 向发动玩家显示「请选择要改变控制权的怪兽」的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择1~空格数只对方场上放置有A指示物的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c21768554.filter,tp,0,LOCATION_MZONE,1,ft,nil)
	-- 设置连锁操作信息：分类为改变控制权，对象及数量为已选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,g:GetCount(),0,0)
end
-- 效果处理：确认对象数量不超过自己怪兽区空格后，对仍表侧表示、仍放置有A指示物且仍与效果关联的对象怪兽建立持续取对象关系，并登记在回合结束阶段自毁用的标记效果。
function c21768554.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	-- 若对象怪兽数量超过自己怪兽区的可用空格数，则中止效果处理。
	if g:GetCount()>Duel.GetLocationCount(tp,LOCATION_MZONE) then return end
	local tc=g:GetFirst()
	while tc do
		if tc:IsFaceup() and tc:GetCounter(0x100e)>0 and tc:IsRelateToEffect(e) then
			c:SetCardTarget(tc)
		end
		tc=g:GetNext()
	end
	c:RegisterFlagEffect(21768554,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 永续效果的对象判定：放置有A指示物的卡。
function c21768554.cttg(e,c)
	return c:GetCounter(0x100e)>0
end
-- 将被取对象怪兽的控制权设置为这张卡的控制者（即发动效果的玩家）。
function c21768554.ctval(e,c)
	return e:GetHandlerPlayer()
end
-- 破坏效果的发动条件：这张卡在发动回合成功处理过夺取控制权的效果（存在标记效果）。
function c21768554.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(21768554)~=0
end
-- 效果处理：以效果原因破坏这张卡自身。
function c21768554.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏这张卡。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

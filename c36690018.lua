--逆転する運命
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「秘仪之力」的怪兽发动。选择怪兽用投掷硬币的里表所得效果变成相反。
function c36690018.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「秘仪之力」的怪兽发动。选择怪兽用投掷硬币的里表所得效果变成相反。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36690018.target)
	e1:SetOperation(c36690018.activate)
	c:RegisterEffect(e1)
end
-- 筛选满足条件的卡片：表侧表示、持有「秘仪之力」字段、且已经带有逆转命运标志的怪兽（用于作为效果对象）。
function c36690018.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x5) and c:GetFlagEffect(FLAG_ID_REVERSAL_OF_FATE)~=0
end
-- 效果发动时的目标选择处理：确认是否存在合法对象；让玩家从自己场上表侧表示的、带「秘仪之力」且带有逆转命运标志的怪兽中选择1只作为对象。
function c36690018.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c36690018.filter(chkc) end
	-- 发动时检查自己场上是否存在至少1只满足条件的表侧表示「秘仪之力」怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c36690018.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向选择玩家弹出选择卡片提示，提示内容为『请选择表侧表示的卡』。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上满足条件的表侧表示「秘仪之力」怪兽中选择1只，并将其设为效果对象（同时建立对象与该连锁的关联）。
	Duel.SelectTarget(tp,c36690018.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象怪兽，确认其仍与效果关联、表侧表示且带有逆转命运标志和硬币标记后，将其记录的硬币表里标记取反（0变1，1变0），从而逆转其投掷硬币所得效果。
function c36690018.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果发动的对象怪兽（通常只有1只）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetFlagEffect(FLAG_ID_REVERSAL_OF_FATE)~=0 and tc:GetFlagEffect(FLAG_ID_ARCANA_COIN)~=0 then
		local val=tc:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)
		tc:SetFlagEffectLabel(FLAG_ID_ARCANA_COIN,1-val)
	end
end

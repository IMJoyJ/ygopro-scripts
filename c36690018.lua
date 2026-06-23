--逆転する運命
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「秘仪之力」的怪兽发动。选择怪兽用投掷硬币的里表所得效果变成相反。
function c36690018.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「秘仪之力」的怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36690018.target)
	e1:SetOperation(c36690018.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的怪兽（表侧表示、名字带有「秘仪之力」、已标记效果）
function c36690018.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x5) and c:GetFlagEffect(FLAG_ID_REVERSAL_OF_FATE)~=0
end
-- 设置效果的目标为满足条件的怪兽
function c36690018.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c36690018.filter(chkc) end
	-- 判断是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c36690018.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c36690018.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将选择的怪兽效果变成相反
function c36690018.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetFlagEffect(FLAG_ID_REVERSAL_OF_FATE)~=0 and tc:GetFlagEffect(FLAG_ID_ARCANA_COIN)~=0 then
		local val=tc:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)
		tc:SetFlagEffectLabel(FLAG_ID_ARCANA_COIN,1-val)
	end
end

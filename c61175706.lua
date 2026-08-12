--アルカナフォースⅣ－THE EMPEROR
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，进行1次投掷硬币得到以下效果。
-- ●表：自己场上表侧表示存在的名字带有「秘仪之力」的怪兽的攻击力上升500。
-- ●里：自己场上表侧表示存在的名字带有「秘仪之力」的怪兽的攻击力下降500。
function c61175706.initial_effect(c)
	-- 注册该卡在召唤、反转召唤、特殊召唤成功时强制进行一次投掷硬币的诱发效果
	aux.EnableArcanaCoin(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS)
	-- ●表：自己场上表侧表示存在的名字带有「秘仪之力」的怪兽的攻击力上升500。●里：自己场上表侧表示存在的名字带有「秘仪之力」的怪兽的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果生效条件为该怪兽已通过投掷硬币确定了表里结果
	e1:SetCondition(aux.ArcanaCondition)
	e1:SetTarget(c61175706.atktg)
	e1:SetValue(c61175706.atkval)
	c:RegisterEffect(e1)
end
-- 限定该攻击力增减效果仅适用于自己场上名字带有「秘仪之力」的怪兽
function c61175706.atktg(e,c)
	return c:IsSetCard(0x5)
end
-- 根据投掷硬币的标记值进行判定，若为表（正面）则攻击力上升500，否则（反面）攻击力下降500
function c61175706.atkval(e,c)
	if e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1 then
		return 500
	else
		return -500
	end
end

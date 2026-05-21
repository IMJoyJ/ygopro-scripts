--アルカナフォースⅥ－THE LOVERS
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，进行1次投掷硬币得到以下效果。
-- ●表：名字带有「秘仪之力」的怪兽祭品召唤的场合，这1只怪兽可以作为2只的数量的祭品。
-- ●里：名字带有「秘仪之力」的怪兽不能祭品召唤。
function c97574404.initial_effect(c)
	-- 注册该卡在召唤、反转召唤、特殊召唤成功时进行1次投掷硬币的诱发效果
	aux.EnableArcanaCoin(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS)
	-- ●表：名字带有「秘仪之力」的怪兽祭品召唤的场合，这1只怪兽可以作为2只的数量的祭品。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetCondition(c97574404.dtcon)
	e1:SetValue(c97574404.dtval)
	c:RegisterEffect(e1)
	-- ●里：名字带有「秘仪之力」的怪兽不能祭品召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCondition(c97574404.sumcon)
	e2:SetTarget(c97574404.sumtg)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_MSET)
	c:RegisterEffect(e3)
end
-- 判定投掷硬币的结果是否为表（正面）
function c97574404.dtcon(e)
	return e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1
end
-- 判定进行上级召唤的怪兽是否为「秘仪之力」怪兽
function c97574404.dtval(e,c)
	return c:IsSetCard(0x5)
end
-- 判定投掷硬币的结果是否为里（反面）
function c97574404.sumcon(e)
	return e:GetHandler():GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==0
end
-- 过滤出进行上级召唤（祭品召唤）且卡名含有「秘仪之力」的怪兽
function c97574404.sumtg(e,c,tp,sumtp)
	return bit.band(sumtp,SUMMON_TYPE_ADVANCE)==SUMMON_TYPE_ADVANCE and c:IsSetCard(0x5)
end

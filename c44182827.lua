--輪廻転生
-- 效果：
-- 作为仪式召唤的祭品的怪兽卡不去墓地，回到持有者的卡组。之后卡组洗切。
function c44182827.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 作为仪式召唤的祭品的怪兽卡不去墓地，回到持有者的卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c44182827.rmtarget)
	e2:SetValue(LOCATION_DECKSHF)
	c:RegisterEffect(e2)
end
-- 检索满足仪式召唤、解放、效果或素材条件的怪兽
function c44182827.rmtarget(e,c)
	return c:GetReason()==REASON_RELEASE+REASON_RITUAL+REASON_EFFECT+REASON_MATERIAL
end

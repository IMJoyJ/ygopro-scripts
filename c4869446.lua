--砂漠の裁き
-- 效果：
-- 表侧表示的怪兽不能变更其表示形式。
function c4869446.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 表侧表示的怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c4869446.posop)
	c:RegisterEffect(e2)
	-- 不能变更其表示形式。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c4869446.postg)
	c:RegisterEffect(e3)
end
-- 筛选出本次表示形式变更中，从里侧表示变为表侧表示的怪兽（即变更后表侧且变更前为里侧）。
function c4869446.cfilter(c)
	return c:IsFaceup() and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 对筛选出的怪兽各注册一个标记，标记值为本张“沙漠的裁决”的FieldID；这些怪兽将被认定为受本卡限制的“表侧表示的怪兽”，随后继续处理下一只。
function c4869446.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c4869446.cfilter,nil)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(4869446,RESET_EVENT+RESETS_STANDARD,0,1,e:GetHandler():GetFieldID())
		tc=g:GetNext()
	end
end
-- 判定某只怪兽是否带有本张“沙漠的裁决”的FieldID标记；若有则返回true，表示它作为表侧表示的怪兽不能变更表示形式。
function c4869446.postg(e,c)
	for _,flag in ipairs({c:GetFlagEffectLabel(4869446)}) do
		if flag==e:GetHandler():GetFieldID() then return true end
	end
	return false
end

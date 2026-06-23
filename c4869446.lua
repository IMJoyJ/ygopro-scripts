--砂漠の裁き
-- 效果：
-- 表侧表示的怪兽不能变更其表示形式。
function c4869446.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 表侧表示的怪兽不能变更其表示形式。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c4869446.posop)
	c:RegisterEffect(e2)
	-- 表侧表示的怪兽不能变更其表示形式。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c4869446.postg)
	c:RegisterEffect(e3)
end
-- 筛选条件：怪兽必须是表侧表示且之前是背面向上的位置。
function c4869446.cfilter(c)
	return c:IsFaceup() and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 遍历触发事件中的怪兽，为符合条件的怪兽注册一个标识效果，用于记录该怪兽被影响的时间戳。
function c4869446.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c4869446.cfilter,nil)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(4869446,RESET_EVENT+RESETS_STANDARD,0,1,e:GetHandler():GetFieldID())
		tc=g:GetNext()
	end
end
-- 判断目标怪兽是否被该效果影响，通过比较其标识效果的标签与当前效果的场地区域ID是否一致来决定。
function c4869446.postg(e,c)
	for _,flag in ipairs({c:GetFlagEffectLabel(4869446)}) do
		if flag==e:GetHandler():GetFieldID() then return true end
	end
	return false
end

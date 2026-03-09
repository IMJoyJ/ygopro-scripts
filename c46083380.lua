--攻通規制
-- 效果：
-- 对方场上有怪兽3只以上存在的场合，对方不能攻击宣言。
function c46083380.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方场上有怪兽3只以上存在的场合，对方不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c46083380.atcon)
	c:RegisterEffect(e2)
end
-- 检查对方场上怪兽数量是否大于等于3
function c46083380.atcon(e)
	-- 获取当前卡片控制者在对方场上的怪兽数量
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)>=3
end

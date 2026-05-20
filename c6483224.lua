--半月竜ラディウス
-- 效果：
-- 对方场上有超量怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡的等级变成8星。
function c6483224.initial_effect(c)
	-- 对方场上有超量怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡的等级变成8星。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(c6483224.spcon)
	e1:SetOperation(c6483224.spop)
	c:RegisterEffect(e1)
end
-- 过滤表侧表示的超量怪兽
function c6483224.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 判断手卡特殊召唤的条件是否满足
function c6483224.spcon(e,c)
	if c==nil then return true end
	-- 检查自身控制者的怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上是否存在表侧表示的超量怪兽
		and Duel.IsExistingMatchingCard(c6483224.filter,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
-- 特殊召唤成功时，为自身注册等级变成8星的效果
function c6483224.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法特殊召唤的这张卡的等级变成8星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(8)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end

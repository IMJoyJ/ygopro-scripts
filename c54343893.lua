--バイス・ドラゴン
-- 效果：
-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡的原本的攻击力·守备力变成一半。
function c54343893.initial_effect(c)
	-- ①：只有对方场上才有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡的原本的攻击力·守备力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c54343893.spcon)
	e1:SetOperation(c54343893.spop)
	c:RegisterEffect(e1)
end
-- 判断自身特殊召唤的条件是否满足：自己场上没有怪兽，对方场上有怪兽，且自己场上有空位
function c54343893.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽数量是否大于0
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 特殊召唤成功时，将这张卡的原本攻击力和原本守备力减半
function c54343893.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法特殊召唤的这张卡的原本的攻击力·守备力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	-- 这个方法特殊召唤的这张卡的原本的攻击力·守备力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(1200)
	e2:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e2)
end

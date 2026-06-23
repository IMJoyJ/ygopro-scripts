--こけコッコ
-- 效果：
-- ①：双方场上没有怪兽存在的场合，这张卡可以作为3星怪兽从手卡特殊召唤。
-- ②：对方场上有怪兽存在，自己场上没有卡存在的场合，这张卡可以作为4星怪兽从手卡特殊召唤。
-- ③：表侧表示的这张卡从场上离开的场合除外。
function c42338879.initial_effect(c)
	-- ①：双方场上没有怪兽存在的场合，这张卡可以作为3星怪兽从手卡特殊召唤。②：对方场上有怪兽存在，自己场上没有卡存在的场合，这张卡可以作为4星怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c42338879.spcon)
	e1:SetOperation(c42338879.spop)
	c:RegisterEffect(e1)
	-- 表侧表示的这张卡从场上离开的场合除外。
	aux.AddBanishRedirect(c)
end
-- 判断特殊召唤条件是否满足
function c42338879.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 双方场上没有怪兽存在
	return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)==0
		-- 对方场上有怪兽存在，自己场上没有卡存在
		or (Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0))
		-- 场上存在可用召唤区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 设置特殊召唤时的等级
function c42338879.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 设置等级为3或4
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	-- 判断自己场上是否没有怪兽
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)==0 then
		e1:SetValue(3)
	else
		e1:SetValue(4)
	end
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end

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
	-- 为这张卡添加③效果：表侧表示的这张卡从场上离开的场合除外（离场时改送去除外区的重定向）。
	aux.AddBanishRedirect(c)
end
-- 特殊召唤规则的条件判定函数：c为nil时返回true以允许规则效果询问；否则判断当前控制者是否满足①或②的召唤条件，并确认主要怪兽区有空位。
function c42338879.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查双方主要怪兽区的怪兽数量是否为0，对应①的“双方场上没有怪兽存在的场合”。
	return (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)==0
		-- 或检查自己场上没有卡（场上区域无卡），且对方场上有怪兽存在，对应②的“对方场上有怪兽存在，自己场上没有卡存在的场合”。
		or (Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0))
		-- 同时还要确认自己主要怪兽区有空余区域可以进行特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 特殊召唤规则的处理函数：为这张卡临时附加一个等级变更效果，使其在本次特殊召唤中按场上情况变成3星或4星，并在离场等时机重置该变更。
function c42338879.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- ①：这张卡可以作为3星怪兽从手卡特殊召唤。②：这张卡可以作为4星怪兽从手卡特殊召唤。（通过变更等级为3或4来实现）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	-- 若双方场上都没有怪兽，则适用①，将这张卡的等级设置为3；否则说明对方场上有怪兽且自己场上无卡，适用②设置为4。
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,LOCATION_MZONE)==0 then
		e1:SetValue(3)
	else
		e1:SetValue(4)
	end
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end

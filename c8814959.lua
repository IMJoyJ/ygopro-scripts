--ヴェルズ・マンドラゴ
-- 效果：
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。
function c8814959.initial_effect(c)
	-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c8814959.spcon)
	c:RegisterEffect(e1)
end
-- 检查自身特殊召唤的条件是否满足（自身控制者场上有可用的怪兽区域，且对方场上的怪兽数量比自己场上的怪兽多）
function c8814959.spcon(e,c)
	if c==nil then return true end
	-- 检查自身控制者的主要怪兽区域是否有可用的空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上的怪兽数量是否小于对方场上的怪兽数量
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)<Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)
end

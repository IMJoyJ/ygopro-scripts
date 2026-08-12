--魔導ギガサイバー
-- 效果：
-- ①：自己场上的怪兽数量比对方场上的怪兽少2只以上的场合，这张卡可以从手卡特殊召唤。
function c66362965.initial_effect(c)
	-- ①：自己场上的怪兽数量比对方场上的怪兽少2只以上的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c66362965.spcon)
	c:RegisterEffect(e1)
end
-- 特殊召唤规则的条件判定
function c66362965.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有空余的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上的怪兽数量是否比自己场上多2只以上
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)-Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)>=2
end

--ギミック・パペット－マグネ・ドール
-- 效果：
-- ①：对方场上有怪兽存在，自己场上的怪兽只有「机关傀儡」怪兽的场合，这张卡可以从手卡特殊召唤。
function c39806198.initial_effect(c)
	-- ①：对方场上有怪兽存在，自己场上的怪兽只有「机关傀儡」怪兽的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c39806198.spcon)
	c:RegisterEffect(e1)
end
-- 满足特殊召唤条件时的判断函数
function c39806198.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查控制者场上是否有可用怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查控制者场上是否存在怪兽
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查对方场上是否存在怪兽
		and	Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查控制者场上是否不存在非「机关傀儡」怪兽
		and not Duel.IsExistingMatchingCard(c39806198.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：判断怪兽是否为里侧表示或不是「机关傀儡」怪兽
function c39806198.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x1083)
end

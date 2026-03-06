--ビッグ・ピース・ゴーレム
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
function c25247218.initial_effect(c)
	-- 效果原文内容：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25247218,0))  --"不解放进行召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c25247218.ntcon)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组，将目标怪兽特殊召唤
function c25247218.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断召唤所需最少解放数为0且怪兽等级大于等于5且自身所在玩家的怪兽区域存在空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断自身所在玩家的场上怪兽区没有怪兽
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 判断对方玩家的场上怪兽区存在怪兽
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
end

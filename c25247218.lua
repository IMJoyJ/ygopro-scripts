--ビッグ・ピース・ゴーレム
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
function c25247218.initial_effect(c)
	-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25247218,0))  --"不解放进行召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c25247218.ntcon)
	c:RegisterEffect(e1)
end
-- 该函数是“不用解放作召唤”这一规则召唤效果的召唤条件判定：若传入的怪兽c为空（用于规则效果自身存在性询问）则直接允许；否则须满足不解放、等级5以上、自己主要怪兽区有空位、自己场上无怪兽且对方场上有怪兽。
function c25247218.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定本次召唤的解放数量要求为0（即不解放），并且这张卡的等级在5以上，且自己主要怪兽区存在可用的空格。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判定自己场上没有怪兽（主要怪兽区怪兽数量为0），满足“自己场上没有怪兽存在”的条件。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 判定对方场上有怪兽（对方主要怪兽区怪兽数量大于0），满足“对方场上有怪兽存在”的条件。
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
end

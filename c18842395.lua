--パワー・インベーダー
-- 效果：
-- 对方场上有怪兽2只以上存在的场合，这张卡可以不用解放作召唤。
function c18842395.initial_effect(c)
	-- 这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18842395,0))  --"不用解放召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c18842395.ntcon)
	c:RegisterEffect(e1)
end
-- 无解放召唤的规则效果发动条件判定：若召唤的怪兽为nil（用于检查规则是否允许无解放召唤）则返回true；否则需满足无需解放、怪兽等级为5以上、自己主要怪兽区有空位，且对方场上有2只以上怪兽。
function c18842395.ntcon(e,c,minc)
	if c==nil then return true end
	-- 满足无解放召唤的基础条件：召唤时无需解放（minc==0）、这张卡是5星以上的怪兽，且自己主要怪兽区域存在可用的空格。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 满足无解放召唤的对方场条件：对方场上的主要怪兽区域存在2只以上的怪兽。
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>=2
end

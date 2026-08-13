--救世竜 セイヴァー・ドラゴン
-- 效果：
-- 把这张卡作为同调素材的场合，不是「救世」怪兽的同调召唤不能使用。
function c21159309.initial_effect(c)
	-- 把这张卡作为同调素材的场合，不是「救世」怪兽的同调召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c21159309.synlimit)
	c:RegisterEffect(e2)
end
-- 判定作为同调素材的怪兽：若该素材不是「救世」怪兽，则禁止将其作为同调素材（返回 true 使限制生效）。
function c21159309.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x3f)
end

--モノ・シンクロン
-- 效果：
-- 把这张卡作为同调素材的场合，其他的同调素材怪兽必须是4星以下的战士族·机械族怪兽，那些等级当作1星使用。
function c56897896.initial_effect(c)
	-- 把这张卡作为同调素材的场合，其他的同调素材怪兽必须是4星以下的战士族·机械族怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TUNER_MATERIAL_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetTarget(c56897896.synlimit)
	c:RegisterEffect(e1)
	-- 那些等级当作1星使用
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SYNCHRO_CHECK)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c56897896.syncheck)
	c:RegisterEffect(e2)
end
-- 限制同调素材必须是4星以下的战士族或机械族怪兽
function c56897896.synlimit(e,c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR+RACE_MACHINE)
end
-- 在进行同调素材检查时，将除自身以外的其他同调素材怪兽的等级当作1星使用
function c56897896.syncheck(e,c)
	if c~=e:GetHandler() then
		c:AssumeProperty(ASSUME_LEVEL,1)
	end
end

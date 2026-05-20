--E-HERO マリシャス・エッジ
function c58554959.initial_effect(c)
	-- 对方场上有怪兽存在的场合，这张卡可以解放1只怪兽进行上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58554959,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c58554959.otcon)
	e1:SetOperation(c58554959.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方其差值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 判断是否满足「对方场上有怪兽存在时，可以仅用1只祭品进行上级召唤」的条件
function c58554959.otcon(e,c,minc)
	if c==nil then return true end
	-- 检查对方场上是否存在怪兽
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 检查自身等级是否在7星以上、所需最少祭品数是否小于等于1，以及场上是否有1个可用的祭品
		and c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1)
end
-- 执行「仅用1只祭品进行上级召唤」时的解放操作
function c58554959.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家选择1只用于上级召唤的祭品怪兽
	local sg=Duel.SelectTribute(tp,c,1,1)
	c:SetMaterial(sg)
	-- 解放选中的怪兽，作为上级召唤的素材
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end

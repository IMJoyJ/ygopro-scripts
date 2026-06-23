--ハンマーラッシュ・バウンサー
-- 效果：
-- 对方场上有卡存在，自己场上没有卡存在的场合，这张卡可以不用解放作召唤。自己场上没有魔法·陷阱卡存在，这张卡向对方怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
function c44790889.initial_effect(c)
	-- 对方场上有卡存在，自己场上没有卡存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44790889,0))  --"不用解放召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c44790889.ntcon)
	c:RegisterEffect(e1)
	-- 自己场上没有魔法·陷阱卡存在，这张卡向对方怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c44790889.aclimit)
	e2:SetCondition(c44790889.actcon)
	c:RegisterEffect(e2)
end
-- 满足条件时可以不用解放作召唤
function c44790889.ntcon(e,c,minc)
	if c==nil then return true end
	-- 满足等级5以上且场上怪兽区有空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 满足自己场上没有怪兽
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0)==0
		-- 满足对方场上存在怪兽
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_ONFIELD)>0
end
-- 攻击阶段且攻击怪兽存在且对方场上没有魔法·陷阱卡
function c44790889.actcon(e)
	-- 攻击怪兽为自身且对方有攻击目标
	return Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil
		-- 对方场上没有魔法·陷阱卡
		and not Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 限制发动的为魔法·陷阱卡
function c44790889.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

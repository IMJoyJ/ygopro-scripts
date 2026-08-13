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
-- 无解放召唤的召唤规则条件：仅在无解放（minc==0）、这张卡等级5以上、自己主怪兽区有空位、自己场上没有卡且对方场上有卡时，允许进行无解放召唤。
function c44790889.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足无解放召唤的基础条件：必须是不需要解放的召唤（minc==0），且这张卡为5星以上，并且自己主要怪兽区有空位可用。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断自己场上没有卡：以这张卡的控制者为视角，自己场上（主要怪兽区+魔法与陷阱区）的卡数量为0。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0)==0
		-- 判断对方场上有卡：以这张卡的控制者为视角，对方场上（主要怪兽区+魔法与陷阱区）的卡数量大于0。
		and Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_ONFIELD)>0
end
-- 攻击限制效果的发动条件：这张卡进行攻击且攻击对象为对方怪兽，并且自己场上没有魔法·陷阱卡时，才会适用“对方不能发动魔法·陷阱卡”的限制。
function c44790889.actcon(e)
	-- 判断是否为这张卡向对方怪兽攻击：当前攻击怪兽是这张卡自身，且攻击目标存在（即攻击对象是怪兽而不是直接攻击）。
	return Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil
		-- 判断自己场上没有魔法·陷阱卡：以这张卡的控制者为视角，自己场上不存在表侧或里侧的魔法·陷阱卡（类型为魔法或陷阱的卡）。
		and not Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 该效果限制的是“魔法·陷阱卡的发动”：当对方发动的效果具有效果发动类型（EFFECT_TYPE_ACTIVATE，即魔法·陷阱卡的发动）时，返回true使其不能发动。
function c44790889.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

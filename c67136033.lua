--熱血獣王ベアーマン
-- 效果：
-- 把这张卡作为超量召唤的素材的场合，不是战士族·炎属性怪兽的超量召唤不能使用。
-- ①：这张卡可以不用解放作召唤。这个方法召唤的这张卡的原本攻击力变成1300。
-- ②：1回合1次，自己主要阶段才能发动。自己场上的全部兽战士族·4星怪兽的等级直到回合结束时变成8星。
function c67136033.initial_effect(c)
	-- ①：这张卡可以不用解放作召唤。这个方法召唤的这张卡的原本攻击力变成1300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67136033,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c67136033.ntcon)
	e1:SetOperation(c67136033.ntop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。自己场上的全部兽战士族·4星怪兽的等级直到回合结束时变成8星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67136033,1))  --"等级变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c67136033.lvtg)
	e2:SetOperation(c67136033.lvop)
	c:RegisterEffect(e2)
	-- 把这张卡作为超量召唤的素材的场合，不是战士族·炎属性怪兽的超量召唤不能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e3:SetValue(c67136033.xyzlimit)
	c:RegisterEffect(e3)
end
-- 不用解放召唤的条件判定函数
function c67136033.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定是否满足不用解放召唤的条件（需要是5星以上怪兽，且自己场上有可用的怪兽区域）
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 不用解放召唤成功时的效果处理函数（设置原本攻击力）
function c67136033.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法召唤的这张卡的原本攻击力变成1300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(1300)
	c:RegisterEffect(e1)
end
-- 过滤自己场上的兽战士族·4星怪兽
function c67136033.filter(c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsLevel(4)
end
-- 等级变化效果的发动条件与对象选择（Target）函数
function c67136033.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足条件的兽战士族·4星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67136033.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 等级变化效果的执行（Operation）函数
function c67136033.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有的兽战士族·4星怪兽
	local g=Duel.GetMatchingGroup(c67136033.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 等级直到回合结束时变成8星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 限制超量素材只能用于战士族·炎属性怪兽的超量召唤
function c67136033.xyzlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_FIRE) or not c:IsRace(RACE_WARRIOR)
end

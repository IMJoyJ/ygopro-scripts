--プリミティブ・バタフライ
-- 效果：
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：1回合1次，自己主要阶段才能发动。自己场上的全部昆虫族怪兽的等级上升1星。
function c98154550.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c98154550.spcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。自己场上的全部昆虫族怪兽的等级上升1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98154550,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c98154550.target)
	e2:SetOperation(c98154550.operation)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件函数：检查自己场上没有怪兽存在且有可用的怪兽区域
function c98154550.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤函数：筛选自己场上表侧表示、等级大于0的昆虫族怪兽
function c98154550.filter(c)
	return c:IsFaceup() and c:GetLevel()>0 and c:IsRace(RACE_INSECT)
end
-- 效果发动的目标检查：检查自己场上是否存在至少1只满足条件的昆虫族怪兽
function c98154550.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否存在至少1只表侧表示且等级大于0的昆虫族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c98154550.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：获取自己场上所有满足条件的昆虫族怪兽，并使它们的等级上升1星
function c98154550.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示且等级大于0的昆虫族怪兽
	local g=Duel.GetMatchingGroup(c98154550.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 等级上升1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

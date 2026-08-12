--光波翼機
-- 效果：
-- ①：自己场上有「光波」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：把这张卡解放才能发动。自己场上的全部「光波」怪兽的等级直到回合结束时上升4星。
function c81974607.initial_effect(c)
	-- ①：自己场上有「光波」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c81974607.spcon)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。自己场上的全部「光波」怪兽的等级直到回合结束时上升4星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81974607,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c81974607.lvcost)
	e2:SetTarget(c81974607.lvtg)
	e2:SetOperation(c81974607.lvop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「光波」怪兽
function c81974607.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe5)
end
-- 特殊召唤规则的条件：自身控制者的主要怪兽区域有空位，且自己场上存在「光波」怪兽
function c81974607.spcon(e,c)
	if c==nil then return true end
	-- 检查自身控制者的主要怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己场上是否存在至少1张表侧表示的「光波」怪兽
		Duel.IsExistingMatchingCard(c81974607.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 发动代价（Cost）：将自身解放
function c81974607.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 作为发动代价，解放自身
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：自己场上表侧表示、等级大于0的「光波」怪兽
function c81974607.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe5) and c:GetLevel()>0
end
-- 效果的目标（Target）：检查自己场上是否存在除自身以外的、满足条件的「光波」怪兽
function c81974607.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否存在至少1张除自身以外的、表侧表示且等级大于0的「光波」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c81974607.lvfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
end
-- 效果的运行空间（Operation）：获取自己场上所有满足条件的「光波」怪兽，并使其等级直到回合结束时上升4星
function c81974607.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示且等级大于0的「光波」怪兽
	local g=Duel.GetMatchingGroup(c81974607.lvfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 等级直到回合结束时上升4星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

--バブルイリュージョン
-- 效果：
-- 「元素英雄 水泡侠」在自己场上表侧表示存在时才能发动。这个回合，自己可以从手卡发动1张陷阱卡。
function c80075749.initial_effect(c)
	-- 为卡片添加「英雄」系列怪兽列表，以便进行系列判定。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 「元素英雄 水泡侠」在自己场上表侧表示存在时才能发动。这个回合，自己可以从手卡发动1张陷阱卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c80075749.condition)
	e1:SetOperation(c80075749.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：检查卡片是否为表侧表示且卡名为「元素英雄 水泡侠」。
function c80075749.filter(c)
	return c:IsFaceup() and c:IsCode(79979666)
end
-- 发动条件：自己场上存在表侧表示的「元素英雄 水泡侠」。
function c80075749.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「元素英雄 水泡侠」。
	return Duel.IsExistingMatchingCard(c80075749.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果处理：创建一个全局效果，允许玩家在本回合从手卡发动1张陷阱卡。
function c80075749.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己可以从手卡发动1张陷阱卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(80075749,0))  --"适用「水泡幻像」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1,80075749)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将允许从手卡发动陷阱卡的效果注册给发动玩家。
	Duel.RegisterEffect(e1,tp)
end

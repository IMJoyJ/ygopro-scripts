--E-HERO デス・プリズン
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：「暗黑融合」的效果才能特殊召唤的融合怪兽在自己场上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：从卡组把1只「英雄」怪兽送去墓地才能发动。这个回合，「英雄」融合怪兽融合召唤的场合，表侧表示的这张卡可以作为那只融合怪兽有卡名记述的1只融合素材怪兽代用（其他的融合素材不能代用）。
local s,id,o=GetID()
-- 初始化效果函数，注册特殊召唤和发动效果
function s.initial_effect(c)
	-- 记录该卡具有「暗黑融合」的卡名
	aux.AddCodeList(c,94820406)
	-- ①：「暗黑融合」的效果才能特殊召唤的融合怪兽在自己场上存在的场合，这张卡可以从手卡特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：从卡组把1只「英雄」怪兽送去墓地才能发动。这个回合，「英雄」融合怪兽融合召唤的场合，表侧表示的这张卡可以作为那只融合怪兽有卡名记述的1只融合素材怪兽代用
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.cost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 判断场上是否存在表侧表示的「暗黑融合」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c.dark_calling
end
-- 判断是否满足特殊召唤条件，包括有空场和场上存在「暗黑融合」怪兽
function s.spcon(e,c)
	if c==nil then return true end
	-- 判断自己场上是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断自己场上是否存在「暗黑融合」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于筛选可以作为代价送去墓地的「英雄」怪兽
function s.costfilter(c,ec)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 发动效果时的处理函数，选择并送去墓地1只「英雄」怪兽
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足发动条件，即自己卡组是否存在符合条件的「英雄」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,c) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1只符合条件的「英雄」怪兽送去墓地
	local cg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil,c)
	-- 将选中的卡送去墓地作为发动代价
	Duel.SendtoGrave(cg,REASON_COST)
end
-- 发动效果时的处理函数，使该卡获得融合素材代用效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 使该卡获得融合素材代用效果，可以代替「英雄」融合怪兽的融合素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(s.subval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"代替素材效果适用中"
end
-- 代用效果的判断函数，判断目标怪兽是否为「英雄」怪兽
function s.subval(e,c)
	return c:IsSetCard(0x8)
end

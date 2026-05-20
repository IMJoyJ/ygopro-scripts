--呪眼の眷属 バジリウス
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「咒眼」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从卡组把1张「咒眼」魔法·陷阱卡送去墓地。
function c81344637.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「咒眼」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81344637,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,81344637+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c81344637.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己主要阶段才能发动。从卡组把1张「咒眼」魔法·陷阱卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81344637,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,81344638)
	e2:SetTarget(c81344637.target)
	e2:SetOperation(c81344637.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「咒眼」怪兽
function c81344637.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x129)
end
-- 特殊召唤规则的判定条件
function c81344637.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的「咒眼」怪兽
		and Duel.IsExistingMatchingCard(c81344637.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡组中可以送去墓地的「咒眼」魔法·陷阱卡
function c81344637.tgfilter(c)
	return c:IsSetCard(0x129) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 效果②的发动准备与合法性检查
function c81344637.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张满足条件的「咒眼」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c81344637.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁中的操作信息：将卡组中的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理
function c81344637.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的「咒眼」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c81344637.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

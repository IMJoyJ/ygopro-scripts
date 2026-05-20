--ミスト・コンドル
-- 效果：
-- 这张卡可以让自己场上表侧表示存在的1只名字带有「霞之谷」的怪兽回到手卡，从手卡特殊召唤。这个方法特殊召唤的这张卡的攻击力变成1700。
function c65549080.initial_effect(c)
	-- 这张卡可以让自己场上表侧表示存在的1只名字带有「霞之谷」的怪兽回到手卡，从手卡特殊召唤。这个方法特殊召唤的这张卡的攻击力变成1700。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c65549080.spcon)
	e1:SetTarget(c65549080.sptg)
	e1:SetOperation(c65549080.spop)
	c:RegisterEffect(e1)
end
-- 过滤满足特殊召唤Cost条件的卡片（自己场上表侧表示的「霞之谷」怪兽，且能返回手牌，且返回后有可用的怪兽区域）
function c65549080.spfilter(c,tp)
	-- 检查卡片是否为表侧表示、属于「霞之谷」系列、能作为Cost返回手牌，且该卡离开场上后有可用的怪兽区域
	return c:IsFaceup() and c:IsSetCard(0x37) and c:IsAbleToHandAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的Condition函数，判断是否满足特殊召唤的条件
function c65549080.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足特殊召唤Cost条件的怪兽
	return Duel.IsExistingMatchingCard(c65549080.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤规则的Target函数，用于选择作为Cost返回手牌的怪兽
function c65549080.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足特殊召唤Cost条件的怪兽组
	local g=Duel.GetMatchingGroup(c65549080.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 给玩家发送提示信息，提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的Operation函数，执行将怪兽返回手牌并特殊召唤自身，同时改变自身攻击力的操作
function c65549080.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽作为特殊召唤的Cost返回持有者手牌
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
	-- 这个方法特殊召唤的这张卡的攻击力变成1700。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(1700)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end

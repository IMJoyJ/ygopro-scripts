--EMハンマーマンモ
-- 效果：
-- ①：自己场上有「娱乐伙伴」卡2张以上存在的场合，这张卡可以不用解放作召唤。
-- ②：自己场上没有其他的「娱乐伙伴」卡存在的场合，这张卡不能攻击。
-- ③：这张卡的攻击宣言时才能发动。对方场上的魔法·陷阱卡全部回到持有者手卡。
function c340002.initial_effect(c)
	-- 效果原文：①：自己场上有「娱乐伙伴」卡2张以上存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(340002,0))  --"不用解放召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c340002.ntcon)
	c:RegisterEffect(e1)
	-- 效果原文：②：自己场上没有其他的「娱乐伙伴」卡存在的场合，这张卡不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(c340002.atkcon)
	c:RegisterEffect(e2)
	-- 效果原文：③：这张卡的攻击宣言时才能发动。对方场上的魔法·陷阱卡全部回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetTarget(c340002.thtg)
	e3:SetOperation(c340002.thop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「娱乐伙伴」卡，用于判断是否满足召唤条件
function c340002.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 判断是否满足不用解放召唤的条件，包括等级、场地空位和「娱乐伙伴」卡数量
function c340002.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断召唤怪兽的等级是否大于等于5且场上存在空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断自己场上是否存在至少2张「娱乐伙伴」卡
		and Duel.IsExistingMatchingCard(c340002.cfilter,c:GetControler(),LOCATION_ONFIELD,0,2,nil)
end
-- 判断是否满足不能攻击的条件，即自己场上不存在其他「娱乐伙伴」卡
function c340002.atkcon(e)
	-- 判断自己场上是否存在至少1张「娱乐伙伴」卡
	return not Duel.IsExistingMatchingCard(c340002.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 检索满足条件的魔法·陷阱卡，用于效果发动时的目标选择
function c340002.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果发动时的处理目标，检索对方场上的魔法·陷阱卡
function c340002.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否存在至少1张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c340002.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有魔法·陷阱卡作为处理目标
	local g=Duel.GetMatchingGroup(c340002.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，指定效果处理类别为回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 设置效果发动时的处理操作，将对方场上的魔法·陷阱卡送回手牌
function c340002.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有魔法·陷阱卡作为处理目标
	local g=Duel.GetMatchingGroup(c340002.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 将目标魔法·陷阱卡以效果原因送回持有者手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end

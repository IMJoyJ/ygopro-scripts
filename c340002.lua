--EMハンマーマンモ
-- 效果：
-- ①：自己场上有「娱乐伙伴」卡2张以上存在的场合，这张卡可以不用解放作召唤。
-- ②：自己场上没有其他的「娱乐伙伴」卡存在的场合，这张卡不能攻击。
-- ③：这张卡的攻击宣言时才能发动。对方场上的魔法·陷阱卡全部回到持有者手卡。
function c340002.initial_effect(c)
	-- ①：自己场上有「娱乐伙伴」卡2张以上存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(340002,0))  --"不用解放召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c340002.ntcon)
	c:RegisterEffect(e1)
	-- ②：自己场上没有其他的「娱乐伙伴」卡存在的场合，这张卡不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(c340002.atkcon)
	c:RegisterEffect(e2)
	-- ③：这张卡的攻击宣言时才能发动。对方场上的魔法·陷阱卡全部回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetTarget(c340002.thtg)
	e3:SetOperation(c340002.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判定卡片为表侧表示且属于「娱乐伙伴」系列（0x9f）。
function c340002.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 无解放召唤的规则条件：c为空时视为满足规则处理；否则需满足无解放要求、这张卡等级5以上、自己场上有空位，且自己场上有2张以上表侧「娱乐伙伴」卡。
function c340002.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查无需解放（minc==0）、这张卡等级不低于5，以及自己场上存在可用于通常召唤的主要怪兽区空格。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 追加检查：自己场上（主要怪兽区或魔法陷阱区）存在至少2张表侧表示的「娱乐伙伴」卡。
		and Duel.IsExistingMatchingCard(c340002.cfilter,c:GetControler(),LOCATION_ONFIELD,0,2,nil)
end
-- 攻击限制条件：自己场上没有其他表侧表示的「娱乐伙伴」卡存在时不能攻击。
function c340002.atkcon(e)
	-- 判断自己场上是否存在除这张卡以外的表侧「娱乐伙伴」卡；不存在时条件成立（禁止攻击）。
	return not Duel.IsExistingMatchingCard(c340002.cfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 过滤函数：判定对方场上的卡为魔法或陷阱卡，并且可以被加入手卡。
function c340002.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 触发效果的目标设定：发动时确定对方场上有满足条件的魔法·陷阱卡，并登记将全部这类卡送回手卡的操作信息。
function c340002.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：对方场上有至少1张满足条件（魔法·陷阱且能回手）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c340002.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有满足条件的魔法·陷阱卡（不取对象）。
	local g=Duel.GetMatchingGroup(c340002.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：将上述全部卡以回手牌效果处理，数量为该组的卡片数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：获取对方场上所有满足条件的魔法·陷阱卡，并将其全部送回持有者手卡。
function c340002.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方场上全部满足条件的魔法·陷阱卡。
	local g=Duel.GetMatchingGroup(c340002.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因将这些卡送回持有者的手卡。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end

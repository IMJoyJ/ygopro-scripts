--U.A.フィールドゼネラル
-- 效果：
-- 「超级运动员 四分卫球员」的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以让「超级运动员 四分卫球员」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
-- ②：这张卡以外的自己的「超级运动员」怪兽的攻击宣言时才能发动。这张卡的攻击力下降800，自己的攻击怪兽的攻击力上升800。
function c98229575.initial_effect(c)
	-- 「超级运动员 四分卫球员」的①的方法的特殊召唤1回合只能有1次。①：这张卡可以让「超级运动员 四分卫球员」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,98229575+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c98229575.spcon)
	e1:SetTarget(c98229575.sptg)
	e1:SetOperation(c98229575.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡以外的自己的「超级运动员」怪兽的攻击宣言时才能发动。这张卡的攻击力下降800，自己的攻击怪兽的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c98229575.atkcon)
	e2:SetOperation(c98229575.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选自己场上表侧表示、除「超级运动员 四分卫球员」以外的「超级运动员」怪兽，且该怪兽能返回手卡、其离开后有可用的怪兽区域
function c98229575.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and not c:IsCode(98229575) and c:IsAbleToHandAsCost()
		-- 检查该卡离开场上后，自己场上是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件：检查自己场上是否存在满足过滤条件的怪兽
function c98229575.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c98229575.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤规则的目标选择：让玩家选择1只满足过滤条件的怪兽，并将其记录为操作对象
function c98229575.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c98229575.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作：将选中的怪兽送回手卡
function c98229575.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽因特殊召唤原因送回手卡
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 效果②的发动条件：攻击宣言的怪兽是自己场上除这张卡以外的「超级运动员」怪兽，且这张卡的攻击力在800以上
function c98229575.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽
	local at=Duel.GetAttacker()
	return at:IsSetCard(0xb2) and at:IsControler(tp) and at~=e:GetHandler() and e:GetHandler():IsAttackAbove(800)
end
-- 效果②的效果处理：使这张卡的攻击力下降800，并使进行攻击的怪兽的攻击力上升800
function c98229575.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前进行攻击的怪兽
	local at=Duel.GetAttacker()
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsAttackAbove(800) then
		-- 这张卡的攻击力下降800
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(-800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		if at:IsFaceup() and at:IsRelateToBattle() then
			local e2=e1:Clone()
			e2:SetValue(800)
			at:RegisterEffect(e2)
		end
	end
end

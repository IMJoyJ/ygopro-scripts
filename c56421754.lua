--U.A.マイティスラッガー
-- 效果：
-- 「超级运动员 猛力强击手」的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以让「超级运动员 猛力强击手」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
-- ②：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
function c56421754.initial_effect(c)
	-- 「超级运动员 猛力强击手」的①的方法的特殊召唤1回合只能有1次。①：这张卡可以让「超级运动员 猛力强击手」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,56421754+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c56421754.spcon)
	e1:SetTarget(c56421754.sptg)
	e1:SetOperation(c56421754.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(c56421754.actcon)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「超级运动员」怪兽（「超级运动员 猛力强击手」除外），且能返回手卡，并且在返回手卡后有可用的怪兽区域
function c56421754.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and not c:IsCode(56421754) and c:IsAbleToHandAsCost()
		-- 检查将该怪兽返回手卡后，自己场上是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件：自己场上存在满足过滤条件的怪兽
function c56421754.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c56421754.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤规则的目标：选择自己场上1只满足过滤条件的怪兽，并将其记录为要操作的对象
function c56421754.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c56421754.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 给玩家发送提示信息，提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作：将选中的怪兽返回手卡，随后这张卡从手卡特殊召唤
function c56421754.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽因特殊召唤手续返回持有者手卡
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 封锁效果发动的条件：这张卡是当前的攻击怪兽
function c56421754.actcon(e)
	-- 检查当前进行攻击的怪兽是否是这张卡自身
	return Duel.GetAttacker()==e:GetHandler()
end

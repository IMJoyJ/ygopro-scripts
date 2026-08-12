--U.A.カストディアン
-- 效果：
-- 「超级运动员 守门员」的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以让「超级运动员 守门员」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
-- ②：对方回合1次，以自己场上1只「超级运动员」怪兽为对象才能发动。那只怪兽在这个回合只有1次不会被战斗·效果破坏。
function c9485511.initial_effect(c)
	-- 「超级运动员 守门员」的①的方法的特殊召唤1回合只能有1次。①：这张卡可以让「超级运动员 守门员」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,9485511+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c9485511.spcon)
	e1:SetTarget(c9485511.sptg)
	e1:SetOperation(c9485511.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合1次，以自己场上1只「超级运动员」怪兽为对象才能发动。那只怪兽在这个回合只有1次不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9485511,0))  --"破坏耐性"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c9485511.indcon)
	e2:SetTarget(c9485511.indtg)
	e2:SetOperation(c9485511.indop)
	c:RegisterEffect(e2)
end
-- 过滤自身以外的自己场上表侧表示的「超级运动员」怪兽，且该怪兽能回到手卡，并且其离开后能腾出怪兽区域
function c9485511.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and not c:IsCode(9485511) and c:IsAbleToHandAsCost()
		-- 检查该怪兽回到手卡后，自己场上是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件判定函数
function c9485511.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在满足特殊召唤条件的「超级运动员」怪兽
	return Duel.IsExistingMatchingCard(c9485511.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤规则的目标选择函数
function c9485511.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足特殊召唤条件的「超级运动员」怪兽组
	local g=Duel.GetMatchingGroup(c9485511.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 提示玩家选择要返回手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作函数
function c9485511.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽因特殊召唤原因送回手卡
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 过滤自己场上表侧表示的「超级运动员」怪兽
function c9485511.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb2)
end
-- 效果②的发动条件判定函数
function c9485511.indcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 效果②的发动准备与目标选择函数
function c9485511.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c9485511.filter(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示「超级运动员」怪兽
	if chk==0 then return Duel.IsExistingTarget(c9485511.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「超级运动员」怪兽作为效果对象
	Duel.SelectTarget(tp,c9485511.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的执行操作函数
function c9485511.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 那只怪兽在这个回合只有1次不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCountLimit(1)
		e1:SetValue(c9485511.valcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 过滤破坏原因，判定是否为战斗或效果破坏
function c9485511.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end

--トランザクション・ロールバック
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把基本分支付一半，以「事务回滚」以外的对方墓地1张通常陷阱卡为对象才能发动。这个效果变成和那张通常陷阱卡发动时的效果相同。
-- ②：把墓地的这张卡除外，把基本分支付一半，以「事务回滚」以外的自己墓地1张通常陷阱卡为对象才能发动。这个效果变成和那张通常陷阱卡发动时的效果相同。
local s,id,o=GetID()
-- 注册卡片效果：①效果（场上发动）和②效果（墓地发动），并设置同名卡一回合只能选择其中任意一个发动一次。
function s.initial_effect(c)
	-- ①：把基本分支付一半，以「事务回滚」以外的对方墓地1张通常陷阱卡为对象才能发动。这个效果变成和那张通常陷阱卡发动时的效果相同。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，把基本分支付一半，以「事务回滚」以外的自己墓地1张通常陷阱卡为对象才能发动。这个效果变成和那张通常陷阱卡发动时的效果相同。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_CHAIN_END+TIMING_END_PHASE)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：支付一半基本分。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半基本分。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- ②效果的发动代价：将墓地的这张卡除外，并支付一半基本分。
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	-- 将墓地的这张卡除外。
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	-- 支付一半基本分。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤条件：除「事务回滚」等特定卡以外的通常陷阱卡，且该卡具有可发动的效果。
function s.filter(c)
	return c:GetType()==TYPE_TRAP and not c:IsCode(id,79766336,22628574) and c:CheckActivateEffect(false,true,false)~=nil
end
-- 效果发动时的对象选择与效果复制处理：根据发动位置确定在对方或自己墓地选择目标，并复制该陷阱卡的发动效果及相关属性。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	local loc1,loc2=0,LOCATION_GRAVE
	if e:GetType()&EFFECT_TYPE_QUICK_O>0 then loc1,loc2=LOCATION_GRAVE,0 end
	-- 检查是否存在可作为对象的目标通常陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,loc1,loc2,1,nil) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择墓地中1张满足条件的通常陷阱卡作为对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,loc1,loc2,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 清除当前连锁的对象，防止被其他卡片连锁响应或影响。
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	e:SetProperty(te:GetProperty())
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，防止该效果被其他卡片响应。
	Duel.ClearOperationInfo(0)
end
-- 效果处理：执行被复制的通常陷阱卡的效果。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local tc=te:GetHandler()
	if not (tc:IsRelateToEffect(e) and tc:GetType()==TYPE_TRAP) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end

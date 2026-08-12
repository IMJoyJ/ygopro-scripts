--武神器－マフツ
-- 效果：
-- ①：自己场上的「武神」怪兽被和对方怪兽的战斗破坏送去自己墓地时，把这张卡从手卡送去墓地才能发动。那只对方怪兽破坏。
function c11958188.initial_effect(c)
	-- ①：自己场上的「武神」怪兽被和对方怪兽的战斗破坏送去自己墓地时，把这张卡从手卡送去墓地才能发动。那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11958188,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c11958188.descon)
	e1:SetCost(c11958188.descost)
	e1:SetTarget(c11958188.destg)
	e1:SetOperation(c11958188.desop)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的怪兽：是「武神」卡、当前控制者是玩家、上一个控制者是玩家、在墓地、被战斗破坏
function c11958188.cfilter(c,tp)
	return c:IsSetCard(0x88) and c:IsControler(tp) and c:IsPreviousControler(tp)
		and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
end
-- 效果发动条件：场上被战斗破坏的「武神」怪兽数量大于0
function c11958188.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c11958188.cfilter,nil,tp)
	e:SetLabelObject(g:GetFirst())
	return g:GetCount()>0
end
-- 效果发动费用：将自身送去墓地作为费用
function c11958188.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身从手牌送去墓地作为发动费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置效果处理目标：将对方怪兽设为破坏对象
function c11958188.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject():GetReasonCard()
	if chk==0 then return tc:IsRelateToBattle() end
	-- 设置连锁操作信息：确定要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果处理函数：对目标怪兽进行破坏
function c11958188.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetReasonCard()
	if tc:IsRelateToBattle() then
		-- 对目标怪兽进行效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

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
-- 筛选出自己场上被对方怪兽战斗破坏后送去自己墓地的「武神」怪兽：它必须持有「武神」字段、当前控制者为自己、上一个控制者为自己、位于墓地且破坏原因是战斗破坏。
function c11958188.cfilter(c,tp)
	return c:IsSetCard(0x88) and c:IsControler(tp) and c:IsPreviousControler(tp)
		and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
end
-- 发动条件：当战斗破坏送入墓地的事件发生时，从相关怪兽中筛选满足条件的「武神」怪兽，若存在则先记录其中一只，并返回真以允许发动。
function c11958188.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c11958188.cfilter,nil,tp)
	e:SetLabelObject(g:GetFirst())
	return g:GetCount()>0
end
-- 发动代价：检查这张卡是否可以从手卡送去墓地作为代价；若可以，在实际发动时支付该代价。
function c11958188.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡从手卡送去墓地，作为发动效果的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 取对象：取出被记录的战斗破坏的「武神」怪兽的战斗来源（即对方怪兽），若该怪兽仍与本次战斗关联则合法，并登记将破坏该怪兽。
function c11958188.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject():GetReasonCard()
	if chk==0 then return tc:IsRelateToBattle() end
	-- 设置操作信息：效果处理时将破坏1只已确定的对方怪兽，供连锁判定等系统查询。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果处理：取出之前记录的对方怪兽，若其仍与本次战斗关联，则将其破坏。
function c11958188.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetReasonCard()
	if tc:IsRelateToBattle() then
		-- 将那只对方怪兽以效果破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

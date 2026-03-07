--リンクスレイヤー
-- 效果：
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：1回合1次，把最多2张手卡丢弃，以丢弃数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
function c35595518.initial_effect(c)
	-- 效果原文内容：①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c35595518.spcon)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：1回合1次，把最多2张手卡丢弃，以丢弃数量的场上的魔法·陷阱卡为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35595518,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c35595518.cost)
	e2:SetTarget(c35595518.target)
	e2:SetOperation(c35595518.operation)
	c:RegisterEffect(e2)
end
-- 规则层面操作：检查是否满足特殊召唤条件，即自己场上没有怪兽且有可用怪兽区域。
function c35595518.spcon(e,c)
	if c==nil then return true end
	-- 规则层面操作：检查自己场上是否没有怪兽。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 规则层面操作：检查自己场上是否有可用怪兽区域。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 规则层面操作：设置效果发动的代价，丢弃1到2张手卡。
function c35595518.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查玩家手卡是否存在可丢弃的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面操作：获取场上魔法·陷阱卡的数量。
	local rt=Duel.GetTargetCount(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if rt>2 then rt=2 end
	-- 规则层面操作：执行丢弃手卡的操作。
	local ct=Duel.DiscardHand(tp,nil,1,rt,REASON_DISCARD+REASON_COST)
	e:SetLabel(ct)
end
-- 规则层面操作：设置效果的目标，选择场上魔法·陷阱卡进行破坏。
function c35595518.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 规则层面操作：检查场上是否存在魔法·陷阱卡作为目标。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	local ct=e:GetLabel()
	-- 规则层面操作：向玩家发送提示信息，提示选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 规则层面操作：选择场上指定数量的魔法·陷阱卡作为破坏对象。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil,TYPE_SPELL+TYPE_TRAP)
	-- 规则层面操作：设置效果处理时的操作信息，确定要破坏的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
end
-- 规则层面操作：执行效果的破坏处理。
function c35595518.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁中设定的目标卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
	if rg:GetCount()>0 then
		-- 规则层面操作：以效果原因破坏目标卡片。
		Duel.Destroy(rg,REASON_EFFECT)
	end
end

--闇のデッキ破壊ウイルス
-- 效果：
-- ①：把自己场上1只攻击力2500以上的暗属性怪兽解放，宣言卡的种类（魔法·陷阱）才能发动。对方场上的魔法·陷阱卡，对方手卡，用对方回合计算的3回合内对方抽到的卡全部确认，那之内的宣言种类的卡全部破坏。
function c54974237.initial_effect(c)
	-- ①：把自己场上1只攻击力2500以上的暗属性怪兽解放，宣言卡的种类（魔法·陷阱）才能发动。对方场上的魔法·陷阱卡，对方手卡，用对方回合计算的3回合内对方抽到的卡全部确认，那之内的宣言种类的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_TOHAND+TIMING_END_PHASE)
	e1:SetCost(c54974237.cost)
	e1:SetTarget(c54974237.target)
	e1:SetOperation(c54974237.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上攻击力2500以上的暗属性怪兽。
function c54974237.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:GetAttack()>=2500
end
-- 发动代价：解放自己场上1只满足条件的怪兽。
function c54974237.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足过滤条件的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c54974237.costfilter,1,nil) end
	-- 玩家选择1只满足过滤条件的怪兽用于解放。
	local g=Duel.SelectReleaseGroup(tp,c54974237.costfilter,1,1,nil)
	-- 将选中的怪兽解放。
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：对方场上表侧表示的指定种类的卡。
function c54974237.tgfilter(c,ty)
	return c:IsFaceup() and c:IsType(ty)
end
-- 效果发动时的处理：宣言卡的种类，并确定要破坏的卡的信息。
function c54974237.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家进行卡片种类的宣言。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(54974237,2))  --"请宣言卡的种类"
	-- 让玩家选择宣言“魔法卡”或“陷阱卡”。
	local ac=Duel.SelectOption(tp,aux.Stringid(54974237,0),aux.Stringid(54974237,1))  --"魔法卡/陷阱卡"
	local ty=TYPE_SPELL
	if ac==1 then ty=TYPE_TRAP end
	e:SetLabel(ty)
	-- 获取对方场上所有满足过滤条件的表侧表示卡片。
	local g=Duel.GetMatchingGroup(c54974237.tgfilter,tp,0,LOCATION_ONFIELD,nil,ty)
	-- 设置效果处理时的操作信息为破坏对方场上这些卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 过滤条件：对方的手卡，以及对方场上里侧表示的魔法·陷阱卡。
function c54974237.cffilter(c)
	return c:IsLocation(LOCATION_HAND) or (c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP))
end
-- 效果处理：确认对方场上的魔法·陷阱卡和手卡并破坏宣言种类的卡，并注册在3回合内持续适用的效果。
function c54974237.activate(e,tp,eg,ep,ev,re,r,rp)
	local ty=e:GetLabel()
	-- 获取对方场上和手卡的所有卡片。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD+LOCATION_HAND)
	if g:GetCount()>0 then
		local cg=g:Filter(c54974237.cffilter,nil)
		-- 给发动效果的玩家确认对方的手卡以及场上里侧表示的魔法·陷阱卡。
		Duel.ConfirmCards(tp,cg)
		local dg=g:Filter(Card.IsType,nil,ty)
		-- 破坏其中所有属于宣言种类的卡。
		Duel.Destroy(dg,REASON_EFFECT)
		-- 将对方的手卡洗切。
		Duel.ShuffleHand(1-tp)
	end
	-- 用对方回合计算的3回合内对方抽到的卡全部确认，那之内的宣言种类的卡全部破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)
	e1:SetOperation(c54974237.desop)
	e1:SetLabel(ty)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 注册在对方抽卡时触发确认并破坏效果的全局效果。
	Duel.RegisterEffect(e1,tp)
	-- 用对方回合计算的3回合内
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c54974237.turncon)
	e2:SetOperation(c54974237.turnop)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
	-- 注册用于在回合结束时累计回合数并维护计数器的全局效果。
	Duel.RegisterEffect(e2,tp)
	e2:SetLabelObject(e1)
	e:GetHandler():RegisterFlagEffect(1082946,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,3)
	c54974237[e:GetHandler()]=e2
end
-- 对方抽卡时的效果处理：确认抽到的卡，并将其中属于宣言种类的卡破坏。
function c54974237.desop(e,tp,eg,ep,ev,re,r,rp)
	if ep==e:GetOwnerPlayer() then return end
	local hg=eg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if hg:GetCount()==0 then return end
	-- 给发动效果的玩家确认对方抽到的卡。
	Duel.ConfirmCards(1-ep,hg)
	local dg=hg:Filter(Card.IsType,nil,e:GetLabel())
	-- 破坏抽到的卡中属于宣言种类的卡。
	Duel.Destroy(dg,REASON_EFFECT)
	-- 将对方的手卡洗切。
	Duel.ShuffleHand(ep)
end
-- 回合结束时效果的触发条件：当前回合不是本方玩家的回合（即对方回合）。
function c54974237.turncon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方玩家。
	return Duel.GetTurnPlayer()~=tp
end
-- 回合结束时的效果处理：回合计数器加1，满3回合时重置相关效果。
function c54974237.turnop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct+1
	e:SetLabel(ct)
	e:GetHandler():SetTurnCounter(ct)
	if ct==3 then
		e:GetLabelObject():Reset()
		e:GetOwner():ResetFlagEffect(1082946)
	end
end

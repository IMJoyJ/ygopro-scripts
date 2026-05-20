--アロマリリス－マグノリア
-- 效果：
-- 「芳香」怪兽＋植物族怪兽
-- ①：只要自己基本分比对方多并有这张卡在怪兽区域存在，自己场上的植物族怪兽不会被对方的效果破坏。
-- ②：1回合1次，支付2000基本分才能发动。把自己场上的「湿润之风」「干渴之风」「恩惠之风」数量的场上的卡除外。
-- ③：1回合1次，自己基本分回复的场合才能发动（伤害步骤也能发动）。自己场上的全部植物族怪兽的攻击力直到回合结束时上升那个数值。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤手续、①效果（植物族不会被对方效果破坏）、②效果（支付2000基本分除外场上的卡）、③效果（回复基本分时自己场上植物族攻击力上升）。
function c73167098.initial_effect(c)
	-- 设置融合召唤手续为：「芳香」怪兽＋植物族怪兽各1只。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xc9),aux.FilterBoolFunction(Card.IsRace,RACE_PLANT),true)
	c:EnableReviveLimit()
	-- ①：只要自己基本分比对方多并有这张卡在怪兽区域存在，自己场上的植物族怪兽不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.indcon)
	e1:SetTarget(s.indtg)
	-- 设置不会被对方的卡的效果破坏。
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，支付2000基本分才能发动。把自己场上的「湿润之风」「干渴之风」「恩惠之风」数量的场上的卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外卡片"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己基本分回复的场合才能发动（伤害步骤也能发动）。自己场上的全部植物族怪兽的攻击力直到回合结束时上升那个数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"攻击力上升"
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RECOVER)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.adcon)
	e3:SetOperation(s.adop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：自己基本分比对方多。
function s.indcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己当前基本分是否大于对方当前基本分。
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
-- ①效果的适用对象：自身以及自己场上的植物族怪兽。
function s.indtg(e,c)
	return e:GetHandler()==c or c:IsRace(RACE_PLANT)
end
-- ②效果的发动代价：支付2000基本分。
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付2000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 扣除玩家2000基本分。
	Duel.PayLPCost(tp,2000)
end
-- 过滤自己场上表侧表示的「湿润之风」、「干渴之风」、「恩惠之风」。
function s.rmfilter(c)
	return c:IsCode(15177750,92266279,28265983) and c:IsFaceup()
end
-- ②效果的发动准备：计算符合条件的风的数量，并确认场上是否有足够数量的可除外卡片，最后设置除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上表侧表示的「湿润之风」「干渴之风」「恩惠之风」的总数量。
	local ct=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_ONFIELD,0,nil):GetCount()
	-- 检查场上是否存在至少与上述风的数量相同的可除外卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,nil) end
	-- 设置连锁处理中的操作信息：从场上除外指定数量的卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,0,LOCATION_ONFIELD)
end
-- ②效果的效果处理：重新计算风的数量，并让玩家选择对应数量的场上的卡除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，重新获取自己场上表侧表示的「湿润之风」「干渴之风」「恩惠之风」的数量。
	local ct=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_ONFIELD,0,nil):GetCount()
	-- 获取场上所有可以被除外的卡片。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>=ct then
		-- 提示玩家选择要除外的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(tp,ct,ct,nil)
		-- 选中卡片时，在场上显示被选中的视觉特效。
		Duel.HintSelection(sg)
		-- 将选中的卡片以表侧表示因效果除外。
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
-- ③效果的发动条件：自己基本分回复，且此卡在场上表侧表示存在。
function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and e:GetHandler():IsFaceup()
end
-- 过滤自己场上表侧表示的植物族怪兽。
function s.adfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsFaceup()
end
-- ③效果的效果处理：获取自己场上所有的植物族怪兽，并使它们的攻击力直到回合结束时上升回复的数值。
function s.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上当前所有表侧表示的植物族怪兽。
	local g=Duel.GetMatchingGroup(s.adfilter,tp,LOCATION_MZONE,0,nil)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
	local tc=g:GetFirst()
		while tc do
			-- 自己场上的全部植物族怪兽的攻击力直到回合结束时上升那个数值。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(ev)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end

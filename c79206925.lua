--墓守の異能者
-- 效果：
-- 「守墓」怪兽×2
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力·守备力上升作为这张卡的融合素材的怪兽的原本等级合计×100。
-- ②：只要场上有「王家长眠之谷」存在，这张卡以及自己的场地区域的卡不会被效果破坏。
-- ③：自己主要阶段才能发动。这个回合的结束阶段，从卡组把1只「守墓」怪兽或者1张「王家长眠之谷」卡加入手卡。
function c79206925.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要「守墓」怪兽2只作为素材。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x2e),2,true)
	-- ①：这张卡的攻击力·守备力上升作为这张卡的融合素材的怪兽的原本等级合计×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c79206925.valcheck)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力·守备力上升作为这张卡的融合素材的怪兽的原本等级合计×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c79206925.atkcon)
	e2:SetOperation(c79206925.atkop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：只要场上有「王家长眠之谷」存在，这张卡以及自己的场地区域的卡不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE+LOCATION_FZONE,0)
	e3:SetCondition(c79206925.indcon)
	e3:SetTarget(c79206925.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：自己主要阶段才能发动。这个回合的结束阶段，从卡组把1只「守墓」怪兽或者1张「王家长眠之谷」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(79206925,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,79206925)
	e4:SetOperation(c79206925.regop)
	c:RegisterEffect(e4)
end
-- 融合素材检查函数，获取并记录作为融合素材的怪兽的原本等级合计。
function c79206925.valcheck(e,c)
	local lv=c:GetMaterial():GetSum(Card.GetOriginalLevel)
	e:SetLabel(lv)
end
-- 攻击力·守备力上升效果的发动条件：这张卡融合召唤成功。
function c79206925.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 攻击力·守备力上升效果的执行：使这张卡的攻击力·守备力上升融合素材原本等级合计×100。
function c79206925.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local val=e:GetLabelObject():GetLabel()*100
	-- ①：这张卡的攻击力·守备力上升作为这张卡的融合素材的怪兽的原本等级合计×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(val)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
-- 破坏抗性效果的适用条件：场上有「王家长眠之谷」存在。
function c79206925.indcon(e)
	-- 检查场上是否存在卡号为47355498的「王家长眠之谷」。
	return Duel.IsEnvironment(47355498)
end
-- 破坏抗性效果的适用对象：自身以及自己的场地区域的卡。
function c79206925.indtg(e,c)
	return c==e:GetHandler() or c:IsLocation(LOCATION_FZONE)
end
-- 主要阶段效果的发动处理：注册一个在回合结束阶段执行的延迟效果。
function c79206925.regop(e,tp,eg,ep,ev,re,r,rp)
	-- ③：自己主要阶段才能发动。这个回合的结束阶段，从卡组把1只「守墓」怪兽或者1张「王家长眠之谷」卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c79206925.thcon)
	e1:SetOperation(c79206925.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将结束阶段的检索效果注册给发动玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 检索卡片的过滤条件：卡组中的「守墓」怪兽或「王家长眠之谷」卡片。
function c79206925.thfilter(c)
	return (c:IsSetCard(0x2e) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0x91) and c:IsAbleToHand()
end
-- 结束阶段检索效果的执行条件：卡组中存在满足条件的卡。
function c79206925.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的卡组中是否存在至少1张满足检索条件的卡。
	return Duel.IsExistingMatchingCard(c79206925.thfilter,tp,LOCATION_DECK,0,1,nil)
end
-- 结束阶段检索效果的执行：从卡组选择1张满足条件的卡加入手卡并给对方确认。
function c79206925.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动效果的卡片为「守墓的异能者」。
	Duel.Hint(HINT_CARD,0,79206925)
	-- 设置选择卡片时的提示信息为“加入手牌”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足检索条件的卡。
	local g=Duel.SelectMatchingCard(tp,c79206925.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end

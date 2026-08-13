--R－ACEハイドラント
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己场上有「救援ACE队 消防栓」以外的「救援ACE队」怪兽存在，对方怪兽不能选择这张卡作为攻击对象，对方不能以此作为效果的对象。
-- ②：只要这张卡在怪兽区域存在，自己的「救援ACE队」卡的效果盖放的1张速攻魔法·陷阱卡在盖放的回合也能发动。
-- ③：自己主要阶段才能发动。从卡组把「救援ACE队 消防栓」以外的1只「救援ACE队」怪兽加入手卡。
local s,id,o=GetID()
-- initial_effect：注册①的不能成为攻击/效果对象效果、②的救援ACE队效果盖放的速攻/陷阱可在盖放回合发动效果、③的检索效果，并注册全局监视器记录救援ACE队效果盖放的卡。
function s.initial_effect(c)
	-- 对应①效果前半句：‘对方怪兽不能选择这张卡作为攻击对象’。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(s.atkcon)
	-- e1:SetValue(aux.imval1)：设置①的攻击对象保护判定，对方怪兽不免疫此效果时不能选择这张卡攻击。
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- e2:SetValue(aux.tgoval)：设置①的效果对象保护判定，对方发动的效果不能以这张卡为对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 对应②效果（陷阱部分）：‘自己的「救援ACE队」卡的效果盖放的1张速攻魔法·陷阱卡在盖放的回合也能发动’。此处为陷阱卡的适用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"适用「救援ACE队 消防栓」的效果来发动"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.qfilter)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
	c:RegisterEffect(e4)
	-- 对应③效果：‘自己主要阶段才能发动。从卡组把「救援ACE队 消防栓」以外的1只「救援ACE队」怪兽加入手卡。’
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+o)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
	if not s.global_check then
		s.global_check=true
		-- 对应②效果中‘自己的「救援ACE队」卡的效果盖放的’限定：注册全局监视器，在救援ACE队效果盖放卡时给该卡打标记。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(s.checkop)
		-- Duel.RegisterEffect(ge1,0)：将全局监视效果注册到场上，捕捉所有盖放魔法·陷阱卡的事件。
		Duel.RegisterEffect(ge1,0)
	end
end
-- checkop：当卡被盖放时，若发动者效果来自救援ACE队卡，则给盖放的卡注册flag标记，供②效果识别。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re or not re:GetHandler():IsSetCard(0x18b) then return end
	local tc=eg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- atkfilter：①效果的过滤条件：表侧表示的救援ACE队怪兽，且不是这张卡自身。
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18b) and not c:IsCode(id)
end
-- atkcon：①效果的适用条件：检查自己场上是否存在至少1只满足atkfilter的救援ACE队怪兽。
function s.atkcon(e)
	-- return Duel.IsExistingMatchingCard(...)：判断自己怪兽区是否存在符合条件的救援ACE队怪兽，只有存在时①效果才适用。
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- qfilter：②效果的筛选函数，仅让带有flag标记（即被救援ACE队效果盖放）的速攻魔法·陷阱卡获得“盖放回合可发动”的权限。
function s.qfilter(e,c)
	return c:GetFlagEffect(id)>0
end
-- filter：③检索的过滤条件：救援ACE队怪兽、可以加入手牌、且不是消防栓自身。
function s.filter(c)
	return c:IsSetCard(0x18b) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand() and not c:IsCode(id)
end
-- thtg：③效果的发动条件和操作信息设定：检查卡组有检索目标，并设置回手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- if chk==0 then return Duel.IsExistingMatchingCard(...)：合法发动检测，确认卡组中存在符合filter的救援ACE队怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)：设置当前连锁的操作信息为从卡组将1张卡加入手牌，供其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- thop：③效果处理：选择1张符合条件的救援ACE队怪兽加入手牌，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)：提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- Duel.SelectMatchingCard：让玩家从卡组选择1张符合filter的救援ACE队怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- Duel.SendtoHand(g,nil,REASON_EFFECT)：将选中的卡加入持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- Duel.ConfirmCards(1-tp,g)：将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end

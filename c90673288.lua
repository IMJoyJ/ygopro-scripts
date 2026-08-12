--閃刀姫－シズク
-- 效果：
-- 水属性以外的「闪刀姬」怪兽1只
-- 自己对「闪刀姬-雫空」1回合只能有1次特殊召唤。
-- ①：对方场上的怪兽的攻击力·守备力下降自己墓地的魔法卡数量×100。
-- ②：这张卡特殊召唤的回合的结束阶段才能发动。同名卡不在自己墓地存在的1张「闪刀」魔法卡从卡组加入手卡。
function c90673288.initial_effect(c)
	c:SetSPSummonOnce(90673288)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，需要1只满足过滤条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,c90673288.matfilter,1,1)
	-- ①：对方场上的怪兽的攻击力·守备力下降自己墓地的魔法卡数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c90673288.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- 这张卡特殊召唤的回合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(c90673288.regop)
	c:RegisterEffect(e3)
	-- ②：这张卡特殊召唤的回合的结束阶段才能发动。同名卡不在自己墓地存在的1张「闪刀」魔法卡从卡组加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(90673288,0))
	e4:SetCategory(CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c90673288.thcon)
	e4:SetTarget(c90673288.thtg)
	e4:SetOperation(c90673288.thop)
	c:RegisterEffect(e4)
end
-- 过滤连接素材：水属性以外的「闪刀姬」怪兽
function c90673288.matfilter(c)
	return c:IsLinkSetCard(0x1115) and c:IsLinkAttribute(ATTRIBUTE_ALL&~ATTRIBUTE_WATER)
end
-- 计算攻击力·守备力下降数值的函数
function c90673288.atkval(e)
	-- 计算并返回自己墓地的魔法卡数量乘以-100的值
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_SPELL)*-100
end
-- 特殊召唤成功时，为自身注册一个在回合结束时重置的Flag，用于标记“特殊召唤的回合”
function c90673288.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(90673288,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查自身是否存在特殊召唤回合的Flag，作为效果发动的条件
function c90673288.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(90673288)~=0
end
-- 过滤卡组中可加入手牌且同名卡不在自己墓地存在的「闪刀」魔法卡
function c90673288.thfilter(c,tp)
	return c:IsSetCard(0x115) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
		-- 过滤条件：自己墓地不存在与该卡同名的卡
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- 效果发动的目标选择与检测，设置检索的操作信息
function c90673288.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检测卡组中是否存在可检索的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c90673288.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置将卡组的1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张满足条件的「闪刀」魔法卡加入手牌并给对方确认
function c90673288.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息：选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「闪刀」魔法卡
	local g=Duel.SelectMatchingCard(tp,c90673288.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end

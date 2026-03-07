--R－ACEハイドラント
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己场上有「救援ACE队 消防栓」以外的「救援ACE队」怪兽存在，对方怪兽不能选择这张卡作为攻击对象，对方不能以此作为效果的对象。
-- ②：只要这张卡在怪兽区域存在，自己的「救援ACE队」卡的效果盖放的1张速攻魔法·陷阱卡在盖放的回合也能发动。
-- ③：自己主要阶段才能发动。从卡组把「救援ACE队 消防栓」以外的1只「救援ACE队」怪兽加入手卡。
local s,id,o=GetID()
-- 注册卡片的两个永续效果，分别使该卡不能成为攻击对象和效果对象
function s.initial_effect(c)
	-- 只要自己场上有「救援ACE队 消防栓」以外的「救援ACE队」怪兽存在，对方怪兽不能选择这张卡作为攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(s.atkcon)
	-- 设置效果值为过滤函数aux.imval1，用于判断是否能成为攻击对象
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置效果值为过滤函数aux.tgoval，用于判断是否能成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 只要这张卡在怪兽区域存在，自己的「救援ACE队」卡的效果盖放的1张速攻魔法·陷阱卡在盖放的回合也能发动
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
	-- 自己主要阶段才能发动。从卡组把「救援ACE队 消防栓」以外的1只「救援ACE队」怪兽加入手卡
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
		-- 注册一个全局连续效果，用于记录盖放的「救援ACE队」魔法陷阱卡
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(s.checkop)
		-- 将全局连续效果ge1注册给玩家0（双方）
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有卡片盖放时，为盖放的「救援ACE队」卡注册标记效果，用于后续判断是否能发动
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re or not re:GetHandler():IsSetCard(0x18b) then return end
	local tc=eg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- 过滤函数，用于筛选场上正面表示的「救援ACE队」怪兽（不包括自身）
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18b) and not c:IsCode(id)
end
-- 条件函数，判断自己场上有「救援ACE队」怪兽（不包括自身）
function s.atkcon(e)
	-- 检查自己场上是否存在满足atkfilter条件的怪兽
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，判断目标卡是否具有标记效果id
function s.qfilter(e,c)
	return c:GetFlagEffect(id)>0
end
-- 过滤函数，用于筛选可以加入手牌的「救援ACE队」怪兽
function s.filter(c)
	return c:IsSetCard(0x18b) and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand() and not c:IsCode(id)
end
-- 设置连锁处理信息，确定发动效果时会将一张卡从卡组加入手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即卡组中是否存在满足filter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，指定效果处理时将要处理的卡为1张手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并把符合条件的卡加入手牌，并向对方确认该卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足filter条件的1张卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

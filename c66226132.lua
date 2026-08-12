--トラックブラック
-- 效果：
-- 效果怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：以这张卡所连接区1只自己怪兽为对象才能发动。这个回合，每次那只怪兽战斗破坏对方怪兽，自己从卡组抽1张。
function c66226132.initial_effect(c)
	-- 设置连接召唤手续：效果怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2)
	c:EnableReviveLimit()
	-- ①：以这张卡所连接区1只自己怪兽为对象才能发动。这个回合，每次那只怪兽战斗破坏对方怪兽，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66226132,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,66226132)
	e1:SetCondition(c66226132.condition)
	e1:SetTarget(c66226132.target)
	e1:SetOperation(c66226132.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：当前回合玩家可以进入战斗阶段
function c66226132.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤条件：选择的怪兽必须存在于这张卡的连接区内
function c66226132.tgfilter(c,lg)
	return lg:IsContains(c)
end
-- 效果发动时的对象选择与合法性检查
function c66226132.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c66226132.tgfilter(chkc,lg) end
	-- 检查自己场上是否存在可以作为对象的、处于连接区内的怪兽
	if chk==0 then return Duel.IsExistingTarget(c66226132.tgfilter,tp,LOCATION_MZONE,0,1,nil,lg) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上连接区内的1只怪兽作为效果的对象
	Duel.SelectTarget(tp,c66226132.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,lg)
end
-- 效果处理：为目标怪兽添加状态，并注册一个全局的战斗破坏抽卡效果
function c66226132.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	tc:RegisterFlagEffect(66226132,RESET_EVENT+0x1220000+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(66226132,1))  --"「引用通告黑鸟」效果适用中"
	-- 这个回合，每次那只怪兽战斗破坏对方怪兽，自己从卡组抽1张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetLabelObject(tc)
	e1:SetCondition(c66226132.drcon)
	e1:SetOperation(c66226132.drop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该延迟触发的抽卡效果
	Duel.RegisterEffect(e1,tp)
end
-- 抽卡效果触发条件：被战斗破坏的怪兽包含目标怪兽，且该怪兽带有此卡效果适用的标记
function c66226132.drcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return eg:IsContains(tc) and tc:GetFlagEffect(66226132)~=0
end
-- 抽卡效果处理：展示此卡并让玩家从卡组抽1张卡
function c66226132.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动此卡的效果（展示卡片动画）
	Duel.Hint(HINT_CARD,0,66226132)
	-- 玩家因效果从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
end

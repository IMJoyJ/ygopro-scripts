--サイレント・ソードマン・ゼロ
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己·对方的准备阶段发动。这张卡的等级上升1星。
-- ②：这张卡的等级比原本等级高的场合，这张卡的攻击力上升那个相差数值×500。
-- ③：以自己场上的「光之黄金柜」或者有那个卡名记述的怪兽为对象的效果由对方发动时才能发动。那个发动无效，这张卡的等级上升1星。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：①准备阶段等级上升、②等级差攻击力上升、③对方发动效果时可无效并等级上升
function s.initial_effect(c)
	-- 记录该卡效果文本上记载着「光之黄金柜」（卡号79791878）
	aux.AddCodeList(c,79791878)
	-- ①：自己·对方的准备阶段发动。这张卡的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"等级上升"
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	-- ②：这张卡的等级比原本等级高的场合，这张卡的攻击力上升那个相差数值×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	-- ③：以自己场上的「光之黄金柜」或者有那个卡名记述的怪兽为对象的效果由对方发动时才能发动。那个发动无效，这张卡的等级上升1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
-- 准备阶段等级上升效果的处理函数，使自身等级上升1星
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 使自身等级上升1星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 计算攻击力上升值的函数，根据等级差计算攻击力增加量
function s.value(e,c)
	return math.max(0,c:GetLevel()-c:GetOriginalLevel())*500
end
-- 筛选目标卡片的过滤函数，判断是否为场上的自己正面表示的「光之黄金柜」或记载有其卡名的怪兽
function s.tfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp) and c:IsFaceup()
		-- 判断目标卡片是否为记载有「光之黄金柜」卡名的怪兽
		and (c:IsCode(79791878) or c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,79791878))
end
-- 无效效果发动的条件判断函数，判断是否为对方发动且目标包含符合条件的卡片
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的目标卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断目标卡片组中是否存在符合条件的卡片且该连锁可被无效
	return tg and tg:IsExists(s.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 设置无效效果发动时的操作信息，标记将要使发动无效
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，标记将要使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 无效效果发动并使自身等级上升的处理函数
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否成功使连锁无效且自身状态有效
	if Duel.NegateActivation(ev) and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 使自身等级上升1星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end

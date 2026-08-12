--R.B.ブルート・ブルース
-- 效果：
-- 机械族怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡所连接区有「反叛曲机器人」怪兽存在，这张卡得到以下效果。
-- ●这张卡的攻击力上升这张卡所连接区的「反叛曲机器人」怪兽的原本攻击力数值。
-- ●这张卡在同1次的战斗阶段中可以作2次攻击。
-- ●这张卡不会被战斗·效果破坏。
-- ②：自己主要阶段才能发动。从卡组把1张「反叛曲机器人」卡加入手卡。
local s,id,o=GetID()
-- 初始化这张卡：添加苏生限制与连接召唤手续，注册攻击力上升、追加攻击次数、不被战斗·效果破坏这3个永续效果，以及1回合1次的卡组检索起动效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：用2只以上机械族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2)
	-- 这张卡的攻击力上升这张卡所连接区的「反叛曲机器人」怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- 这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(s.eacon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这张卡不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetCondition(s.eacon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
	-- ②：自己主要阶段才能发动。从卡组把1张「反叛曲机器人」卡加入手卡。（这个卡名的②的效果1回合只能使用1次）
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))  --"检索"
	e5:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
-- 过滤函数：判断是否为表侧表示的「反叛曲机器人」（0x1cf）怪兽
function s.valfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf)
end
-- 计算攻击力上升值：取这张卡所连接区的「反叛曲机器人」怪兽的原本攻击力之和
function s.atkval(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(s.valfilter,nil)
	return g:GetSum(Card.GetBaseAttack)
end
-- 永续效果的适用条件：这张卡所连接区存在「反叛曲机器人」怪兽
function s.eacon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroup():IsExists(s.valfilter,1,nil)
end
-- 检索过滤函数：判断是否为可以加入手卡的「反叛曲机器人」卡
function s.thfilter(c)
	return c:IsSetCard(0x1cf) and c:IsAbleToHand()
end
-- 检索效果的发动条件检测：确认卡组存在可加入手卡的「反叛曲机器人」卡，并设置将要从卡组加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检测：自己卡组存在至少1张可加入手卡的「反叛曲机器人」卡时才能发动
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣告将从自己卡组把1张卡加入手卡（目标不确定，targets为nil）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：提示后让玩家从卡组选1张「反叛曲机器人」卡加入手卡，并向对方展示确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己从卡组选择1张可加入手卡的「反叛曲机器人」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 以效果处理把选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡向对方玩家展示确认
		Duel.ConfirmCards(1-tp,g)
	end
end

--R.B.ブルート・ブルース
-- 效果：
-- 机械族怪兽2只以上
-- 这张卡所连接区有「奏悦机组」怪兽存在的场合，这张卡得到以下效果。
-- ●这张卡的攻击力上升这张卡所连接区的「奏悦机组」怪兽的原本攻击力合计数值。
-- ●这张卡在同1次的战斗阶段中可以作2次攻击。
-- ●这张卡不会被战斗·效果破坏。
-- 自己主要阶段：可以从卡组把1张「奏悦机组」卡加入手卡。「奏悦机组 狂放蓝调号」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化效果函数，设置卡片苏生限制并添加连接召唤手续
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用至少2只机械族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2)
	-- 这张卡的攻击力上升这张卡所连接区的「奏悦机组」怪兽的原本攻击力合计数值
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	-- 这张卡在同1次的战斗阶段中可以作2次攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(s.eacon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这张卡不会被战斗破坏
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
	-- 自己主要阶段时可以从卡组把1张「奏悦机组」卡加入手卡
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
-- 过滤函数，用于判断怪兽是否为表侧表示且属于「奏悦机组」系列
function s.valfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf)
end
-- 计算攻击力增加值，获取连接区中满足条件的怪兽数量并求和其原本攻击力
function s.atkval(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(s.valfilter,nil)
	return g:GetSum(Card.GetBaseAttack)
end
-- 判断条件函数，检查连接区是否存在满足条件的怪兽
function s.eacon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroup():IsExists(s.valfilter,1,nil)
end
-- 检索过滤函数，用于筛选可以加入手牌的「奏悦机组」卡
function s.thfilter(c)
	return c:IsSetCard(0x1cf) and c:IsAbleToHand()
end
-- 设置检索效果的发动条件，检查是否满足至少有1张「奏悦机组」卡在卡组中
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索效果的发动条件，即卡组中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息，指定将要处理的卡为1张加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，选择并把符合条件的卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

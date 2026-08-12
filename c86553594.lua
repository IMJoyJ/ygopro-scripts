--ティスティナの変晶
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：可以从以下效果选择1个发动。
-- ●自己场上有「提斯蒂娜」怪兽存在的场合才能发动。对方墓地1张卡里侧除外。
-- ●从额外卡组特殊召唤的「提斯蒂娜」怪兽在自己场上存在的场合才能发动。对方墓地的卡全部里侧除外。
-- ②：把墓地的这张卡除外，以自己墓地1只「提斯蒂娜」怪兽为对象才能发动。那只怪兽回到手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。●自己场上有「提斯蒂娜」怪兽存在的场合才能发动。对方墓地1张卡里侧除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从对方墓地把1张卡里侧表示除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ●从额外卡组特殊召唤的「提斯蒂娜」怪兽在自己场上存在的场合才能发动。对方墓地的卡全部里侧除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"对方墓地的卡全部里侧表示除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.recon)
	e2:SetTarget(s.retg)
	e2:SetOperation(s.reop)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己墓地1只「提斯蒂娜」怪兽为对象才能发动。那只怪兽回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"墓地回收"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	-- 设置效果②的发动成本为：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「提斯蒂娜」怪兽
function s.filter(c)
	return c:IsSetCard(0x1a4) and c:IsFaceup()
end
-- 过滤条件：对方墓地可以里侧表示除外的卡
function s.filter1(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 效果①分支1的发动条件：自己场上有「提斯蒂娜」怪兽存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「提斯蒂娜」怪兽
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①分支1的发动准备与效果分类注册
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方墓地是否存在至少1张可以里侧表示除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,0,LOCATION_GRAVE,1,nil,tp) end
	-- 设置当前连锁的操作信息为：将对方墓地的1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
-- 效果①分支1的处理：将对方墓地1张卡里侧表示除外
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家从对方墓地选择1张可以里侧表示除外的卡
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,0,LOCATION_GRAVE,1,1,nil,tp)
	if #g>0 then
	-- 将选中的卡里侧表示除外
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上表侧表示的、从额外卡组特殊召唤的「提斯蒂娜」怪兽
function s.refilter(c)
	return c:IsSetCard(0x1a4) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsFaceup()
end
-- 效果①分支2的发动条件：从额外卡组特殊召唤的「提斯蒂娜」怪兽在自己场上存在
function s.recon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的、从额外卡组特殊召唤的「提斯蒂娜」怪兽
	return Duel.IsExistingMatchingCard(s.refilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①分支2的发动准备与效果分类注册
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方墓地是否存在至少1张可以里侧表示除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,0,LOCATION_GRAVE,1,nil,tp) end
	-- 获取对方墓地所有可以里侧表示除外的卡
	local g=Duel.GetMatchingGroup(s.filter1,tp,0,LOCATION_GRAVE,nil,tp)
	-- 设置当前连锁的操作信息为：将对方墓地的所有可除外卡里侧表示除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果①分支2的处理：将对方墓地的卡全部里侧表示除外
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方墓地所有可以里侧表示除外的卡
	local g=Duel.GetMatchingGroup(s.filter1,tp,0,LOCATION_GRAVE,nil,tp)
	-- 将获取到的卡全部里侧表示除外
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end
-- 过滤条件：自己墓地可以加入手牌的「提斯蒂娜」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x1a4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的发动准备、选择对象与效果分类注册
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.thfilter(chkc) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) end
	-- 检查自己墓地是否存在可以加入手牌的「提斯蒂娜」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「提斯蒂娜」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理：将作为对象的怪兽回到手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

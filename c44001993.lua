--黒き混沌の魔術師ブラック・カオス
-- 效果：
-- 「光与暗的仪式」降临
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从自己墓地把1张魔法卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，自己场上的魔法·陷阱卡不会被对方的效果破坏，不能用对方的效果除外，这张卡不受除以这张卡为对象的效果以外的对方发动的效果影响。
-- ③：以对方场上1张卡为对象才能发动。那张卡里侧除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 将「光与暗的仪式」（卡号33599853）加入该卡的关联卡片代码列表中
	aux.AddCodeList(c,33599853)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从自己墓地把1张魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收魔法"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的魔法·陷阱卡不会被对方的效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设置效果影响的对象为魔法卡或陷阱卡
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPELL+TYPE_TRAP))
	-- 设置破坏的来源为对方发动的卡的效果
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- 不能用对方的效果除外
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(s.rmlimit)
	c:RegisterEffect(e3)
	-- 这张卡不受除以这张卡为对象的效果以外的对方发动的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	-- ③：以对方场上1张卡为对象才能发动。那张卡里侧除外。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"里侧除外"
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+o)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
end
-- 判断除外效果的来源是否为对方玩家
function s.rmval(e,re,r,rp)
	return rp~=e:GetHandlerPlayer()
end
-- 效果①（特殊召唤成功时回收墓地魔法卡）的发动判定与效果目标设置函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己墓地是否存在至少1张魔法卡
		return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL)
	end
	-- 设置效果处理的连锁操作信息，为将自己墓地的一张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①（特殊召唤成功时回收墓地魔法卡）的效果处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家在自己墓地选择1张不受「王家长眠之谷」影响的魔法卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsType),tp,LOCATION_GRAVE,0,1,1,nil,TYPE_SPELL)
	if #g>0 then
		-- 因效果将选中的卡片加入持有者的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 限制效果（自己场上的魔法·陷阱卡不能用对方的效果除外）的过滤和判定函数
function s.rmlimit(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp) and c:IsOnField() and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and r&REASON_EFFECT~=0 and r&REASON_REDIRECT==0 and rp==1-tp
end
-- 抗性效果（不受除以这张卡为对象的效果以外的对方发动的效果影响）的过滤和判定函数
function s.efilter(e,te)
	if te:GetOwnerPlayer()==e:GetHandlerPlayer() or not te:IsActivated() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	-- 获取当前处理的连锁中的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(e:GetHandler())
end
-- 效果③（里侧除外对方场上的卡）的发动判定与效果目标设置函数
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove(tp,POS_FACEDOWN) end
	-- 在发动判定的第一阶段，检查对方场上是否存在至少1张可以里侧除外的卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil,tp,POS_FACEDOWN) end
	-- 向发动效果的玩家提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择对方场上的1张卡片作为除外对象并将其注册为连锁对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil,tp,POS_FACEDOWN)
	-- 设置效果处理的连锁操作信息，为将选中的卡片除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果③（里侧除外对方场上的卡）的效果处理函数
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果指向的第一个对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 因效果将目标卡片里侧除外
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end

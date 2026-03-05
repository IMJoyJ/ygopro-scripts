--心の架け橋
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「宝玉兽」怪兽召唤。
-- ②：自己主要阶段才能发动。选自己的手卡·场上1张「宝玉兽」卡破坏，从卡组把1张「宝玉」魔法·陷阱卡加入手卡。
-- ③：自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，以对方场上1张卡为对象才能发动（伤害步骤也能发动）。那张卡和这张卡回到持有者手卡。
local s,id,o=GetID()
-- 注册场地魔法卡的发动效果和三个效果的处理函数
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「宝玉兽」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置效果目标为「宝玉兽」卡
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1034))
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。选自己的手卡·场上1张「宝玉兽」卡破坏，从卡组把1张「宝玉」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ③：自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，以对方场上1张卡为对象才能发动（伤害步骤也能发动）。那张卡和这张卡回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_MOVE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 检索满足条件的「宝玉兽」卡（场上或手牌）
function s.desfilter(c)
	return c:IsSetCard(0x1034) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
-- 检索满足条件的「宝玉」魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x34) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 判断是否满足②效果的发动条件
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足②效果的发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
		-- 判断是否满足②效果的发动条件
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 获取满足条件的「宝玉兽」卡组
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	-- 设置连锁操作信息：破坏1张「宝玉兽」卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁操作信息：从卡组检索1张「宝玉」魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行②效果的处理流程
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的「宝玉兽」卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择要破坏的「宝玉兽」卡
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 执行破坏操作
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 提示玩家选择要检索的「宝玉」魔法·陷阱卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- 选择要检索的「宝玉」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的「宝玉」魔法·陷阱卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 判断是否满足③效果的发动条件
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5
end
-- 判断是否满足③效果的发动条件
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 执行③效果的处理流程
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	local c=e:GetHandler()
	-- 判断是否满足③效果的发动条件
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的对方场上卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	-- 选择要返回手牌的对方场上卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	g:AddCard(c)
	-- 设置连锁操作信息：将2张卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 执行③效果的处理流程
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将目标卡和自身返回手牌
		Duel.SendtoHand(Group.FromCards(c,tc),nil,REASON_EFFECT)
	end
end

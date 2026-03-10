--魔界劇団－ワイルド・ホープ
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，以另一边的自己的灵摆区域1张「魔界剧团」卡为对象才能发动。那张卡的灵摆刻度直到回合结束时变成9。这个效果的发动后，直到回合结束时自己不是「魔界剧团」怪兽不能特殊召唤。
-- 【怪兽效果】
-- 这个卡名的②的怪兽效果1回合只能使用1次。
-- ①：1回合1次，自己主要阶段才能发动。这张卡的攻击力直到回合结束时上升自己场上的「魔界剧团」怪兽种类×100。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把「魔界剧团-狂放新秀」以外的1张「魔界剧团」卡加入手卡。
function c51391183.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以另一边的自己的灵摆区域1张「魔界剧团」卡为对象才能发动。那张卡的灵摆刻度直到回合结束时变成9。这个效果的发动后，直到回合结束时自己不是「魔界剧团」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51391183,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c51391183.target)
	e1:SetOperation(c51391183.operation)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。这张卡的攻击力直到回合结束时上升自己场上的「魔界剧团」怪兽种类×100。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c51391183.atktg)
	e2:SetOperation(c51391183.atkop)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把「魔界剧团-狂放新秀」以外的1张「魔界剧团」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,51391183)
	e3:SetCondition(c51391183.thcon)
	e3:SetTarget(c51391183.thtg)
	e3:SetOperation(c51391183.thop)
	c:RegisterEffect(e3)
end
-- 设置灵摆效果的目标为对方场上的任意一张「魔界剧团」灵摆卡
function c51391183.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在至少一张「魔界剧团」灵摆卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x10ec) end
	-- 获取对方场上满足条件的第一张「魔界剧团」灵摆卡
	local tc=Duel.GetFirstMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,e:GetHandler(),0x10ec)
	-- 将该卡设置为效果对象
	Duel.SetTargetCard(tc)
end
-- 执行灵摆刻度变更和特殊召唤限制效果
function c51391183.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡的左刻度设置为9
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(9)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		tc:RegisterEffect(e2)
	end
	-- 创建并注册一个全场范围的效果，禁止非「魔界剧团」怪兽特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c51391183.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将特殊召唤限制效果注册到游戏环境
	Duel.RegisterEffect(e3,tp)
end
-- 定义特殊召唤限制函数，判断目标是否为「魔界剧团」卡
function c51391183.splimit(e,c)
	return not c:IsSetCard(0x10ec)
end
-- 定义攻击力提升效果的过滤条件，筛选场上正面表示的「魔界剧团」怪兽
function c51391183.atkfilter(c)
	return c:IsSetCard(0x10ec) and c:IsFaceup()
end
-- 设置攻击力提升效果的目标为场上的「魔界剧团」怪兽
function c51391183.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少一张正面表示的「魔界剧团」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c51391183.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 执行攻击力提升效果
function c51391183.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有正面表示的「魔界剧团」怪兽
	local g=Duel.GetMatchingGroup(c51391183.atkfilter,tp,LOCATION_MZONE,0,nil)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atkval=g:GetClassCount(Card.GetCode)*100
		-- 将自身攻击力提升为场上「魔界剧团」怪兽种类数乘以100
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 判断破坏原因是否为战斗或效果破坏
function c51391183.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 定义检索卡组的过滤条件，筛选非本卡的「魔界剧团」卡
function c51391183.filter(c)
	return c:IsSetCard(0x10ec) and c:IsAbleToHand() and not c:IsCode(51391183)
end
-- 设置检索效果的目标为卡组中满足条件的卡
function c51391183.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少一张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c51391183.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组检索一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索并加入手牌的效果
function c51391183.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的一张卡
	local g=Duel.SelectMatchingCard(tp,c51391183.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

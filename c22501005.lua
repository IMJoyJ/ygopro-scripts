--霊獣の継聖
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方场上的怪兽的攻击力下降自己场上的「灵兽」怪兽的种族种类×200。
-- ②：把手卡1只「灵兽」怪兽给对方观看才能发动。和那只怪兽种族不同的1只「灵兽」怪兽从卡组加入手卡。那之后，选自己1张手卡丢弃。
-- ③：自己场上有怪兽2只以上同时特殊召唤的场合，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
local s,id,o=GetID()
-- 初始化卡片效果，创建场地魔法卡的通用发动效果、攻击力变更效果、起动效果和诱发效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：对方场上的怪兽的攻击力下降自己场上的「灵兽」怪兽的种族种类×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	-- ②：把手卡1只「灵兽」怪兽给对方观看才能发动。和那只怪兽种族不同的1只「灵兽」怪兽从卡组加入手卡。那之后，选自己1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：自己场上有怪兽2只以上同时特殊召唤的场合，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.pcon)
	e3:SetTarget(s.ptg)
	e3:SetOperation(s.pop)
	c:RegisterEffect(e3)
end
-- 筛选场上表侧表示的「灵兽」怪兽
function s.atkfilter(c)
	return c:IsSetCard(0xb5) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 计算「灵兽」怪兽数量并乘以-200作为攻击力变更值
function s.val(e,c)
	local tp=e:GetHandlerPlayer()
	-- 获取场上所有表侧表示的「灵兽」怪兽
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetRace)*(-200)
end
-- 判断卡片是否为指定玩家控制
function s.filter(c,tp)
	return c:IsControler(tp)
end
-- 筛选手卡中未公开的「灵兽」怪兽，且卡组中存在不同种族的「灵兽」怪兽
function s.costfilter(c)
	-- 筛选手卡中未公开的「灵兽」怪兽，且卡组中存在不同种族的「灵兽」怪兽
	return c:IsSetCard(0xb5) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and Duel.IsExistingMatchingCard(aux.NOT(Card.IsRace),c:GetControler(),LOCATION_DECK,0,1,nil,c:GetRace())
end
-- 检查手卡是否存在符合条件的「灵兽」怪兽并选择给对方确认
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在符合条件的「灵兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择符合条件的「灵兽」怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	e:SetLabel(g:GetFirst():GetRace())
end
-- 筛选卡组中种族与已确认怪兽不同的「灵兽」怪兽
function s.thfilter(c,race)
	return c:IsSetCard(0xb5) and c:IsType(TYPE_MONSTER) and not c:IsRace(race) and c:IsAbleToHand()
end
-- 设置检索和丢弃手牌的效果目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local race=e:GetLabel()
	-- 检查卡组中是否存在符合条件的「灵兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,race) end
	-- 设置将卡从卡组加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置丢弃手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 执行检索和丢弃手牌效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local race=e:GetLabel()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择符合条件的「灵兽」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,race)
	-- 判断是否成功将卡加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 丢弃1张手牌
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 判断是否满足特殊召唤2只以上怪兽的条件
function s.pcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,2,nil,tp)
end
-- 判断怪兽是否可以改变表示形式
function s.pfilter(c)
	return c:IsCanChangePosition()
end
-- 设置改变表示形式效果的目标
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.pfilter(chkc) end
	-- 检查场上是否存在可以改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.pfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上可以改变表示形式的怪兽
	local g=Duel.SelectTarget(tp,s.pfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置改变表示形式的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 执行改变表示形式效果
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为表侧守备表示、表侧攻击表示、表侧攻击表示、表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end

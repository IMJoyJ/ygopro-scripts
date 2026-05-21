--海造賊－拠点
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上的「海造贼」怪兽的攻击力上升自己的魔法与陷阱区域的「海造贼」卡数量×500。
-- ②：自己主要阶段，丢弃1张手卡才能发动。从卡组把「海造贼-据点」以外的1张「海造贼」卡加入手卡。
-- ③：这张卡在墓地存在的场合，以自己的魔法与陷阱区域1张「海造贼」卡为对象才能发动。这张卡在自己场上盖放，作为对象的卡回到持有者手卡。
function c93031067.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的「海造贼」怪兽的攻击力上升自己的魔法与陷阱区域的「海造贼」卡数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置攻击力上升效果的对象为自己场上的「海造贼」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x13f))
	e2:SetValue(c93031067.atkval)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段，丢弃1张手卡才能发动。从卡组把「海造贼-据点」以外的1张「海造贼」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93031067,0))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,93031067)
	e3:SetCost(c93031067.thcost)
	e3:SetTarget(c93031067.thtg)
	e3:SetOperation(c93031067.thop)
	c:RegisterEffect(e3)
	-- ③：这张卡在墓地存在的场合，以自己的魔法与陷阱区域1张「海造贼」卡为对象才能发动。这张卡在自己场上盖放，作为对象的卡回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(93031067,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,93031068)
	e4:SetTarget(c93031067.settg)
	e4:SetOperation(c93031067.setop)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己魔陷区表侧表示的「海造贼」卡
function c93031067.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13f) and c:GetSequence()<5
end
-- 计算攻击力上升数值的函数
function c93031067.atkval(e,c)
	-- 返回自己魔陷区表侧表示的「海造贼」卡数量×500的数值
	return Duel.GetMatchingGroupCount(c93031067.atkfilter,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)*500
end
-- 过滤条件：卡组中「海造贼-据点」以外的「海造贼」卡
function c93031067.thfilter(c)
	return c:IsSetCard(0x13f) and not c:IsCode(93031067) and c:IsAbleToHand()
end
-- 检索效果的发动代价（Cost）处理函数
function c93031067.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家发送提示：请选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家选择1张手牌丢弃
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的手牌作为代价丢弃送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 检索效果的发动条件与效果分类（Target）处理函数
function c93031067.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以检索的「海造贼」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c93031067.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的效果处理（Operation）函数
function c93031067.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张符合条件的「海造贼」卡
	local g=Duel.SelectMatchingCard(tp,c93031067.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己魔陷区表侧表示的「海造贼」卡
function c93031067.setfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13f) and c:GetSequence()<5
end
-- 盖放效果的发动条件与对象选择（Target）处理函数
function c93031067.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c93031067.setfilter(chkc) end
	-- 检查自己魔陷区是否存在可作为对象的「海造贼」卡，且墓地的这张卡是否可以盖放
	if chk==0 then return Duel.IsExistingTarget(c93031067.setfilter,tp,LOCATION_SZONE,0,1,nil) and e:GetHandler():IsSSetable() end
	-- 给玩家发送提示：请选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己魔陷区1张表侧表示的「海造贼」卡作为效果对象
	local g=Duel.SelectTarget(tp,c93031067.setfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 设置操作信息：将对象卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：墓地的这张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 盖放效果的效果处理（Operation）函数
function c93031067.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断此卡是否仍受效果影响，若成功在场上盖放，且对象卡仍受效果影响，则继续处理
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)~=0 and tc:IsRelateToEffect(e) then
		-- 将作为对象的卡回到持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

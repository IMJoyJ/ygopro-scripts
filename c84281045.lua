--VV－マスターフェイズ
-- 效果：
-- ①：1回合1次，怪兽区域的卡向其他的怪兽区域移动的场合，可以从以下效果选择1个发动。
-- ●自己场上的全部5星以上的「群豪」怪兽的攻击力直到回合结束时上升1200。
-- ●把魔法与陷阱区域的表侧表示的这张卡送去墓地，以对方的主要怪兽区域1只效果怪兽为对象才能发动。那只对方怪兽在和那只是相同纵列的对方的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置（所要放置区的卡破坏）。
local s,id,o=GetID()
-- 初始化函数，注册卡片的发动效果以及在魔陷区发动的两个诱发即时效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，怪兽区域的卡向其他的怪兽区域移动的场合，可以从以下效果选择1个发动。 ●自己场上的全部5星以上的「群豪」怪兽的攻击力直到回合结束时上升1200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，怪兽区域的卡向其他的怪兽区域移动的场合，可以从以下效果选择1个发动。 ●把魔法与陷阱区域的表侧表示的这张卡送去墓地，以对方的主要怪兽区域1只效果怪兽为对象才能发动。那只对方怪兽在和那只是相同纵列的对方的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置（所要放置区的卡破坏）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"对方怪兽当作魔法卡放置"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_MOVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.condition)
	e3:SetCost(s.mvcost)
	e3:SetTarget(s.mvtg)
	e3:SetOperation(s.mvop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡片在怪兽区域内移动（位置改变或控制权转移）
function s.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=c:GetControler())
end
-- 发动条件：怪兽区域的卡向其他的怪兽区域移动的场合
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
-- 过滤条件：自己场上表侧表示的5星以上的「群豪」怪兽
function s.afilter(c)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsSetCard(0x17d)
end
-- 攻击力上升效果的发动准备与合法性检查
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在符合条件的「群豪」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向对方玩家提示选择发动了攻击力上升的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 攻击力上升效果的实际处理：使自己场上所有符合条件的「群豪」怪兽攻击力上升1200
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有符合条件的「群豪」怪兽
	local g=Duel.GetMatchingGroup(s.afilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历符合条件的怪兽卡片组
	for tc in aux.Next(g) do
		-- 攻击力直到回合结束时上升1200
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果发动的Cost：把魔法与陷阱区域表侧表示的这张卡送去墓地
function s.mvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsStatus(STATUS_EFFECT_ENABLED) and c:IsAbleToGraveAsCost() end
	-- 将作为Cost的这张卡送去墓地
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤条件：对方主要怪兽区域的表侧表示效果怪兽
function s.mfilter(c)
	local seq=c:GetSequence()
	return seq<=4 and c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 放置效果的发动准备，选择对方主要怪兽区域的1只效果怪兽作为对象
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.mfilter(chkc) end
	-- 检查对方主要怪兽区域是否存在符合条件的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(s.mfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示选择发动了将对方怪兽当作魔法卡放置的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要放置到后场的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要放置到后场的怪兽"
	-- 选择对方主要怪兽区域的1只效果怪兽作为对象
	Duel.SelectTarget(tp,s.mfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 过滤条件：获取指定纵列（格子编号相同）的卡片
function s.sfilter(c,seq)
	return c:GetSequence()==seq
end
-- 放置效果的实际处理：将对象怪兽移动到相同纵列的对方魔陷区，破坏该区域原本的卡并使其当作永续魔法卡使用
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e)) then return end
	local zone=1<<tc:GetSequence()
	-- 获取与对象怪兽相同纵列的对方魔法与陷阱区域的卡
	local oc=Duel.GetMatchingGroup(s.sfilter,tp,0,LOCATION_SZONE,nil,tc:GetSequence()):GetFirst()
	if oc then
		-- 依据规则破坏所要放置区域的卡
		Duel.Destroy(oc,REASON_RULE)
	end
	-- 将对象怪兽移动到相同纵列的对方魔法与陷阱区域以表侧表示放置
	if Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true,zone) then
		-- 当作永续魔法卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end

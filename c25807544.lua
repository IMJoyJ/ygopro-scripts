--大聖剣博物館
-- 效果：
-- ①：自己场上的战士族·炎属性怪兽的攻击力上升500。
-- ②：1回合1次，支付1200基本分才能发动。从卡组把「大圣剑博物馆」以外的1张「圣剑」卡加入手卡。
-- ③：这张卡的②的效果适用的回合1次，以自己的魔法与陷阱区域1张「圣骑士」怪兽卡为对象才能发动。那张卡特殊召唤。自己场上没有「焰圣骑士帝-查理」存在的状态把这个效果发动过的场合，直到回合结束时自己不是战士族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的通用发动效果、攻击力提升效果、检索效果和特殊召唤效果
function s.initial_effect(c)
	-- 记录该卡与「焰圣骑士帝-查理」的关联，用于效果判定
	aux.AddCodeList(c,77656797)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上的战士族·炎属性怪兽的攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.atktg)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 1回合1次，支付1200基本分才能发动。从卡组把「大圣剑博物馆」以外的1张「圣剑」卡加入手卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	-- 这张卡的②的效果适用的回合1次，以自己的魔法与陷阱区域1张「圣骑士」怪兽卡为对象才能发动。那张卡特殊召唤。自己场上没有「焰圣骑士帝-查理」存在的状态把这个效果发动过的场合，直到回合结束时自己不是战士族怪兽不能特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetLabel(0)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 判断目标怪兽是否为战士族且炎属性
function s.atktg(e,c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR)
end
-- 支付1200基本分作为发动②效果的费用
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1200基本分
	if chk==0 then return Duel.CheckLPCost(tp,1200) end
	-- 支付1200基本分
	Duel.PayLPCost(tp,1200)
end
-- 过滤出卡组中「圣剑」卡且不是此卡的卡片
function s.thfilter(c)
	return c:IsSetCard(0x207a) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 设置②效果的发动条件和处理信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「圣剑」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行②效果的处理，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「圣剑」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断②效果是否已发动过
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 过滤出自己魔法与陷阱区域中「圣骑士」怪兽卡
function s.spfilter(c,e,tp)
	return c:IsFaceup() and not c:IsLocation(LOCATION_FZONE) and c:IsSetCard(0x107a)
		and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤出场上存在的「焰圣骑士帝-查理」
function s.charlesfilter(c)
	return c:IsFaceup() and c:IsCode(77656797)
end
-- 设置③效果的发动条件和处理信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_SZONE) and s.spfilter(chkc,e,tp) end
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己魔法与陷阱区域是否存在满足条件的「圣骑士」怪兽卡
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	e:SetLabel(0)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「圣骑士」怪兽卡
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 检查场上是否存在「焰圣骑士帝-查理」
	if not Duel.IsExistingMatchingCard(s.charlesfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		e:SetLabel(1)
	end
end
-- 执行③效果的处理，特殊召唤目标卡并设置限制效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 检查是否有足够的召唤位置且目标卡有效
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsRelateToEffect(e) then
		-- 将目标卡特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:GetLabel()==1 then
		-- 创建并注册限制非战士族怪兽特殊召唤的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将限制效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制非战士族怪兽特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end

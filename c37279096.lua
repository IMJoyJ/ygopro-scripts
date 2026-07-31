--無垢なる芸術－「黄昏の変幻」
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动、适用条件和起动效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方场上有以「无垢なる芸術」为属性的连接怪兽存在时，这张卡才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(id)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(s.recon)
	c:RegisterEffect(e2)
	-- ①：这张卡在场上发动时，以自己或者对方的魔法·陷阱区域的1张卡为对象才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上的怪兽是否为「无垢なる芸術」属性且为连接怪兽
function s.confilter(c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK)
end
-- 条件函数，检查对方场上是否存在满足confilter条件的怪兽
function s.recon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1只满足confilter条件的怪兽
	return Duel.IsExistingMatchingCard(s.confilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于检索卡组中符合「黄昏的变幻」或「黄昏的幻影」属性且为怪兽的卡片
function s.thfilter(c)
	return c:IsSetCard(0x1e6,0x1e8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索手牌效果的处理条件，检查是否已使用过此效果且卡组中存在满足条件的卡片
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足检索手牌效果的发动条件：未使用过此效果且卡组中存在满足条件的卡片
	if chk==0 then return c:GetFlagEffect(id)==0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	-- 设置连锁操作信息，指定将要处理的卡为对方卡组中的一张怪兽卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索手牌效果的处理函数，提示选择并执行将符合条件的卡加入手牌的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示其选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的一张卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

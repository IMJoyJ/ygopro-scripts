--無垢なる芸術－「黄昏の変幻」
-- 效果：
-- 这个卡名在规则上也当作「神艺」、「终刻」、「耀圣」卡使用。这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有「狱神」连接怪兽存在，原本卡名包含「无垢大艺术」的自己场上的怪兽发动的效果变成对方回合也能发动的效果。
-- ②：只在这张卡表侧表示存在才有1次，自己主要阶段才能发动。从卡组把1只「米底乌斯」怪兽或「无垢大艺术」怪兽加入手卡。
local s,id,o=GetID()
-- 初始化函数：注册永续魔陷通用的发动许可空效果，以及e2永续效果和e3检索起动效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有「狱神」连接怪兽存在，原本卡名包含「无垢大艺术」的自己场上的怪兽发动的效果变成对方回合也能发动的效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(id)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(s.recon)
	c:RegisterEffect(e2)
	-- ②：只在这张卡表侧表示存在才有1次，自己主要阶段才能发动。从卡组把1只「米底乌斯」怪兽或「无垢大艺术」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：属于「狱神」系列（0x1ce）的连接怪兽
function s.confilter(c)
	return c:IsSetCard(0x1ce) and c:IsType(TYPE_LINK)
end
-- ①效果的适用条件：检查这张卡的控制者场上是否存在「狱神」连接怪兽
function s.recon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在至少1只「狱神」连接怪兽
	return Duel.IsExistingMatchingCard(s.confilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：可以加入手卡的「米底乌斯」（0x1e6）或「无垢大艺术」（0x1e8）怪兽
function s.thfilter(c)
	return c:IsSetCard(0x1e6,0x1e8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的目标函数：确认本回合尚未发动过且卡组中存在可检索的怪兽，随后给这张卡登记「已发动过效果」的标记并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：这张卡在场上表侧表示期间尚未发动过该效果，且卡组中存在至少1只满足条件的怪兽
	if chk==0 then return c:GetFlagEffect(id)==0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"已发动过效果"
	-- 设置操作信息：将从卡组把1张卡加入手卡（CATEGORY_TOHAND），供对方效果的发动检测使用
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：提示玩家选择卡片，从卡组选1只满足条件的怪兽加入手卡，并让对手确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的「米底乌斯」或「无垢大艺术」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果处理将选中的卡加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

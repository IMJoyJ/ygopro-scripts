--トリコロール・ガジェット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。把1张「光之黄金柜」或者有那个卡名记述的魔法·陷阱卡从卡组加入手卡。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1张「隐藏城 堡垒」在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 将「光之黄金柜」注册为此卡效果文本中记载的卡片密码
	aux.AddCodeList(c,79791878)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。把1张「光之黄金柜」或者有那个卡名记述的魔法·陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.srtg)
	e1:SetOperation(s.srop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把1张「隐藏城 堡垒」在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"卡组盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 检索卡片过滤条件：卡名为「光之黄金柜」或记载了「光之黄金柜」卡名的魔法·陷阱卡，且能加入手牌
function s.srfilter(c)
	-- 检查卡片是否为「光之黄金柜」或记载了「光之黄金柜」卡名的魔法·陷阱卡，且可以加入手牌
	return (c:IsCode(79791878) or aux.IsCodeListed(c,79791878) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
-- ①效果的发动准备与合法性检查，设置检索操作信息
function s.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.srfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的效果处理：从卡组将1张符合条件的卡加入手牌并给对方确认
function s.srop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选择1张满足检索条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.srfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示并确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：此卡被战斗或效果破坏
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 盖放卡片过滤条件：卡名为「隐藏城 堡垒」且可以盖放
function s.setfilter(c)
	return c:IsCode(27157727) and c:IsSSetable()
end
-- ②效果的发动准备与合法性检查
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在可以盖放的「隐藏城 堡垒」
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果的效果处理：从卡组选择1张「隐藏城 堡垒」在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家从卡组中选择1张满足盖放条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片在自己场上盖放
		Duel.SSet(tp,g)
	end
end

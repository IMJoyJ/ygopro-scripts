--顕現する伝説の都
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡只要在魔法与陷阱区域存在，卡名当作「海」使用。
-- ②：自己主要阶段才能发动。从卡组把1张「龙都 亚特兰蒂斯」或「海」在自己的场地区域表侧表示放置。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把1只海龙族·7星怪兽加入手卡。
local s,id,o=GetID()
-- 初始化函数：注册卡名变更（卡名当作「海」）、允许发动的空效果、②的放置场地魔法起动效果（1回合1次）和③的送墓检索海龙族7星怪兽的诱发效果
function s.initial_effect(c)
	-- 在卡上记载「龙都 亚特兰蒂斯」和「海」的卡名，用于代码检测
	aux.AddCodeList(c,38391684,22702055)
	-- 注册①的卡名变更效果：这张卡在魔法与陷阱区域存在时卡名当作「海」使用
	aux.EnableChangeCode(c,22702055)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ②：自己主要阶段才能发动。从卡组把1张「龙都 亚特兰蒂斯」或「海」在自己的场地区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置效果"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.fttg)
	e1:SetOperation(s.ftop)
	c:RegisterEffect(e1)
	-- ③：这张卡被送去墓地的场合才能发动。从卡组把1只海龙族·7星怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 定义场地魔法过滤器：卡名为「龙都 亚特兰蒂斯」或「海」、未被禁止、满足场上唯一性限制且为场地魔法
function s.tffilter(c,tp)
	return c:IsCode(38391684,22702055)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
		and c:IsType(TYPE_FIELD)
end
-- ②效果的发动条件：确认卡组中存在可放置的「龙都 亚特兰蒂斯」或「海」场地魔法
function s.fttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索卡组中是否存在至少1张满足条件的可放置场地魔法
	if chk==0 then return Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- ②效果的处理：让玩家从卡组选择1张「龙都 亚特兰蒂斯」或「海」，在自己的场地区域表侧表示放置
function s.ftop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示：请选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从自己卡组选择1张满足条件的场地魔法并取出
	local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将选中的卡移动到自己的场地区域表侧表示放置并立刻适用其效果
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
-- 定义检索过滤器：等级7、海龙族、可以加入手卡的怪兽
function s.thfilter(c)
	return c:IsLevel(7) and c:IsRace(RACE_SEASERPENT) and c:IsAbleToHand()
end
-- ③效果的发动条件：确认卡组中存在海龙族·7星怪兽，并设置加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索卡组中是否存在至少1只海龙族·7星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：连锁0、分类为加入手卡、预计从自己卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果的处理：让玩家从卡组选择1只海龙族·7星怪兽加入手卡，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1只满足条件的海龙族·7星怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以效果原因将选中的怪兽加入其持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

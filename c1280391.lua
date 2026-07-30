--顕現する伝説の都
local s,id,o=GetID()
-- 初始化效果函数，注册所有效果
function s.initial_effect(c)
	-- 为卡片添加代码列表，记录其关联的卡号38391684和22702055
	aux.AddCodeList(c,38391684,22702055)
	-- 启用卡片变更为卡号22702055的效果
	aux.EnableChangeCode(c,22702055)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 设置场地区域的起动效果，允许玩家从卡组选择场地魔法卡放置到场地区域
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.fttg)
	e1:SetOperation(s.ftop)
	c:RegisterEffect(e1)
	-- 设置墓地触发效果，当此卡被送入墓地时发动，检索一张海龙族7星怪兽加入手牌
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选可以放置到场地区的卡片，必须是38391684或22702055且未被禁止、满足唯一性检查、类型为场地魔法
function s.tffilter(c,tp)
	return c:IsCode(38391684,22702055)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
		and c:IsType(TYPE_FIELD)
end
-- 场地区域效果的发动条件判断函数，检查玩家卡组中是否存在满足条件的场地魔法卡
function s.fttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足tffilter条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 场地区域效果的处理函数，提示玩家选择一张场地魔法卡并放置到场地区域
function s.ftop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息“请选择要放置到场上的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择一张满足条件的场地魔法卡
	local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将选中的场地魔法卡移动到场地区域并正面表示
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
-- 过滤函数，用于筛选可以加入手牌的卡片，必须是7星海龙族怪兽且能被送入手牌
function s.thfilter(c)
	return c:IsLevel(7) and c:IsRace(RACE_SEASERPENT) and c:IsAbleToHand()
end
-- 墓地触发效果的发动条件判断函数，检查玩家卡组中是否存在满足条件的海龙族7星怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足thfilter条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果将把一张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 墓地触发效果的处理函数，提示玩家选择一张海龙族7星怪兽并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的海龙族7星怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end

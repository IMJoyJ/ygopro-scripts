--深淵の獣ルベリオン
-- 效果：
-- 这张卡不能通常召唤。「深渊之兽 赫界龙」1回合1次在把自己场上1只6星以上的龙族·暗属性怪兽解放的场合才能从手卡·墓地特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡送去墓地才能发动。从卡组把「深渊之兽 赫界龙」以外的1只「深渊之兽」怪兽加入手卡。
-- ②：自己主要阶段才能发动。从卡组把1张「烙印」永续魔法·永续陷阱卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 初始化卡片效果，设置不能通常召唤，注册特殊召唤条件、特殊召唤处理、检索效果和放置效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
	-- 「深渊之兽 赫界龙」1回合1次在把自己场上1只6星以上的龙族·暗属性怪兽解放的场合才能从手卡·墓地特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 把这张卡从手卡送去墓地才能发动。从卡组把「深渊之兽 赫界龙」以外的1只「深渊之兽」怪兽加入手卡
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 自己主要阶段才能发动。从卡组把1张「烙印」永续魔法·永续陷阱卡在自己场上表侧表示放置
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 筛选满足6星以上、暗属性、龙族且场上存在空怪兽区的怪兽
function s.cfilter(c,tp)
	return c:IsLevelAbove(6) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
		-- 确保场上存在空怪兽区
		and Duel.GetMZoneCount(tp,c)>0
end
-- 判断是否满足特殊召唤条件，即是否能解放满足条件的怪兽
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在满足条件的怪兽用于解放
	return Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 设置特殊召唤的目标选择逻辑，选择要解放的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的怪兽组并筛选满足条件的怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.cfilter,nil,tp)
	-- 提示玩家选择要解放的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤的解放操作
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 设置检索效果的费用，将自身送去墓地
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为费用
	Duel.SendtoGrave(c,REASON_COST)
end
-- 筛选满足「深渊之兽」卡组、非本卡、可加入手牌的怪兽
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x188) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 设置检索效果的目标，检查卡组是否存在满足条件的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息，表示要将一张怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选满足「烙印」卡组、永续魔法/陷阱、未被禁止且场上唯一存在的卡
function s.pfilter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0x15d)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 设置放置效果的目标，检查是否满足放置条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在空的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组是否存在满足条件的「烙印」卡
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 执行放置效果，选择并放置到场上
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在空的魔法陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择满足条件的「烙印」卡
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	-- 将选中的卡放置到场上
	if tc then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end

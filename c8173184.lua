--リペア・ジェネクス・コントローラー
--not fully implemented
-- 效果：
-- （注：暂时无法正常使用）
-- 
-- 4星以下的「次世代」怪兽1只
-- 自己对「修复次世代控制员」1回合只能有1次特殊召唤。
-- ①：这张卡连接召唤的场合才能发动。从自己墓地把1只「次世代」怪兽加入手卡。
-- ②：「次世代」怪兽用抽卡以外的方法加入自己手卡的场合才能发动（同一连锁上最多1次）。进行1只「次世代」怪兽的召唤。这个回合，自己不用以「次世代」调整为同调素材的同调召唤不能从额外卡组把怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：设置连接召唤素材要求、苏生限制与「修复次世代控制员」1回合1次特殊召唤限制，并注册①连接召唤回收墓地效果和②「次世代」怪兽入手后追加召唤效果
function s.initial_effect(c)
	-- 设置连接召唤条件：以1只满足mfilter（4星以下的「次世代」怪兽）的怪兽作为连接素材
	aux.AddLinkProcedure(c,s.mfilter,1,1)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	-- ①：这张卡连接召唤的场合才能发动。从自己墓地把1只「次世代」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"墓地加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：「次世代」怪兽用抽卡以外的方法加入自己手卡的场合才能发动（同一连锁上最多1次）。进行1只「次世代」怪兽的召唤。这个回合，自己不用以「次世代」调整为同调素材的同调召唤不能从额外卡组把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.smcon)
	e2:SetTarget(s.smtg)
	e2:SetOperation(s.smop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤函数：筛选4星以下的「次世代」怪兽
function s.mfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x2)
end
-- 检查①效果发动条件：此卡是否通过连接召唤方式出场
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤可加入手卡的「次世代」卡片（用于墓地检索「次世代」怪兽）
function s.thfilter(c)
	return c:IsSetCard(0x2) and c:IsAbleToHand()
end
-- 发动前确认己方墓地存在可加入手卡的「次世代」怪兽并登记回收操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方墓地是否存在至少1张满足thfilter条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 登记从己方墓地将1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果处理：从己方墓地选择1只「次世代」怪兽加入手卡并向对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方发送从墓地选择要加入手卡的「次世代」怪兽的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方从墓地选择1张满足条件的「次世代」卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片以效果加入己方手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤手卡中可忽略通常召唤次数限制进行召唤的「次世代」怪兽
function s.smfilter(c)
	return c:IsSetCard(0x2) and c:IsSummonable(true,nil)
end
-- ②效果触发过滤函数：筛选由非抽卡方式进入己方手卡且已公开确认的「次世代」怪兽
function s.trigfilter(c,tp)
	return c:IsSetCard(0x2) and c:IsControler(tp) and c:IsType(TYPE_MONSTER) and not c:IsReason(REASON_DRAW)
		and not (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN) and not c:IsPublic())
		and (not c:IsStatus(STATUS_TO_HAND_WITHOUT_CONFIRM) or (c:IsStatus(STATUS_TO_HAND_WITHOUT_CONFIRM) and c:IsPublic()))
end
-- 检查②效果发动条件：本次加入手卡事件中是否存在满足trigfilter条件的「次世代」怪兽
function s.smcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.trigfilter,1,nil,tp)
end
-- 发动前确认手卡存在可召唤的「次世代」怪兽并登记通常召唤操作信息
function s.smtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方手卡是否存在至少1只可进行通常召唤的「次世代」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.smfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 登记进行1次怪兽通常召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②效果处理：从手卡选择1只「次世代」怪兽忽略召唤次数进行通常召唤，并注册本回合只能以「次世代」调整为素材进行同调召唤才可从额外卡组特召的限制
function s.smop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向己方发送从手卡选择要进行通常召唤的「次世代」怪兽的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让己方从手卡选择1只可召唤的「次世代」怪兽
	local g=Duel.SelectMatchingCard(tp,s.smfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 让己方忽略每回合通常召唤次数限制，对选中的「次世代」怪兽进行通常召唤
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
	-- 为己方注册持续至回合结束的额外卡组特殊召唤限制：必须是以「次世代」调整为素材的同调召唤
	aux.RegisterSynchroMaterialRequire(c,tp,s.tlmfilter,RESET_PHASE+PHASE_END)
end
-- 同调素材要求过滤函数：限定必须包含「次世代」字段的调整怪兽
function s.tlmfilter(c)
	return c:IsSetCard(0x2) and c:IsType(TYPE_TUNER)
end

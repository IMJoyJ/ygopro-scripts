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
-- 初始化函数，注册卡片效果：包含连接召唤手续、1回合1次特召限制、①效果（连接召唤成功时回收墓地怪兽）和②效果（「次世代」怪兽加入手卡时进行召唤并施加特召限制）
function s.initial_effect(c)
	-- 设置连接召唤手续，需要1只满足过滤条件的怪兽作为素材
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
	-- ②：「次世代」怪兽用抽卡以外的方法加入自己手卡的场合才能发动（同一连锁上最多1次）。进行1只「次世代」怪兽的召唤。
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
-- 过滤连接素材：4星以下的「次世代」怪兽
function s.mfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x2)
end
-- 检查此卡是否是通过连接召唤特殊召唤的，作为①效果的发动条件
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤可以从墓地加入手卡的「次世代」怪兽
function s.thfilter(c)
	return c:IsSetCard(0x2) and c:IsAbleToHand()
end
-- ①效果的发动准备，检查墓地是否存在可回收的「次世代」怪兽，并设置回收手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以加入手卡的「次世代」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息：从自己墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果的处理：让玩家选择墓地中的1只「次世代」怪兽加入手卡并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只满足条件的「次世代」怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤手卡中可以进行通常召唤的「次世代」怪兽
function s.smfilter(c)
	return c:IsSetCard(0x2) and c:IsSummonable(true,nil)
end
-- 过滤触发②效果的卡：非抽卡加入自己手卡的「次世代」怪兽，且需满足公开状态等规则细节
function s.trigfilter(c,tp)
	return c:IsSetCard(0x2) and c:IsControler(tp) and c:IsType(TYPE_MONSTER) and not c:IsReason(REASON_DRAW)
		and not (c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN) and not c:IsPublic())
		and (not c:IsStatus(STATUS_TO_HAND_WITHOUT_CONFIRM) or (c:IsStatus(STATUS_TO_HAND_WITHOUT_CONFIRM) and c:IsPublic()))
end
-- 检查是否有满足条件的「次世代」怪兽加入手卡，作为②效果的发动条件
function s.smcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.trigfilter,1,nil,tp)
end
-- ②效果的发动准备，检查手卡中是否有可召唤的「次世代」怪兽，并设置召唤的操作信息
function s.smtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡中是否存在可以进行通常召唤的「次世代」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.smfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置效果处理信息：进行1只怪兽的召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②效果的处理：进行1只「次世代」怪兽的召唤，并适用本回合从额外卡组特召怪兽的限制
function s.smop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「次世代」怪兽
	local g=Duel.SelectMatchingCard(tp,s.smfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 让玩家对选中的怪兽进行通常召唤（忽略每回合的通常召唤次数限制）
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
	-- 这个回合，自己不用以「次世代」调整为同调素材的同调召唤不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家从额外卡组特殊召唤非同调怪兽的效果
	Duel.RegisterEffect(e1,tp)
	-- 这个回合，自己不用以「次世代」调整为同调素材的同调召唤不能从额外卡组把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTarget(s.tlmtg)
	e2:SetValue(s.tlmval)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制非「次世代」调整不能作为同调素材的效果
	Duel.RegisterEffect(e2,tp)
	-- 这个回合，自己不用以「次世代」调整为同调素材的同调召唤不能从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(id)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册用于标记本回合已适用该特殊召唤限制的玩家标记效果
	Duel.RegisterEffect(e3,tp)
end
-- 限制从额外卡组特殊召唤非同调怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and bit.band(sumtype,SUMMON_TYPE_SYNCHRO)~=SUMMON_TYPE_SYNCHRO
end
-- 过滤非「次世代」的调整怪兽
function s.tlmtg(e,c)
	return c:IsType(TYPE_TUNER) and not c:IsSetCard(0x2)
end
-- 限制非「次世代」调整不能作为同调素材
function s.tlmval(e,sync)
	local tp=e:GetHandlerPlayer()
	if sync:GetControler()==tp then
		-- 检查玩家是否未获得豁免标记（用于处理某些特殊同调召唤情况）
		return Duel.GetFlagEffect(tp,id+1)==0
	end
	return false
end

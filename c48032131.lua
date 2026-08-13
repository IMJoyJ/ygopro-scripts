--D－タクティクス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己·对方的准备阶段才能发动。自己场上的全部「英雄」怪兽的攻击力上升400。
-- ②：自己场上有8星以上的「命运英雄」怪兽或者「龙骑士 D-终」特殊召唤的场合才能发动。选对方的手卡·场上·墓地1张卡除外。
-- ③：魔法与陷阱区域的这张卡被效果破坏的场合才能发动。从卡组把1只「命运英雄」怪兽加入手卡。
function c48032131.initial_effect(c)
	-- 记录这张卡的效果文中记载了「龙骑士 D-终」(76263644)的卡名，供相关规则/检索判定使用。
	aux.AddCodeList(c,76263644)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对应效果原文：这个卡名的①②③的效果1回合各能使用1次。①：自己·对方的准备阶段才能发动。自己场上的全部「英雄」怪兽的攻击力上升400。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48032131,0))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1,48032131)
	e2:SetTarget(c48032131.adtg)
	e2:SetOperation(c48032131.adop)
	c:RegisterEffect(e2)
	-- 对应效果原文：这个卡名的①②③的效果1回合各能使用1次。②：自己场上有8星以上的「命运英雄」怪兽或者「龙骑士 D-终」特殊召唤的场合才能发动。选对方的手卡·场上·墓地1张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48032131,1))  --"卡片除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,48032132)
	e3:SetCondition(c48032131.rmcon)
	e3:SetTarget(c48032131.rmtg)
	e3:SetOperation(c48032131.rmop)
	c:RegisterEffect(e3)
	-- 对应效果原文：这个卡名的①②③的效果1回合各能使用1次。③：魔法与陷阱区域的这张卡被效果破坏的场合才能发动。从卡组把1只「命运英雄」怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,48032133)
	e4:SetCondition(c48032131.thcon)
	e4:SetTarget(c48032131.thtg)
	e4:SetOperation(c48032131.thop)
	c:RegisterEffect(e4)
end
-- 过滤条件：怪兽须为表侧表示且属于「英雄」(0x8)字段，用于判定自己场上的「英雄」怪兽。
function c48032131.adfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8)
end
-- ①效果的发动条件判定：仅在当前存在至少1只自己场上表侧表示且属于「英雄」字段的怪兽时才可发动。
function c48032131.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0（发动时）检查是否存在至少1张满足adfilter的卡；不存在则①效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c48032131.adfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ①效果处理：取自己场上全部表侧表示「英雄」怪兽，逐只赋予攻击力上升400的效果，该效果随怪兽离场等标准状态重置。
function c48032131.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索并获取自己场上所有满足adfilter的表侧「英雄」怪兽，组成处理用的怪兽集合。
	local g=Duel.GetMatchingGroup(c48032131.adfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对应效果原文：自己场上的全部「英雄」怪兽的攻击力上升400。这里为每一只对象怪兽创建一个攻击力上升400的效果并注册到该怪兽。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- ②触发怪兽条件：表侧表示且为自己控制，并且是「龙骑士 D-终」(76263644)，或是等级8以上且属于「命运英雄」(0xc008)字段的怪兽。
function c48032131.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and (c:IsCode(76263644) or c:IsLevelAbove(8) and c:IsSetCard(0xc008))
end
-- ②效果的触发条件：本次特殊召唤成功的怪兽集合中，存在至少1只符合cfilter条件的怪兽（8星以上命运英雄或龙骑士 D-终）。
function c48032131.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c48032131.cfilter,1,nil,tp)
end
-- ②效果的发动条件判定与操作信息登记：确认对方手卡·场上·墓地存在至少1张可除外的卡，并登记除外1张卡的操作信息（具体卡在效果处理时确定，不取对象）。
function c48032131.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0（发动时）检查对方手卡·场上·墓地中是否有至少1张可除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 登记本连锁将进行除外处理：数量为1，区域为对方手卡·场上·墓地，具体目标由效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- ②效果处理：分别取得对方手卡、对方场上·墓地的可除外卡；两处都有可用卡时由玩家选择除外来源，手卡随机选1张，场上·墓地由玩家选1张，然后表侧除外。
function c48032131.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方手卡中所有当前可以被除外的卡。
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	-- 取得对方场上与墓地中所有当前可以被除外的卡。
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	local opt=0
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 当对方手卡和场上·墓地都有可选卡时，弹出选择提示，由当前玩家选择除外手卡还是除外场上·墓地的卡。
		opt=Duel.SelectOption(tp,aux.Stringid(48032131,2),aux.Stringid(48032131,3))  --"除外手卡/除外场上·墓地的卡"
	elseif g1:GetCount()>0 then
		opt=0
	elseif g2:GetCount()>0 then
		opt=1
	else
		return
	end
	local sg=nil
	if opt==0 then
		sg=g1:RandomSelect(tp,1)
	else
		-- 在选择场上·墓地的卡之前，给当前玩家发送‘请选择要除外的卡’的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		sg=g2:Select(tp,1,1,nil)
	end
	-- 将选中的卡以表侧表示从当前区域除外，除外原因是效果。
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
-- ③效果的发动条件：这张卡是被效果破坏，且破坏前位于魔法与陷阱区域。
function c48032131.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_SZONE)
end
-- 过滤条件：卡组中的「命运英雄」(0xc008)怪兽，且可以被加入手卡。
function c48032131.thfilter(c)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ③效果的目标判定与操作信息登记：确认卡组中存在至少1只符合条件的「命运英雄」怪兽，并登记从卡组检索加入手卡的操作信息。
function c48032131.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0（发动时）检查卡组中是否存在至少1张满足thfilter的「命运英雄」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c48032131.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本连锁将进行从卡组把1只怪兽加入手卡的处理，数量1，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：提示玩家从卡组选择1只符合条件的「命运英雄」怪兽，加入手卡，并向对方玩家展示该卡。
function c48032131.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给当前玩家发送‘请选择要加入手牌的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中筛选并选择1张满足thfilter的「命运英雄」怪兽。
	local g=Duel.SelectMatchingCard(tp,c48032131.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡（此处即当前玩家的手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end

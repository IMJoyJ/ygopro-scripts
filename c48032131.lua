--D－タクティクス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己·对方的准备阶段才能发动。自己场上的全部「英雄」怪兽的攻击力上升400。
-- ②：自己场上有8星以上的「命运英雄」怪兽或者「龙骑士 D-终」特殊召唤的场合才能发动。选对方的手卡·场上·墓地1张卡除外。
-- ③：魔法与陷阱区域的这张卡被效果破坏的场合才能发动。从卡组把1只「命运英雄」怪兽加入手卡。
function c48032131.initial_effect(c)
	-- 记录此卡与「龙骑士 D-终」的卡片代码关联
	aux.AddCodeList(c,76263644)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的准备阶段才能发动。自己场上的全部「英雄」怪兽的攻击力上升400。
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
	-- ②：自己场上有8星以上的「命运英雄」怪兽或者「龙骑士 D-终」特殊召唤的场合才能发动。选对方的手卡·场上·墓地1张卡除外。
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
	-- ③：魔法与陷阱区域的这张卡被效果破坏的场合才能发动。从卡组把1只「命运英雄」怪兽加入手卡。
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
-- 过滤函数，用于判断是否为场上表侧表示的「英雄」怪兽
function c48032131.adfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8)
end
-- 效果处理时的检查函数，确认自己场上有至少1只「英雄」怪兽
function c48032131.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「英雄」怪兽存在
	if chk==0 then return Duel.IsExistingMatchingCard(c48032131.adfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果发动时执行的操作函数，将所有符合条件的怪兽攻击力上升400
function c48032131.adop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足条件的场上怪兽组
	local g=Duel.GetMatchingGroup(c48032131.adfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为每个符合条件的怪兽添加攻击力增加400的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 过滤函数，用于判断是否为己方场上的8星以上「命运英雄」怪兽或「龙骑士 D-终」
function c48032131.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and (c:IsCode(76263644) or c:IsLevelAbove(8) and c:IsSetCard(0xc008))
end
-- 触发条件函数，检查是否有满足条件的怪兽被特殊召唤成功
function c48032131.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c48032131.cfilter,1,nil,tp)
end
-- 效果处理时的检查函数，确认对方手卡·场上·墓地有可除外的卡
function c48032131.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的卡可以除外
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 设置操作信息，指定要除外的卡的位置和数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果发动时执行的操作函数，选择并除外对方一张卡
function c48032131.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡中可除外的卡组
	local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	-- 获取对方场上或墓地中可除外的卡组
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	local opt=0
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 让玩家选择从手卡或场上·墓地除外卡
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
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		sg=g2:Select(tp,1,1,nil)
	end
	-- 执行将选中的卡除外的操作
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
-- 触发条件函数，检查此卡是否因效果破坏且之前在魔法与陷阱区域
function c48032131.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_SZONE)
end
-- 过滤函数，用于判断是否为「命运英雄」怪兽且可加入手牌
function c48032131.thfilter(c)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理时的检查函数，确认卡组中有满足条件的「命运英雄」怪兽
function c48032131.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「命运英雄」怪兽存在
	if chk==0 then return Duel.IsExistingMatchingCard(c48032131.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，指定要加入手牌的卡的位置和数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时执行的操作函数，从卡组检索1只「命运英雄」怪兽加入手牌
function c48032131.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c48032131.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了被送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

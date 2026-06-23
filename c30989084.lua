--アロマリリス－ローズマリー
-- 效果：
-- 植物族怪兽2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「芳香」卡加入手卡。
-- ②：自己基本分回复的场合才能发动（伤害步骤也能发动）。从手卡把最多3只「芳香」怪兽在作为这张卡所连接区的自己场上特殊召唤。
-- ③：把这张卡所连接区1只怪兽解放，以场上1张卡为对象才能发动。那张卡除外，自己回复1000基本分。
local s,id,o=GetID()
-- 初始化卡片效果，设置连接召唤条件，创建三个效果
function c30989084.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤需要2~3只植物族怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT),2,3)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「芳香」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己基本分回复的场合才能发动（伤害步骤也能发动）。从手卡把最多3只「芳香」怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从手卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RECOVER)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：把这张卡所连接区1只怪兽解放，以场上1张卡为对象才能发动。那张卡除外，自己回复1000基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"卡片除外"
	e3:SetCategory(CATEGORY_RECOVER+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCost(s.rmcost)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数，用于检索卡组中「芳香」族且能加入手牌的卡
function s.filter(c)
	return c:IsSetCard(0xc9) and c:IsAbleToHand()
end
-- 设置检索效果的处理目标，检查卡组中是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动了检索效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置检索效果的操作信息，指定将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果的操作，选择卡组中的一张「芳香」卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义回复LP时的触发条件，确保是自己回复LP
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 定义特殊召唤时的过滤函数，用于筛选手牌中「芳香」族且可特殊召唤的怪兽
function s.spfilter(c,e,tp,zone)
	return c:IsSetCard(0xc9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 设置特殊召唤效果的处理目标，检查手牌中是否存在满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,zone) end
	-- 设置特殊召唤效果的操作信息，指定将怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤效果的操作，选择手牌中的怪兽进行特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if zone==0 then return end
	-- 获取当前玩家在指定区域的召唤位置数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	if ft<1 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,ft,nil,e,tp,zone)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 定义用于判断是否为连接区怪兽的过滤函数
function s.cfilter(c,g)
	return g:IsContains(c)
end
-- 设置除外效果的费用，需要解放连接区中的怪兽
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 检查场上是否存在满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,lg) end
	-- 选择要解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,lg)
	-- 解放选中的怪兽作为费用
	Duel.Release(g,REASON_COST)
end
-- 定义除外效果中可特殊召唤的怪兽过滤函数
function s.rmfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置除外效果的处理目标，选择场上一张卡进行除外
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上一张可除外的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置操作对象参数为1000
	Duel.SetTargetParam(1000)
	-- 设置除外效果的操作信息，指定将卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置除外效果的操作信息，指定回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 执行除外效果的操作，将选中的卡除外并回复LP
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 检查目标卡是否有效且成功除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 回复1000基本分
		Duel.Recover(tp,1000,REASON_EFFECT)
	end
end

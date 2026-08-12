--X・HERO クロスガイ
-- 效果：
-- 战士族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次，这张卡的效果发动的回合，自己不是「英雄」怪兽不能特殊召唤。
-- ①：这张卡连接召唤的场合，以自己墓地1只「命运英雄」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：把自己场上1只「命运英雄」怪兽解放才能发动。和解放的怪兽卡名不同的1只「英雄」怪兽从卡组加入手卡。
function c58004362.initial_effect(c)
	-- 添加连接召唤手续：战士族怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合，以自己墓地1只「命运英雄」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58004362,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,58004362)
	e1:SetCost(c58004362.cost)
	e1:SetCondition(c58004362.spcon)
	e1:SetTarget(c58004362.sptg)
	e1:SetOperation(c58004362.spop)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只「命运英雄」怪兽解放才能发动。和解放的怪兽卡名不同的1只「英雄」怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58004362,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,58004363)
	e2:SetCost(c58004362.thcost)
	e2:SetTarget(c58004362.thtg)
	e2:SetOperation(c58004362.thop)
	c:RegisterEffect(e2)
	-- 注册特殊召唤活动计数器，用于检测该回合是否特殊召唤过「英雄」怪兽以外的怪兽
	Duel.AddCustomActivityCounter(58004362,ACTIVITY_SPSUMMON,c58004362.counterfilter)
end
-- 特殊召唤活动计数器的过滤函数，检查是否为表侧表示的「英雄」怪兽
function c58004362.counterfilter(c)
	return c:IsSetCard(0x8) and c:IsFaceup()
end
-- 效果发动的回合，自己不是「英雄」怪兽不能特殊召唤的限制条件检查与注册
function c58004362.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查自己本回合是否特殊召唤过非「英雄」怪兽
	if chk==0 then return Duel.GetCustomActivityCount(58004362,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②的效果1回合各能使用1次，这张卡的效果发动的回合，自己不是「英雄」怪兽不能特殊召唤。①：这张卡连接召唤的场合，以自己墓地1只「命运英雄」怪兽为对象才能发动。那只怪兽特殊召唤。②：把自己场上1只「命运英雄」怪兽解放才能发动。和解放的怪兽卡名不同的1只「英雄」怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c58004362.splimit)
	-- 向玩家注册本回合不能特殊召唤非「英雄」怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤，限制玩家只能特殊召唤「英雄」怪兽
function c58004362.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x8)
end
-- 效果①的发动条件：此卡是连接召唤成功
function c58004362.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤自己墓地可特殊召唤的「命运英雄」怪兽
function c58004362.spfilter(c,e,tp)
	return c:IsSetCard(0xc008) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：进行特召限制检查，选择墓地的「命运英雄」怪兽作为对象，设置特殊召唤操作信息
function c58004362.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c58004362.spfilter(chkc,e,tp) end
	-- 在chk为0时，检查自己场上的怪兽区域是否有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在chk为0时，检查自己墓地是否存在可特殊召唤的「命运英雄」怪兽
		and Duel.IsExistingTarget(c58004362.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「命运英雄」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c58004362.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为：特殊召唤选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将选择的对象怪兽特殊召唤
function c58004362.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取已选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选择的对象怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动Cost的检查：通过设置Label以标记这是一个Cost处理阶段，并返回true
function c58004362.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤自己场上用于解放的「命运英雄」怪兽，要求卡组存在可检索的其他「英雄」怪兽
function c58004362.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xc008)
		-- 检查卡组中是否存在与该解放怪兽卡名不同的「英雄」怪兽
		and Duel.IsExistingMatchingCard(c58004362.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 过滤卡组中与解放怪兽卡名不同的可检索的「英雄」怪兽
function c58004362.thfilter(c,code)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8) and c:IsAbleToHand() and not c:IsCode(code)
end
-- 效果②的发动准备：进行特召限制检查，选择自己场上1只「命运英雄」怪兽解放，记录其卡名，并设置检索操作信息
function c58004362.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return c58004362.cost(e,tp,eg,ep,ev,re,r,rp,0)
			-- 在chk为0时，检查自己场上是否存在可解放的「命运英雄」怪兽
			and Duel.CheckReleaseGroup(tp,c58004362.cfilter,1,nil,tp)
	end
	c58004362.cost(e,tp,eg,ep,ev,re,r,rp,1)
	-- 选择自己场上1只「命运英雄」怪兽作为解放的对象
	local rg=Duel.SelectReleaseGroup(tp,c58004362.cfilter,1,1,nil,tp)
	e:SetValue(rg:GetFirst():GetCode())
	-- 将被选中的怪兽解放
	Duel.Release(rg,REASON_COST)
	-- 设置当前连锁的操作信息为：从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组将1只与解放的怪兽卡名不同的「英雄」怪兽加入手牌
function c58004362.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组检索1只与解放的怪兽卡名不同的「英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,c58004362.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetValue())
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认选中的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end

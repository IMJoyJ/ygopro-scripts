--カプシー★ヤミーウェイ
-- 效果：
-- 调整＋调整以外的怪兽1只
-- 这张卡同调召唤的场合，可以把自己场上1只连接1怪兽当作1星调整使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组把2只「味美喵」怪兽加入手卡。那之后，选自己1张手卡丢弃。
-- ②：对方把魔法·陷阱·怪兽的效果发动时，让这张卡回到额外卡组才能发动。从自己墓地把最多2只「味美喵」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，设置同调召唤手续、检索效果和特殊召唤效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续，要求1只调整或连接1怪兽作为素材
	aux.AddSynchroMixProcedure(c,s.matfilter1,nil,nil,s.matfilter2,1,1)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SYNCHRO_LEVEL_EX)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(s.syntg)
	e0:SetValue(s.synval)
	c:RegisterEffect(e0)
	-- ①：这张卡同调召唤的场合才能发动。从卡组把2只「味美喵」怪兽加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱·怪兽的效果发动时，让这张卡回到额外卡组才能发动。从自己墓地把最多2只「味美喵」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤调整或连接1怪兽作为同调素材
function s.matfilter1(c,syncard)
	return c:IsTuner(syncard) or c:IsType(TYPE_LINK) and c:IsLink(1)
end
-- 过滤非调整且非连接怪兽作为同调素材
function s.matfilter2(c,syncard)
	return c:IsNotTuner(syncard) and not c:IsType(TYPE_LINK)
end
-- 设定同调召唤时可使用的连接1怪兽
function s.syntg(e,c)
	return c:IsType(TYPE_LINK) and c:IsLink(1)
end
-- 设定连接1怪兽的等级为1
function s.synval(e,syncard)
	if e:GetHandler()==syncard then
		return 1
	else
		return 0
	end
end
-- 判断是否为同调召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤「味美喵」怪兽，可加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x1ca) and c:IsAbleToHand() and c:IsType(TYPE_MONSTER)
end
-- 设置检索效果的处理目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在2只满足条件的「味美喵」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置检索效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理检索效果的发动与执行
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡组是否存在2只满足条件的「味美喵」怪兽
	if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择2张满足条件的「味美喵」怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,2,2,nil)
	-- 将选中的怪兽加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择1张可丢弃的手牌
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 洗切玩家手牌
		Duel.ShuffleHand(tp)
		if dg:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将选中的手牌丢弃至墓地
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 判断是否为对方发动效果
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 设置特殊召唤效果的费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	-- 将自身送至额外卡组作为费用
	Duel.SendtoDeck(e:GetHandler(),nil,0,REASON_COST)
end
-- 过滤可特殊召唤的「味美喵」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1ca) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的处理目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在满足条件的「味美喵」怪兽
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler(),tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 处理特殊召唤效果的发动与执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算可特殊召唤的怪兽数量
	local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ft==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「味美喵」怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤至场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

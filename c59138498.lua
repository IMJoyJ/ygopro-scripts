--三幻魔の殉教者
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「三幻魔」场地魔法·永续魔法·永续陷阱卡在自己场上表侧表示放置。
-- ②：自己场上有其他的「三幻魔」怪兽存在的场合才能发动。从自己的手卡·卡组·墓地把2只「三幻魔的殉教者」特殊召唤。
-- ③：对方结束阶段，自己墓地有这张卡和10星「三幻魔」怪兽存在的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果注册
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「三幻魔」场地魔法·永续魔法·永续陷阱卡在自己场上表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"放置魔陷"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己场上有其他的「三幻魔」怪兽存在的场合才能发动。从自己的手卡·卡组·墓地把2只「三幻魔的殉教者」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ③：对方结束阶段，自己墓地有这张卡和10星「三幻魔」怪兽存在的场合才能发动。这张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.thcon)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 效果①的放置卡片过滤函数，筛选卡组中的「三幻魔」永续魔法、永续陷阱或场地魔法
function s.pfilter(c,tp)
	return c:IsSetCard(0x1144) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
		-- 检查该卡是否为永续类型，且自己场上是否有空余的魔法与陷阱区域
		and (c:IsType(TYPE_CONTINUOUS) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			or c:IsType(TYPE_FIELD))
end
-- 效果①的target函数，检查卡组中是否存在可以放置的「三幻魔」卡片
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以表侧表示放置的「三幻魔」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 向对方玩家提示已选择发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①的operation函数，处理从卡组选择1张「三幻魔」魔法·陷阱卡并在场上表侧表示放置
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从卡组中选择1张满足条件的「三幻魔」卡片
	local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		if tc:IsType(TYPE_CONTINUOUS) then
			-- 将选中的永续卡片放置到自己的魔法与陷阱区域
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		else
			-- 将选中的场地魔法卡放置到自己的场地区域
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		end
	end
end
-- 效果②的怪兽过滤函数，筛选自己场上表侧表示的「三幻魔」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1144)
end
-- 效果②的触发条件函数，检查自己场上是否存在其他的「三幻魔」怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上除这张卡以外是否存在其他表侧表示的「三幻魔」怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果②的特殊召唤过滤函数，筛选名称为「三幻魔的殉教者」且可以特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的target函数，检查限制、空余怪兽区域及手卡·卡组·墓地是否有足够的「三幻魔的殉教者」，并设置特殊召唤的连锁操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有至少2个空余的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己的手卡、卡组、墓地中是否存在至少2只可以特殊召唤的「三幻魔的殉教者」
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 向对方玩家提示已选择特殊召唤的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤操作信息，表示从手卡、卡组、墓地将2只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②的operation函数，处理从手卡·卡组·墓地选择2只「三幻魔的殉教者」特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若可用怪兽区域不足2个，则结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取手卡、卡组、墓地中满足条件的「三幻魔的殉教者」怪兽集合
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选择的2只「三幻魔的殉教者」在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的怪兽过滤函数，筛选自己墓地中10星的「三幻魔」怪兽
function s.cfilter2(c)
	return c:IsLevel(10) and c:IsSetCard(0x1144)
end
-- 效果③的触发条件函数，检查对方结束阶段时自己墓地是否存在这张卡和10星「三幻魔」怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地中是否存在10星的「三幻魔」怪兽，且当前为对方的回合结束阶段
	return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_GRAVE,0,1,e:GetHandler()) and Duel.GetTurnPlayer()==1-tp
end
-- 效果③的target函数，检查墓地中的这张卡是否可以加入手卡，并设置加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置加入手卡操作信息，表示将墓地中的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果③的operation函数，处理将墓地中的这张卡加入手卡并展示
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查该卡是否与连锁相关且不受墓地针对效果影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡送回持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的这张卡片
		Duel.ConfirmCards(1-tp,c)
	end
end

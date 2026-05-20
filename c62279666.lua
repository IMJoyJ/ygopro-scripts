--星遺物が導く果て
-- 效果：
-- ①：「星遗物引导的终点」在自己场上只能有1张表侧表示存在。
-- ②：1回合1次，自己场上的表侧表示的连接怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从手卡·卡组把1只「星遗物」怪兽守备表示特殊召唤。
function c62279666.initial_effect(c)
	c:SetUniqueOnField(1,0,62279666)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上的表侧表示的连接怪兽因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从手卡·卡组把1只「星遗物」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62279666,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c62279666.spcon)
	e2:SetTarget(c62279666.sptg)
	e2:SetOperation(c62279666.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查离开场上的卡是否为自己场上表侧表示的连接怪兽，且因战斗破坏或因对方的效果离开场上
function c62279666.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0
		and (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT)))
end
-- 检查因离开场上而触发效果的卡片组中是否存在满足过滤条件的怪兽
function c62279666.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c62279666.cfilter,1,nil,tp,rp)
end
-- 过滤条件：卡组或手卡中可以守备表示特殊召唤的「星遗物」怪兽
function c62279666.spfilter(c,e,tp)
	return c:IsSetCard(0xfe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标检查与操作信息注册
function c62279666.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组是否存在至少1只满足特殊召唤条件的「星遗物」怪兽
		and Duel.IsExistingMatchingCard(c62279666.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息为从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：从手卡或卡组选择1只「星遗物」怪兽守备表示特殊召唤
function c62279666.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的「星遗物」怪兽
	local g=Duel.SelectMatchingCard(tp,c62279666.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

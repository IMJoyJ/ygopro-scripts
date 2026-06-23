--麗の魔妖－妲姫
-- 效果：
-- ①：「丽之魔妖-妲姬」在自己场上只能有1只表侧表示存在。
-- ②：这张卡在墓地存在，「魔妖」怪兽从额外卡组往自己场上特殊召唤时才能发动。这张卡特殊召唤。这个效果发动的回合，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
function c42542842.initial_effect(c)
	c:SetUniqueOnField(1,0,42542842)
	-- ②：这张卡在墓地存在，「魔妖」怪兽从额外卡组往自己场上特殊召唤时才能发动。这张卡特殊召唤。这个效果发动的回合，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42542842,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c42542842.spcon)
	e1:SetCost(c42542842.spcost)
	e1:SetTarget(c42542842.sptg)
	e1:SetOperation(c42542842.spop)
	c:RegisterEffect(e1)
	-- 设置限制额外卡组特殊召唤非「魔妖」怪兽的自定义计数器
	Duel.AddCustomActivityCounter(42542842,ACTIVITY_SPSUMMON,c42542842.counterfilter)
end
-- 计数器过滤条件：只允许从额外卡组以外的特殊召唤或表侧表示的「魔妖」怪兽的特殊召唤
function c42542842.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x121) and c:IsFaceup()
end
-- 过滤条件：自己场上从额外卡组特殊召唤的「魔妖」怪兽
function c42542842.cfilter(c,tp)
	return c:IsSetCard(0x121) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsControler(tp)
end
-- 发动条件：检查是否有从额外卡组往自己场上特殊召唤「魔妖」怪兽的事件发生
function c42542842.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c42542842.cfilter,1,nil,tp)
end
-- 发动代价：检查本回合是否未特殊召唤过非「魔妖」怪兽，并在发动时施加回合内不能从额外卡组特殊召唤非「魔妖」怪兽的誓约效果
function c42542842.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合内自己是否未特殊召唤过额外卡组的非「魔妖」怪兽
	if chk==0 then return Duel.GetCustomActivityCount(42542842,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡特殊召唤。这个效果发动的回合，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c42542842.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给自身玩家注册这个特殊召唤限制的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果发动目标：检查自己怪兽区域是否有空位，以及这张卡是否能特殊召唤
function c42542842.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：如果这张卡仍与效果相关联，则将其特殊召唤到自己场上
function c42542842.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制过滤条件：非「魔妖」怪兽的额外卡组怪兽不能被特殊召唤
function c42542842.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x121)
end

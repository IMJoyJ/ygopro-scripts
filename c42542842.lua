--麗の魔妖－妲姫
-- 效果：
-- ①：「丽之魔妖-妲姬」在自己场上只能有1只表侧表示存在。
-- ②：这张卡在墓地存在，「魔妖」怪兽从额外卡组往自己场上特殊召唤时才能发动。这张卡特殊召唤。这个效果发动的回合，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
function c42542842.initial_effect(c)
	c:SetUniqueOnField(1,0,42542842)
	-- 创建一个诱发选发效果，当自己场上「魔妖」怪兽从额外卡组特殊召唤成功时发动，将此卡从墓地特殊召唤
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
	-- 设置一个计数器，用于记录玩家在回合中从额外卡组特殊召唤怪兽的次数
	Duel.AddCustomActivityCounter(42542842,ACTIVITY_SPSUMMON,c42542842.counterfilter)
end
-- 计数器过滤函数，若怪兽不是从额外卡组召唤或为「魔妖」卡，则不计入计数
function c42542842.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x121)
end
-- 条件过滤函数，用于判断是否有「魔妖」怪兽从额外卡组召唤成功
function c42542842.cfilter(c,tp)
	return c:IsSetCard(0x121) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsControler(tp)
end
-- 效果发动条件函数，检查是否有「魔妖」怪兽从额外卡组特殊召唤成功
function c42542842.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c42542842.cfilter,1,nil,tp)
end
-- 效果发动时的费用函数，若本回合未发动过此效果，则设置一个回合结束时重置的不能特殊召唤效果
function c42542842.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否已发动过此效果，若未发动则满足费用条件
	if chk==0 then return Duel.GetCustomActivityCount(42542842,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建一个不能特殊召唤怪兽的效果，仅对额外卡组中非「魔妖」怪兽生效，回合结束时重置
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c42542842.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述效果注册给发动玩家
	Duel.RegisterEffect(e1,tp)
end
-- 设置效果的目标函数，检查是否满足特殊召唤条件
function c42542842.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 设置效果处理信息，表明此效果将特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将此卡特殊召唤到场上
function c42542842.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作，将此卡以正面表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制效果函数，若怪兽在额外卡组且不是「魔妖」卡，则不能特殊召唤
function c42542842.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x121)
end

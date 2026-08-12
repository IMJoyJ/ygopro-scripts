--剣闘獣クラウディウス
-- 效果：
-- 「剑斗兽」怪兽×5
-- 让自己的场上·墓地的上记的卡回到卡组·额外卡组的场合才能从额外卡组特殊召唤。
-- ①：这张卡用上记的方法特殊召唤的场合才能发动。下次的自己战斗阶段可以进行2次。
-- ②：1回合1次，对方把怪兽的效果发动的场合，可以把发动回合的以下效果发动。
-- ●自己回合：从卡组把1只「剑斗兽」怪兽特殊召唤。
-- ●对方回合：从额外卡组把1只11星以下的「剑斗兽」怪兽无视召唤条件特殊召唤。
local s,id,o=GetID()
-- 初始化效果，设置融合召唤条件、接触融合程序并注册特殊召唤限制、战斗阶段两次攻击效果和对方怪兽发动效果时的特殊召唤效果
function s.initial_effect(c)
	-- 添加需要5个满足s.matfilter条件的卡进行融合召唤的程序
	aux.AddFusionProcFunRep(c,s.matfilter,5,true)
	c:EnableReviveLimit()
	-- 添加接触融合程序，要求自己场上或墓地的满足s.cfilter条件的卡送回卡组作为召唤代价
	aux.AddContactFusionProcedure(c,s.cfilter,LOCATION_MZONE+LOCATION_GRAVE,0,aux.ContactFusionSendToDeck(c)):SetValue(SUMMON_VALUE_SELF)
	-- 设置该卡只能从额外卡组特殊召唤的条件，即不能在额外卡组外特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- 当该卡通过上述方法特殊召唤成功时发动的效果：下次自己的战斗阶段可以进行2次攻击
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"2次战阶"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.btcon)
	e1:SetOperation(s.btop)
	c:RegisterEffect(e1)
	-- 对方怪兽发动效果时触发的效果：自己回合从卡组特殊召唤1只剑斗兽怪兽，对方回合从额外卡组特殊召唤1只11星以下的剑斗兽怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 限制该卡不能在额外卡组外特殊召唤
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 融合素材过滤函数，筛选「剑斗兽」怪兽且为怪兽类型
function s.matfilter(c)
	return c:IsFusionSetCard(0x1019) and c:IsFusionType(TYPE_MONSTER)
end
-- 接触融合素材过滤函数，筛选可以送回卡组或额外卡组的怪兽
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
-- 战斗阶段两次攻击效果的发动条件，即该卡是通过指定方式特殊召唤的
function s.btcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 执行战斗阶段两次攻击效果，根据当前回合和阶段设置效果持续时间
function s.btop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置战斗阶段两次攻击效果的具体实现，包括效果类型、目标范围、触发条件和重置方式
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 判断是否在自己的回合且处于战斗阶段开始到战斗阶段结束之间
	if Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) then
		-- 记录当前回合数用于后续判断
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(s.bpcon)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
	end
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断战斗阶段两次攻击效果是否仍然有效，即回合数未改变
function s.bpcon(e)
	-- 返回回合数不等于记录值以确认效果有效
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 对方怪兽发动效果时的触发条件，即对方发动了怪兽效果
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 特殊召唤目标过滤函数，根据当前回合玩家决定召唤方式和限制条件
function s.spfilter(c,e,tp)
	if not c:IsSetCard(0x1019) or not c:IsType(TYPE_MONSTER) then return false end
	-- 判断是否为对方回合
	if Duel.GetTurnPlayer()==1-tp then
		-- 对方回合时召唤条件：11星以下且可无视召唤条件从额外卡组特殊召唤
		return c:IsLevelBelow(11) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 自己回合时召唤条件：可从卡组特殊召唤且有足够怪兽区
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end
-- 设置特殊召唤效果的目标信息，根据当前回合玩家决定从卡组还是额外卡组召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_DECK
	-- 根据当前回合玩家决定召唤来源为卡组或额外卡组
	if Duel.GetTurnPlayer()==1-tp then loc=LOCATION_EXTRA end
	-- 检查是否有满足条件的卡片可以特殊召唤
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只怪兽到指定位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
-- 执行特殊召唤操作，根据召唤来源选择不同的特殊召唤方式
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local loc=LOCATION_DECK
	-- 根据当前回合玩家决定召唤来源为卡组或额外卡组
	if Duel.GetTurnPlayer()==1-tp then loc=LOCATION_EXTRA end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡片作为特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,loc,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		if loc==LOCATION_EXTRA then
			-- 从额外卡组特殊召唤卡片，无视召唤条件
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		else
			-- 从卡组特殊召唤卡片，不无视召唤条件
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
			-- 完成一次特殊召唤操作
			Duel.SpecialSummonComplete()
		end
	end
end

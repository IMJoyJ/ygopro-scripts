--燦幻超龍トランセンド・ドラギオン
-- 效果：
-- 龙族调整＋调整以外的龙族怪兽1只以上
-- 这个卡名的③的效果在决斗中只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。场上的怪兽全部变成攻击表示。
-- ②：只要这张卡在怪兽区域存在，可以攻击的对方怪兽必须作出攻击，对方在战斗阶段中不能把效果发动。
-- ③：3次以上攻击宣言过的自己·对方回合才能发动。这张卡从墓地特殊召唤。那之后，可以把场上1张卡破坏。
function c18969888.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整且为龙族，以及1只以上调整以外的龙族怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),aux.NonTuner(Card.IsRace,RACE_DRAGON),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。场上的怪兽全部变成攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18969888,0))  --"改变形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c18969888.poscon)
	e1:SetTarget(c18969888.postg)
	e1:SetOperation(c18969888.posop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，可以攻击的对方怪兽必须作出攻击，对方在战斗阶段中不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_MUST_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2)
	-- ③：3次以上攻击宣言过的自己·对方回合才能发动。这张卡从墓地特殊召唤。那之后，可以把场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	e3:SetCondition(c18969888.actcon)
	c:RegisterEffect(e3)
	-- 注册一个在战斗阶段中对方不能发动效果的永续效果
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(18969888,2))  --"从墓地特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_BATTLE_START+TIMING_ATTACK+TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,18969888+EFFECT_COUNT_CODE_DUEL)
	e4:SetCondition(c18969888.spcon)
	e4:SetCost(c18969888.spcost)
	e4:SetTarget(c18969888.sptg)
	e4:SetOperation(c18969888.spop)
	c:RegisterEffect(e4)
	if not c18969888.global_check then
		c18969888.global_check=true
		-- 注册一个在攻击宣言时记录攻击次数的连续效果
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c18969888.checkop)
		-- 将连续效果注册到游戏环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 攻击宣言时记录双方的攻击次数
function c18969888.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为当前玩家注册一个在回合结束时重置的标识效果
	Duel.RegisterFlagEffect(tp,18969888,RESET_PHASE+PHASE_END,0,1)
	-- 为对手玩家注册一个在回合结束时重置的标识效果
	Duel.RegisterFlagEffect(1-tp,18969888,RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否为同调召唤 summoned by synchro summon
function c18969888.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置效果目标为场上所有里侧守备表示的怪兽
function c18969888.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在里侧守备表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有里侧守备表示的怪兽
	local sg=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息为改变场上所有里侧守备表示怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
end
-- 执行将场上所有里侧守备表示的怪兽变为表侧攻击表示的操作
function c18969888.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有里侧守备表示的怪兽
	local sg=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		local sc=sg:GetFirst()
		while sc do
			-- 将目标怪兽变为表侧攻击表示
			Duel.ChangePosition(sc,POS_FACEUP_ATTACK)
			sc=sg:GetNext()
		end
	end
end
-- 判断当前阶段是否为战斗阶段
function c18969888.actcon(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 判断当前玩家的攻击次数是否达到3次
function c18969888.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家的攻击次数
	return Duel.GetFlagEffect(tp,18969888)>=3
end
-- 设置效果成本为标记该效果已被使用
function c18969888.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 注册一个提示玩家该效果已被使用的提示效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18969888,4))  --"已经使用过「灿幻超龙 三超戟龙军王」的③的效果"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	-- 将提示效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
end
-- 设置特殊召唤的处理信息
function c18969888.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤并询问是否破坏场上一张卡
function c18969888.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否满足特殊召唤并询问是否破坏场上一张卡的条件
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(18969888,3)) then  --"是否选场上1张卡破坏？"
		-- 选择场上一张卡作为破坏对象
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
		if #g>0 then
			-- 中断当前连锁效果
			Duel.BreakEffect()
			-- 显示选中的卡作为破坏对象的动画效果
			Duel.HintSelection(g)
			-- 将选中的卡以效果原因破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

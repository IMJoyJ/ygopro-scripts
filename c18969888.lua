--燦幻超龍トランセンド・ドラギオン
-- 效果：
-- 龙族调整＋调整以外的龙族怪兽1只以上
-- 这个卡名的③的效果在决斗中只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。场上的怪兽全部变成攻击表示。
-- ②：只要这张卡在怪兽区域存在，可以攻击的对方怪兽必须作出攻击，对方在战斗阶段中不能把效果发动。
-- ③：3次以上攻击宣言过的自己·对方回合才能发动。这张卡从墓地特殊召唤。那之后，可以把场上1张卡破坏。
function c18969888.initial_effect(c)
	-- 为卡片添加同调召唤手续，指定龙族怪兽作为调整素材，以及非调整的龙族怪兽。
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
	-- ②：只要这张卡在怪兽区域存在，可以攻击的对方怪兽必须作出攻击，对方在战斗阶段中不能把效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	e3:SetCondition(c18969888.actcon)
	c:RegisterEffect(e3)
	-- ③：3次以上攻击宣言过的自己·对方回合才能发动。这张卡从墓地特殊召唤。那之后，可以把场上1张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(18969888,2))  --"从墓地特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_ATTACK+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,18969888+EFFECT_COUNT_CODE_DUEL)
	e4:SetCondition(c18969888.spcon)
	e4:SetCost(c18969888.spcost)
	e4:SetTarget(c18969888.sptg)
	e4:SetOperation(c18969888.spop)
	c:RegisterEffect(e4)
	if not c18969888.global_check then
		c18969888.global_check=true
		-- 注册一个全局标识效果，用于记录攻击次数。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c18969888.checkop)
		-- 注册全局标识效果，标记玩家的攻击次数
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查当前回合是否为同调召唤，如果是则执行后续操作。
function c18969888.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的怪兽组，并设置操作信息。
	Duel.RegisterFlagEffect(tp,18969888,RESET_PHASE+PHASE_END,0,1)
	-- 将所有处于守备表示的怪兽变为攻击表示。
	Duel.RegisterFlagEffect(1-tp,18969888,RESET_PHASE+PHASE_END,0,1)
end
-- 判断当前阶段是否在战斗阶段。
function c18969888.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 检查玩家的标志效果值是否大于等于3，以确定是否可以发动特殊召唤效果。
function c18969888.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可用于特殊召唤的卡片和空位
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置操作信息，指定特殊召唤的目标、数量等。
	local sg=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 如果特殊召唤成功且场上有卡，则询问玩家是否要破坏一张卡。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
end
-- 获取所有在场上的卡组
function c18969888.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 中断当前效果链，防止连锁发动。
	local sg=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		local sc=sg:GetFirst()
		while sc do
			-- 为选中的卡片显示动画提示。
			Duel.ChangePosition(sc,POS_FACEUP_ATTACK)
			sc=sg:GetNext()
		end
	end
end
-- 以效果原因破坏选中的卡片。
function c18969888.actcon(e)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 返回玩家的标志效果值是否大于等于3
function c18969888.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有可用于特殊召唤的卡片和空位
	return Duel.GetFlagEffect(tp,18969888)>=3
end
-- 设置操作信息，指定特殊召唤的目标、数量等。
function c18969888.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 如果特殊召唤成功且场上有卡，则询问玩家是否要破坏一张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18969888,4))  --"已经使用过「灿幻超龙 三超戟龙军王」的③的效果"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	-- 中断当前效果链，防止连锁发动。
	Duel.RegisterEffect(e1,tp)
end
-- 为选中的卡片显示动画提示。
function c18969888.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 以效果原因破坏选中的卡片。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 注册全局标识效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 获取场上怪兽数量
function c18969888.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前阶段是否在战斗阶段
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(18969888,3)) then  --"是否选场上1张卡破坏？"
		-- 获取所有在场上的卡组
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
		if #g>0 then
			-- 中断当前效果链，防止连锁发动。
			Duel.BreakEffect()
			-- 为选中的卡片显示动画提示。
			Duel.HintSelection(g)
			-- 以效果原因破坏选中的卡片。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end

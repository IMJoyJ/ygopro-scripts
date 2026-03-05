--エレキハダマグロ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己怪兽给与对方战斗伤害的伤害步骤结束时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡可以直接攻击。
-- ③：这张卡直接攻击给与对方战斗伤害时才能发动。这张卡和除调整以外的自己的手卡·场上（表侧表示）的怪兽1只以上解放，把持有和解放的怪兽的等级合计相同等级的1只「电气」同调怪兽从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果的函数入口
function s.initial_effect(c)
	-- ②：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ①：自己怪兽给与对方战斗伤害的伤害步骤结束时才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 注册全局效果用于记录战斗伤害事件，以便后续效果①使用
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_BATTLE_DAMAGE)
		e3:SetCondition(s.regcon)
		e3:SetOperation(s.regop)
		-- 将效果e3注册为全局环境下的持续效果，监听战斗伤害事件
		Duel.RegisterEffect(e3,0)
	end
	-- ③：这张卡直接攻击给与对方战斗伤害时才能发动。这张卡和除调整以外的自己的手卡·场上（表侧表示）的怪兽1只以上解放，把持有和解放的怪兽的等级合计相同等级的1只「电气」同调怪兽从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.sscon)
	e4:SetTarget(s.sstg)
	e4:SetOperation(s.ssop)
	c:RegisterEffect(e4)
end
-- 判断是否满足①效果的发动条件，即在伤害步骤结束时是否有标记。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家在伤害步骤结束时是否有标记。
	return Duel.GetFlagEffect(tp,id)>0
end
-- 设置①效果的目标，判断是否可以特殊召唤该卡。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有足够的空间进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤该卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行①效果的处理，将该卡特殊召唤到场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认该卡是否还在场上，若在则进行特殊召唤。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 判断是否满足③效果的发动条件，即是否为对方造成的战斗伤害且没有攻击目标。
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=rp
end
-- 注册一个场地区域的持续效果，用于记录战斗伤害发生时的状态。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为对方玩家注册一个标记效果，在伤害步骤结束时重置。
	Duel.RegisterFlagEffect(rp,id,RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 判断是否满足③效果的发动条件，即是否为对方造成的战斗伤害且没有攻击目标。
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方造成的战斗伤害且当前没有攻击目标。
	return ep==1-tp and Duel.GetAttackTarget()==nil
end
-- 过滤函数，用于筛选非调整类的表侧表示怪兽。
function s.mfilter(c)
	return not c:IsType(TYPE_TUNER) and c:IsFaceupEx() and c:GetLevel()>0
end
-- 过滤函数，用于筛选满足同调条件的「电气」同调怪兽。
function s.spfilter(c,e,tp,g)
	return c:IsSetCard(0xe) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and g:CheckSubGroup(s.gcheck,1,#g,tp,e:GetHandler(),c)
end
-- 检查函数，用于判断所选怪兽数量和等级是否满足同调召唤条件。
function s.gcheck(g,tp,ec,sc)
	-- 检查所选怪兽的等级总和是否等于目标同调怪兽的等级。
	return Duel.GetLocationCountFromEx(tp,tp,g+ec,sc)>0 and g:GetSum(Card.GetLevel)+ec:GetLevel()==sc:GetLevel()
end
-- 设置③效果的目标，判断是否可以解放怪兽并特殊召唤同调怪兽。
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取玩家可解放的怪兽组，包括手牌和场上的表侧表示怪兽。
	local g=Duel.GetReleaseGroup(tp,true,REASON_EFFECT):Filter(s.mfilter,c)
	if chk==0 then return c:IsReleasableByEffect() and c:GetLevel()>0
		-- 检查是否存在满足条件的「电气」同调怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	-- 设置连锁操作信息，表示将要解放怪兽。
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,2,0,0)
end
-- 执行③效果的处理，选择要特殊召唤的同调怪兽并解放符合条件的怪兽。
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家可解放的怪兽组，包括手牌和场上的表侧表示怪兽。
	local g=Duel.GetReleaseGroup(tp,true,REASON_EFFECT):Filter(s.mfilter,c)
	if not (c:IsRelateToEffect(e) and c:IsReleasableByEffect()) or #g==0 then return end
	-- 提示玩家选择要特殊召唤的同调怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「电气」同调怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g):GetFirst()
	if tc then
		-- 提示玩家选择要解放的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		local sg=g:SelectSubGroup(tp,s.gcheck,false,1,#g,tp,c,tc)+c
		-- 执行解放并特殊召唤操作。
		if Duel.Release(sg,REASON_EFFECT)>0 then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
	end
end

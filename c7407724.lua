--六花精エリカ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡以外的自己的植物族怪兽进行战斗的攻击宣言时，把手卡·场上的这张卡解放才能发动。那只自己怪兽的攻击力·守备力直到回合结束时上升1000。
-- ②：这张卡在墓地存在的状态，自己场上的植物族怪兽被解放的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c7407724.initial_effect(c)
	-- ①：这张卡以外的自己的植物族怪兽进行战斗的攻击宣言时，把手卡·场上的这张卡解放才能发动。那只自己怪兽的攻击力·守备力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7407724,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetCountLimit(1,7407724)
	e1:SetCondition(c7407724.atkcon)
	e1:SetCost(c7407724.atkcost)
	e1:SetOperation(c7407724.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的植物族怪兽被解放的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7407724,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,7407725)
	e2:SetCondition(c7407724.spcon)
	e2:SetTarget(c7407724.sptg)
	e2:SetOperation(c7407724.spop)
	c:RegisterEffect(e2)
end
-- 判断是否为自己场上除这张卡以外的植物族怪兽进行战斗的攻击宣言，并记录该怪兽
function c7407724.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击怪兽
	local ac=Duel.GetAttacker()
	-- 获取被攻击怪兽
	local bc=Duel.GetAttackTarget()
	if not ac:IsControler(tp) then ac,bc=bc,ac end
	e:SetLabelObject(ac)
	return ac and ac:IsControler(tp) and ac:IsFaceup() and ac:IsRace(RACE_PLANT) and ac~=c
end
-- 检查并执行发动代价：将手卡或场上的这张卡解放
function c7407724.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身作为代价解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果处理：使进行战斗的那只自己怪兽的攻击力·守备力直到回合结束时上升1000
function c7407724.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
		-- 那只自己怪兽的攻击力·守备力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 过滤出原本在场上且属于自己场上的植物族怪兽被解放的卡片
function c7407724.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousRaceOnField()&RACE_PLANT~=0
end
-- 判断是否自己场上的植物族怪兽被解放，且被解放的卡中不包含这张卡自身
function c7407724.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c7407724.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 检查怪兽区域是否有空位，以及这张卡是否能特殊召唤，并设置特殊召唤的操作信息
function c7407724.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家的怪兽区域是否有空余位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤的操作信息，表示该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡守备表示特殊召唤，并添加离场时除外的限制
function c7407724.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 尝试将这张卡以表侧守备表示特殊召唤，并检查是否特殊召唤成功
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1)
		end
	end
end

--久遠の神徒フリムニル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己的手卡·场上3只天使族怪兽解放才能发动。从卡组把1张永续魔法卡在自己场上盖放。这个效果盖放的卡在对方结束阶段送去墓地。
-- ②：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 创建两个效果，①为起动效果，②为诱发效果
function s.initial_effect(c)
	-- ①：把自己的手卡·场上3只天使族怪兽解放才能发动。从卡组把1张永续魔法卡在自己场上盖放。这个效果盖放的卡在对方结束阶段送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sttg)
	e1:SetOperation(s.stop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 筛选可解放的天使族怪兽
function s.filter(c,tp)
	return c:IsReleasable() and c:IsRace(RACE_FAIRY) and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查是否满足解放条件
function s.rcheck(g,tp)
	-- 检查是否满足解放条件
	return Duel.GetSZoneCount(tp,g)>0 and Duel.CheckReleaseGroupEx(tp,Auxiliary.IsInGroup,#g,REASON_COST,true,nil,g)
end
-- 支付解放费用，选择3只天使族怪兽进行解放
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取可解放的卡片组
	local rg=Duel.GetReleaseGroup(tp,true,REASON_COST):Filter(s.filter,nil,tp)
	if chk==0 then return rg:CheckSubGroup(s.rcheck,3,3,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local g=rg:SelectSubGroup(tp,s.rcheck,false,3,3,tp)
	-- 使用代替解放次数
	aux.UseExtraReleaseCount(g,tp)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 筛选永续魔法卡
function s.stfilter(c)
	return c:IsAllTypes(TYPE_CONTINUOUS+TYPE_SPELL) and c:IsSSetable()
end
-- 准备发动效果，检查是否有足够的场地区域和满足条件的永续魔法卡
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的场地区域和满足条件的永续魔法卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 发动效果，选择并盖放一张永续魔法卡，并设置其在对方结束阶段送去墓地的效果
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的场地区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足条件的永续魔法卡
	local g=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 执行盖放操作
		local ct=Duel.SSet(tp,g)
		if ct~=0 then
			local tc=g:GetFirst()
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
			-- 设置在对方结束阶段将盖放的卡送去墓地的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.tgcon)
			e1:SetOperation(s.tgop)
			-- 注册效果
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 判断是否为对方回合且盖放的卡未被移除
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	if Duel.GetTurnPlayer()~=1-tp then return false end
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 将盖放的卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将盖放的卡送去墓地
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
-- 判断此卡是否因效果而送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT+REASON_REDIRECT)
end
-- 准备发动特殊召唤效果，检查是否有足够的怪兽区域和满足条件的卡片
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 发动特殊召唤效果，将此卡特殊召唤到场上，并设置其离开场时被移除的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否可以特殊召唤此卡
	if c:IsRelateToChain() and aux.NecroValleyFilter(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 设置此卡离开场时被移除的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end

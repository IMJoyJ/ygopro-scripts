--夢幻吸収体
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方把手卡·墓地·除外状态的怪兽的效果发动的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果特殊召唤的这张卡在结束阶段破坏。
-- ②：只要这张卡在怪兽区域存在，每次对方把怪兽的效果发动，这张卡的攻击力上升1000。
local s,id,o=GetID()
-- 初始化卡片效果，注册效果①（手卡·墓地特召及结束阶段破坏）和效果②（对方发动怪兽效果时自身攻击力上升）。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：对方把手卡·墓地·除外状态的怪兽的效果发动的场合才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次对方把怪兽的效果发动，
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	-- 每次对方把怪兽的效果发动
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_NEGATED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.regcon)
	e4:SetOperation(s.regop1)
	c:RegisterEffect(e4)
	e4:SetLabelObject(e2)
end
-- 检查触发连锁的玩家是否为对方，且发动的效果是否为手卡、墓地或除外状态的怪兽效果。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中发动效果的卡片所在的位置。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and loc and bit.band(loc,LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED)~=0
end
-- 检查自身是否能特殊召唤，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否可以特殊召唤，以及己方场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表明此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤，并注册一个在结束阶段将这张卡破坏的延迟效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与效果相关、是否受王家长眠之谷影响，并尝试将其以表侧表示特殊召唤。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local fid=e:GetHandler():GetFieldID()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的这张卡在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(c)
		e1:SetCondition(s.descon)
		e1:SetOperation(s.desop)
		-- 将结束阶段破坏的效果作为玩家效果注册到全局环境中。
		Duel.RegisterEffect(e1,tp)
	end
	-- 完成特殊召唤的后续处理。
	Duel.SpecialSummonComplete()
end
-- 检查被特殊召唤的怪兽是否仍带有对应的标记，若标记不符则重置该破坏效果。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 在结束阶段执行破坏操作。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏被特殊召唤的这张卡。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
-- 在对方发动怪兽效果时，给自身注册一个带有当前连锁标记的Flag，用于后续判定攻击力上升。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- 检查对方发动的效果是否为怪兽效果，且自身是否成功注册了对应的Flag（排除发动被无效的情况）。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local v=e:GetLabel()
	e:SetLabel(0)
	local c=e:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and ep~=tp and c:GetFlagEffect(id)~=0 and (not v or v==0 or ev~=v)
end
-- 提示卡片发动，并使这张卡的攻击力上升1000。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上展示该卡片，向玩家提示该卡的效果正在生效。
	Duel.Hint(HINT_CARD,0,id)
	-- 这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(1000)
	e:GetHandler():RegisterEffect(e1)
end
-- 检查被无效的连锁是否为对方发动的怪兽效果。
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and ep~=tp
end
-- 记录被无效的连锁序号，以便在攻击力上升判定中排除该连锁。
function s.regop1(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(ev)
end

--ビック・バイパー T301
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，自己的表侧表示怪兽和对方怪兽进行战斗的攻击宣言时才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：只要这张卡在怪兽区域存在，自己场上的其他的机械族·光属性怪兽的攻击力上升1200。
function c10642488.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，自己的表侧表示怪兽和对方怪兽进行战斗的攻击宣言时才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10642488,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,10642488)
	e1:SetCondition(c10642488.spcon)
	e1:SetTarget(c10642488.sptg)
	e1:SetOperation(c10642488.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的其他的机械族·光属性怪兽的攻击力上升1200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c10642488.atktg)
	e2:SetValue(1200)
	c:RegisterEffect(e2)
end
-- 判定①效果的发动条件：获取攻击怪兽与攻击对象，确认二者存在；若攻击怪兽是对方控制的怪兽，则要求攻击对象是自己表侧表示的怪兽，否则要求攻击怪兽是自己表侧表示的怪兽，从而满足“自己的表侧表示怪兽和对方怪兽进行战斗的攻击宣言”。
function c10642488.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击宣言的怪兽（攻击方）。
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽（攻击对象）。
	local d=Duel.GetAttackTarget()
	if not a or not d then return false end
	if a:IsControler(1-tp) then return d:IsFaceup()
	else return a:IsFaceup() end
end
-- 特殊召唤效果的发动条件和处理信息设定：在发动时确认自己主要怪兽区有空位，且这张卡在手卡·墓地可以被特殊召唤，满足条件后登记特殊召唤的操作信息。
function c10642488.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时（chk==0）检查自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本次连锁将特殊召唤这张卡：对象为这张卡，数量为1，玩家/位置参数为0（表示由效果处理时实际确定），供其他卡检测这次特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与发动时的效果关联，则将其表侧表示特殊召唤到自己主要怪兽区；若召唤成功，给这张卡附加一个不能无效的“离场时改为除外”的效果。
function c10642488.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡仍与效果关联（未被除外/回手等导致关联重置），并尝试以表侧表示特殊召唤到自己场上；若特殊召唤成功则继续执行后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：只要这张卡在怪兽区域存在，自己场上的其他的机械族·光属性怪兽的攻击力上升1200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- ②效果的适用对象过滤器：对在自己场上的、机械族且光属性、且不是这张卡自身的表侧表示怪兽，适用攻击力上升1200的效果。
function c10642488.atktg(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c~=e:GetHandler()
end

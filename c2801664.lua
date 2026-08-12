--戦華の雄－張徳
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己场上有「战华」怪兽2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的攻击力在自己回合内上升对方场上的怪兽数量×300。
-- ③：对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c2801664.initial_effect(c)
	-- ①：自己场上有「战华」怪兽2只以上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2801664,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,2801664)
	e1:SetCondition(c2801664.spcon)
	e1:SetTarget(c2801664.sptg)
	e1:SetOperation(c2801664.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力在自己回合内上升对方场上的怪兽数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c2801664.atkcon)
	e2:SetValue(c2801664.atkval)
	c:RegisterEffect(e2)
	-- ③：对方场上的怪兽数量比自己场上的怪兽多的场合才能发动。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2801664,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,2801665)
	e3:SetCondition(c2801664.xatkcon)
	e3:SetTarget(c2801664.xatktg)
	e3:SetOperation(c2801664.xatkop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在至少2只正面表示的「战华」怪兽。
function c2801664.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- 效果条件函数，检查自己场上是否存在至少2只正面表示的「战华」怪兽。
function c2801664.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的「战华」怪兽组，确保自己场上至少有2只正面表示的「战华」怪兽。
	return Duel.IsExistingMatchingCard(c2801664.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 效果目标函数，检查是否满足特殊召唤的条件。
function c2801664.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，确定特殊召唤的卡为自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将自身从手牌特殊召唤到场上。
function c2801664.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作，将自身以正面表示形式特殊召唤到场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果条件函数，判断是否为自身回合。
function c2801664.atkcon(e)
	-- 判断当前回合玩家是否为自身控制者。
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 效果数值函数，计算攻击力提升值。
function c2801664.atkval(e,c)
	-- 计算自身回合内攻击力提升值，等于对方场上怪兽数量乘以300。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)*300
end
-- 效果条件函数，判断对方场上怪兽数量是否多于己方。
function c2801664.xatkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方场上怪兽数量是否少于对方场上怪兽数量。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
		-- 判断当前是否可以进入战斗阶段。
		and Duel.IsAbleToEnterBP()
end
-- 效果目标函数，检查自身是否已拥有额外攻击效果。
function c2801664.xatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsHasEffect(EFFECT_EXTRA_ATTACK_MONSTER) end
end
-- 效果处理函数，使自身在本回合内可进行最多2次攻击。
function c2801664.xatkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 注册额外攻击效果，使自身在本回合内可进行最多2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	end
end

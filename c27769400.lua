--テュアラティン
-- 效果：
-- 对方的战斗阶段时才能发动。战斗阶段开始时自己场上有怪兽2只以上存在，那些怪兽在同1次的战斗阶段中被战斗全部破坏送去墓地时，这张卡可以从手卡特殊召唤。这个效果特殊召唤成功时，宣言1个属性，场上表侧表示存在的宣言的属性的怪兽全部破坏。那之后，只要这张卡在场上表侧表示存在，对方不能把宣言的属性的怪兽召唤·特殊召唤。
function c27769400.initial_effect(c)
	-- 对方的战斗阶段时才能发动。战斗阶段开始时自己场上有怪兽2只以上存在，那些怪兽在同1次的战斗阶段中被战斗全部破坏送去墓地时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27769400,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+27769400)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c27769400.spcon)
	e1:SetTarget(c27769400.sptg)
	e1:SetOperation(c27769400.spop)
	c:RegisterEffect(e1)
	-- 这个效果特殊召唤成功时，宣言1个属性，场上表侧表示存在的宣言的属性的怪兽全部破坏。那之后，只要这张卡在场上表侧表示存在，对方不能把宣言的属性的怪兽召唤·特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27769400,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c27769400.descon)
	e2:SetOperation(c27769400.desop)
	c:RegisterEffect(e2)
	if not c27769400.global_check then
		c27769400.global_check=true
		c27769400[0]=Group.CreateGroup()
		c27769400[0]:KeepAlive()
		c27769400[1]=0
		-- 战斗阶段开始时，记录当前回合玩家场上的怪兽数量和位置信息。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
		ge1:SetOperation(c27769400.checkop1)
		-- 注册战斗阶段开始时的检查效果，用于检测是否满足特殊召唤条件。
		Duel.RegisterEffect(ge1,0)
		-- 战斗阶段开始时，记录当前回合玩家场上的怪兽数量和位置信息。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_BATTLE_DESTROYED)
		ge2:SetOperation(c27769400.checkop2)
		-- 注册战斗破坏事件的检查效果，用于检测是否满足特殊召唤条件。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 战斗阶段开始时，记录当前回合玩家场上的怪兽数量和位置信息。
function c27769400.checkop1(e,tp,eg,ep,ev,re,r,rp)
	c27769400[0]:Clear()
	-- 获取当前回合玩家场上的所有怪兽并记录到全局变量中。
	c27769400[0]:Merge(Duel.GetFieldGroup(Duel.GetTurnPlayer(),0,LOCATION_MZONE))
	c27769400[1]=c27769400[0]:GetCount()
end
-- 战斗破坏事件发生时，检查是否满足特殊召唤条件。
function c27769400.checkop2(e,tp,eg,ep,ev,re,r,rp)
	if c27769400[1]<2 or c27769400[0]:GetCount()==0 then return end
	local g=eg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	c27769400[0]:Sub(g)
	if c27769400[0]:GetCount()==0 then
		-- 满足条件时触发自定义事件，用于发动特殊召唤效果。
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+27769400,e,0,0,0,0)
	end
end
-- 判断是否为对方的战斗阶段。
function c27769400.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方的战斗阶段。
	return Duel.GetTurnPlayer()~=tp
end
-- 判断是否满足特殊召唤的条件。
function c27769400.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的召唤空间。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作。
function c27769400.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片特殊召唤到场上。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 判断是否为特殊召唤成功的效果。
function c27769400.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤函数，用于筛选场上正面表示且具有指定属性的怪兽。
function c27769400.desfilter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 宣言属性并破坏场上指定属性的怪兽，同时设置不能召唤/特殊召唤的限制。
function c27769400.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要宣言的属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言一个属性。
	local rc=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	-- 获取场上所有正面表示且具有指定属性的怪兽。
	local g=Duel.GetMatchingGroup(c27769400.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,rc)
	-- 将符合条件的怪兽破坏。
	Duel.Destroy(g,REASON_EFFECT)
	if c:IsRelateToEffect(e) then
		c:SetHint(CHINT_ATTRIBUTE,rc)
		-- 设置对方不能召唤或特殊召唤指定属性怪兽的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetTarget(c27769400.sumlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabel(rc)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		c:RegisterEffect(e2)
	end
end
-- 判断目标怪兽是否具有指定属性。
function c27769400.sumlimit(e,c)
	return c:IsAttribute(e:GetLabel())
end

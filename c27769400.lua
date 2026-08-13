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
		-- 战斗阶段开始时自己场上有怪兽2只以上存在
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
		ge1:SetOperation(c27769400.checkop1)
		-- 将战斗阶段开始时监测效果注册到全局，使每次战斗阶段开始时执行checkop1记录当前回合玩家场上的怪兽。
		Duel.RegisterEffect(ge1,0)
		-- 那些怪兽在同1次的战斗阶段中被战斗全部破坏送去墓地时
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_BATTLE_DESTROYED)
		ge2:SetOperation(c27769400.checkop2)
		-- 将战斗破坏监测效果注册到全局，使每次怪兽被战斗破坏时执行checkop2检查是否已全部被战斗破坏。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 战斗阶段开始时，清空之前记录的怪兽组，将当前回合玩家（即对方）场上的全部怪兽加入记录，并保存怪兽数量。
function c27769400.checkop1(e,tp,eg,ep,ev,re,r,rp)
	c27769400[0]:Clear()
	-- 将当前回合玩家场上的全部怪兽并入记录组，作为后续判断是否全部被战斗破坏的依据。
	c27769400[0]:Merge(Duel.GetFieldGroup(Duel.GetTurnPlayer(),0,LOCATION_MZONE))
	c27769400[1]=c27769400[0]:GetCount()
end
-- 战斗破坏发生时，若战斗阶段开始时的怪兽数不少于2且记录组还有卡，则从记录组中剔除本次被战斗破坏并送去墓地的怪兽；若记录组变为空，则触发图拉丁的特殊召唤条件事件。
function c27769400.checkop2(e,tp,eg,ep,ev,re,r,rp)
	if c27769400[1]<2 or c27769400[0]:GetCount()==0 then return end
	local g=eg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	c27769400[0]:Sub(g)
	if c27769400[0]:GetCount()==0 then
		-- 当战斗阶段开始时存在的怪兽全部被战斗破坏时，以图拉丁自身为对象触发自定义事件，诱发其手卡特殊召唤效果。
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+27769400,e,0,0,0,0)
	end
end
-- 特殊召唤效果的发动条件：当前回合玩家不是这张卡的控制者，即限定在对方的战斗阶段。
function c27769400.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否不是这张卡的控制者，以确保是对方回合（对方的战斗阶段）。
	return Duel.GetTurnPlayer()~=tp
end
-- 特殊召唤效果的发动目标条件：自己主要怪兽区有空位，且这张卡能够通过自身效果特殊召唤。
function c27769400.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，标明此效果涉及将图拉丁特殊召唤，供相关卡片的时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果处理：将这张卡以表侧表示特殊召唤到自己场上。
function c27769400.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将图拉丁以表侧表示特殊召唤，召唤类型标记为自身效果（SUMMON_VALUE_SELF），以便后续判断是否为图拉丁自身效果特殊召唤。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 破坏效果的触发条件：这张卡是因为图拉丁自身效果特殊召唤成功时。
function c27769400.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 破坏对象筛选条件：场上表侧表示且属性为宣言属性的怪兽。
function c27769400.desfilter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 效果处理：宣言1个属性，破坏场上该属性的所有表侧表示怪兽；若这张卡仍存在，再给自己附加封印效果，使对方不能召唤/特殊召唤该属性怪兽。
function c27769400.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出提示，要求玩家选择要宣言的属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从所有属性中宣言1个属性，并记录所宣言的属性。
	local rc=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	-- 获取场上所有表侧表示且属性等于宣言属性的怪兽组。
	local g=Duel.GetMatchingGroup(c27769400.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,rc)
	-- 以效果破坏选中的怪兽。
	Duel.Destroy(g,REASON_EFFECT)
	if c:IsRelateToEffect(e) then
		c:SetHint(CHINT_ATTRIBUTE,rc)
		-- 那之后，只要这张卡在场上表侧表示存在，对方不能把宣言的属性的怪兽召唤·特殊召唤。
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
-- 封印效果的判定函数：若怪兽属性为已宣言的属性，则不能进行召唤·特殊召唤。
function c27769400.sumlimit(e,c)
	return c:IsAttribute(e:GetLabel())
end

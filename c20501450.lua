--コンセントレイト
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升那个守备力数值。这张卡发动的回合，作为对象的怪兽以外的自己怪兽不能攻击。
function c20501450.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升那个守备力数值。这张卡发动的回合，作为对象的怪兽以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件为伤害步骤且尚未进行伤害计算时，以保证该卡可在伤害步骤但只能在伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c20501450.cost)
	e1:SetTarget(c20501450.target)
	e1:SetOperation(c20501450.activate)
	c:RegisterEffect(e1)
	if not c20501450.global_check then
		c20501450.global_check=true
		c20501450[0]=0
		c20501450[1]=0
		-- 这张卡发动的回合，作为对象的怪兽以外的自己怪兽不能攻击。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c20501450.checkop)
		-- 将ge1作为全场连续效果注册，在任意玩家攻击宣言时触发checkop，用于记录本回合攻击宣言过的怪兽及次数。
		Duel.RegisterEffect(ge1,0)
		-- 那只怪兽的攻击力直到回合结束时上升那个守备力数值。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c20501450.clear)
		-- 将ge2作为全场连续效果注册，在抽卡阶段开始时将双方本回合攻击宣言计数清零，使计数仅对当前回合有效。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 攻击宣言时，若该怪兽本回合尚未记录过攻击宣言，则给其打上标识，并将对应玩家的攻击宣言计数加1，用于后续判断该怪兽是否已经进行过攻击。
function c20501450.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:GetFlagEffect(20501450)==0 then
		c20501450[ep]=c20501450[ep]+1
		tc:RegisterFlagEffect(20501450,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 在抽卡阶段开始时将玩家1和玩家2的本回合攻击宣言计数重置为0，确保每回合的攻击记录独立。
function c20501450.clear(e,tp,eg,ep,ev,re,r,rp)
	c20501450[0]=0
	c20501450[1]=0
end
-- 发动代价检查：仅当发动者本回合已进行的攻击宣言次数小于2时才可发动（即本回合攻击宣言次数为0或1时允许发动）。
function c20501450.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c20501450[tp]<2 end
end
-- 对象筛选条件：怪兽须为表侧表示且守备力不低于1；若本回合已有攻击宣言（计数不为0），则对象必须已在本回合攻击过（带有标识），否则不能选择。
function c20501450.filter(c,tp)
	return c:IsFaceup() and c:IsDefenseAbove(1) and (c20501450[tp]==0 or c:GetFlagEffect(20501450)~=0)
end
-- 效果目标的设置：选择己方场上1只满足filter的表侧表示怪兽为对象，并同时给己方场上注册一个“对象以外的己方怪兽不能攻击”的誓约效果，持续到回合结束。
function c20501450.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and c20501450.filter(chkc,tp) end
	-- 发动时合法性检查：确认己方场上是否存在至少1只满足filter条件的怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c20501450.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 给玩家弹出“请选择表侧表示的卡”的选择提示信息，用于选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从己方场上选择1只满足filter条件的表侧表示怪兽作为效果对象，并自动与当前连锁建立对象关联。
	local g=Duel.SelectTarget(tp,c20501450.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 这张卡发动的回合，作为对象的怪兽以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c20501450.ftarget)
	e1:SetLabel(g:GetFirst():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将对己方场上所有怪兽生效的禁止攻击效果注册到发动者tp，效果持续到回合结束，令对象以外的己方怪兽本回合不能攻击。
	Duel.RegisterEffect(e1,tp)
end
-- 禁止攻击效果的判定函数：若当前怪兽的FieldID不等于效果记录的对象FieldID，则该怪兽不能攻击，即只允许对象怪兽攻击。
function c20501450.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 效果处理：取回对象怪兽，若其仍表侧且与效果关联，则为其施加攻击力上升效果，上升数值为该怪兽当前守备力，持续到回合结束。
function c20501450.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升那个守备力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetDefense())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

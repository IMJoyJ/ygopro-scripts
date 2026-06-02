--No.39 光の使者 希望皇ホープ
-- 效果：
-- 4星怪兽×2
-- ①：这张卡不会被和「No.」怪兽以外的怪兽的战斗破坏。
-- ②：自己·对方回合，把这张卡1个超量素材取除，以自己场上1只怪兽为对象才能发动。那只怪兽在这个回合只有1次不会被战斗·效果破坏。
-- ③：这个回合的第2次的攻击宣言时才能发动。这张卡攻击力上升2500，得到以下效果。
-- ●这张卡战斗破坏怪兽送去墓地时才能发动。那只怪兽在自己场上特殊召唤。
local s,id,o=GetID()
-- 注册“No.39 光之使者 希望皇 霍普”的卡片效果：注册XYZ召唤手续，不会被「No.」以外怪兽战破的效果①，去除超量素材使己方1只怪兽本回合仅1次不被破坏的效果②，攻击宣言次数全局监测，以及第2次攻击宣言时自身增攻并获得战破特召效果的诱发效果③。
function s.initial_effect(c)
	-- 为卡片添加XYZ召唤手续：需要2只4星怪兽作为超量素材。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡不会被和「No.」怪兽以外的怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.indes)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把这张卡1个超量素材取除，以自己场上1只怪兽为对象才能发动。那只怪兽在这个回合只有1次不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"破坏抗性"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(s.indcost)
	e2:SetTarget(s.indtg)
	e2:SetOperation(s.indop)
	c:RegisterEffect(e2)
	-- ③：这个回合的第2次的攻击宣言时才能发动。这张卡攻击力上升2500，得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		-- ②：自己·对方回合，把这张卡1个超量素材取除，以自己场上1只怪兽为对象才能发动。那只怪兽在这个回合只有1次不会被战斗·效果破坏。/③：这个回合的第2次的攻击宣言时才能发动。这张卡攻击力上升2500，得到以下效果。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(s.checkop)
		-- 将全局效果注册给系统，用于监测每回合的攻击宣言次数。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 设置该超量怪兽的「No.」编号为39。
aux.xyz_number[76504386]=39
-- 攻击宣言时的全局监听回调函数：每次发生攻击宣言时，为双方玩家注册一个持续到回合结束的标识效果以记录宣言次数。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为当前回合玩家注册一个在回合结束时重置的标记效果（表示该回合已进行过攻击宣言）。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	-- 为当前回合的对方玩家注册一个在回合结束时重置的标记效果。
	Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 战破抗性的数值判定函数：排除持有「No.」字段（0x48）的怪兽（即只对「No.」怪兽以外的怪兽生效）。
function s.indes(e,c)
	return not c:IsSetCard(0x48)
end
-- 效果②的发动代价（Cost）：取除这张卡的1个超量素材。
function s.indcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动准备（Target）：选择己方场上1只怪兽作为效果对象。
function s.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsType(TYPE_MONSTER) end
	-- 效果发动判定：检查己方场上是否存在至少1只怪兽可以成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示“选择效果的对象”的系统提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己怪兽区域的1只怪兽作为效果对象，同时将其设置为当前连锁的对象卡。
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的效果处理（Operation）：若对象怪兽仍在场上且与连锁相关，为其注册一个在回合结束前有效的“只有1次不会被战斗·效果破坏”的抗性效果。
function s.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动阶段所选择的需要赋予破坏抗性的己方对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 那只怪兽在这个回合只有1次不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCountLimit(1)
		e1:SetValue(s.valcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 抗性的伤害与效果判定函数：当抗性判定原因为战斗破坏或效果破坏时生效。
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 效果③的发动条件：当前为这个回合的第2次攻击宣言时。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家在全局环境下已注册有1次攻击宣言标识（表明当前是本回合的第2次攻击宣言）。
	return Duel.GetFlagEffect(tp,id)==1
end
-- 效果③的发动准备（Target）：直接返回真以允许效果发动。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 效果③的效果处理（Operation）：若自身仍在场上且表侧表示，则攻击力上升2500；并且如果自身未处于其他反转改变状态，则赋予自身一个在攻击破坏对方怪兽送去墓地时可以发动、将那只怪兽在己方场上特殊召唤的诱发效果。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToChain() then
		-- 这张卡攻击力上升2500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 得到以下效果。●这张卡战斗破坏怪兽送去墓地时才能发动。那只怪兽在自己场上特殊召唤。
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
			e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e2:SetCode(EVENT_BATTLE_DESTROYING)
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
			-- 设置新增效果的发动条件：自身战斗破坏对方怪兽且那只怪兽被送去墓地。
			e2:SetCondition(aux.bdgcon)
			e2:SetTarget(s.sptg)
			e2:SetOperation(s.spop)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e2)
			c:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"已得到效果"
		end
	end
end
-- 新增效果的发动准备（Target）：检查主要怪兽区域是否有空位，以及被战破的怪兽是否在墓地且可特殊召唤；将该被战破的怪兽设为连锁对象，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then
		-- 效果发动判定：检查己方主要怪兽区域是否还有可用的空位。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and bc:IsLocation(LOCATION_GRAVE)
			and bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
	end
	-- 将战斗破坏的对方怪兽设置为当前连锁的对象卡。
	Duel.SetTargetCard(bc)
	-- 设置操作信息：特殊召唤被选为对象的被战破怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 新增效果的效果处理（Operation）：若对象怪兽仍在墓地且不受“王家长眠之谷”影响，将其在己方场上特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象（即被战斗破坏并送去墓地的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查该怪兽是否仍与连锁相关，且在不受“王家长眠之谷”影响的情况下执行后续效果。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将该怪兽以表侧表示特殊召唤到发动者的场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

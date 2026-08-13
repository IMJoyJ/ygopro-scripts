--古代の歯車機械
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合，宣言卡的种类（怪兽·魔法·陷阱）才能发动。这个回合，自己怪兽攻击的场合，对方直到伤害步骤结束时宣言的种类的卡不能发动。
-- ②：1回合1次，宣言1个「零件」怪兽的卡名才能发动。直到结束阶段，这张卡当作和宣言的卡同名卡使用。
function c18486927.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，宣言卡的种类（怪兽·魔法·陷阱）才能发动。这个回合，自己怪兽攻击的场合，对方直到伤害步骤结束时宣言的种类的卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c18486927.dectg)
	e1:SetOperation(c18486927.decop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，宣言1个「零件」怪兽的卡名才能发动。直到结束阶段，这张卡当作和宣言的卡同名卡使用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18486927,0))  --"宣言怪兽卡名"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c18486927.nametg)
	e3:SetOperation(c18486927.nameop)
	c:RegisterEffect(e3)
end
-- 效果发动时的处理：确认发动合法后，提示玩家宣言卡片种类，并将宣言结果存入效果标签，供后续处理使用。
function c18486927.dectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 显示“请选择一个种类”的提示消息，引导玩家进行卡片种类宣言。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家宣言怪兽/魔法/陷阱中的一种，并把宣言结果保存到效果的Label字段中。
	e:SetLabel(Duel.AnnounceType(tp))
end
-- 效果处理时读取宣言的种类并转换为对应的卡片类型，然后给该回合生成一个永续效果：当自己怪兽攻击时，对方不能发动宣言种类的卡，持续到结束阶段。
function c18486927.decop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=e:GetLabel()
	local ct=nil
	if opt==0 then
		ct=TYPE_MONSTER
	elseif opt==1 then
		ct=TYPE_SPELL
	else
		ct=TYPE_TRAP
	end
	-- 这个回合，自己怪兽攻击的场合，对方直到伤害步骤结束时宣言的种类的卡不能发动。直到结束阶段，这张卡当作和宣言的卡同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetLabel(ct)
	e1:SetCondition(c18486927.actcon)
	e1:SetValue(c18486927.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将生成的“对方不能发动宣言种类卡”效果注册到当前操作中，使其在该回合内对对方玩家生效。
	Duel.RegisterEffect(e1,tp)
end
-- 作为禁发效果的Value判定：当对方发动的效果卡的卡片类型与宣言种类一致时（魔法·陷阱仅限制卡的发动，怪兽效果则包含怪兽效果发动），返回真以禁止其发动。
function c18486927.actlimit(e,re,tp)
	local ct=e:GetLabel()
	return re:IsActiveType(ct) and (ct==TYPE_MONSTER or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 作为禁发效果的Condition条件：仅在己方怪兽正在进行攻击时返回真，确保“自己怪兽攻击的场合”这一限制条件成立。
function c18486927.actcon(e)
	-- 获取当前正在攻击的怪兽卡，用于判断是否为己方怪兽的攻击。
	local tc=Duel.GetAttacker()
	local tp=e:GetHandlerPlayer()
	return tc and tc:IsControler(tp)
end
-- 效果发动时的处理：无条件可发动；构造只允许宣言“零件”字段的怪兽且不能宣言本卡名的过滤条件，让玩家宣言一个卡名，并将宣言卡号存入连锁参数，同时记录操作信息为宣言卡名。
function c18486927.nametg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local code=c:GetCode()
	getmetatable(c).announce_filter={0x51,OPCODE_ISSETCARD,TYPE_MONSTER,OPCODE_ISTYPE,OPCODE_AND,code,OPCODE_ISCODE,OPCODE_NOT,OPCODE_AND}
	-- 按过滤条件让玩家宣言一张「零件」怪兽，返回宣言的卡号。
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(c).announce_filter))
	-- 将宣言的卡号作为对象参数写入当前连锁，供效果处理阶段读取。
	Duel.SetTargetParam(ac)
	-- 设置当前连锁的操作信息为CATEGORY_ANNOUNCE，表示本次效果包含宣言卡名操作。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果处理时取出宣言的卡号；若本卡仍与效果相关且表侧表示，则给它赋予卡名变为宣言卡号的效果，持续到结束阶段。
function c18486927.nameop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取发动时保存的宣言卡号参数。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 直到结束阶段，这张卡当作和宣言的卡同名卡使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(ac)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

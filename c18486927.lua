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
-- 选择并记录玩家宣言的卡片类型（怪兽·魔法·陷阱）
function c18486927.dectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家提示“请选择一个种类”以进行卡片类型宣言
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 记录玩家通过宣言类型函数选择的卡片类型
	e:SetLabel(Duel.AnnounceType(tp))
end
-- 创建一个影响对方玩家的永续效果，使对方不能发动与宣言类型相同的卡片
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
	-- 创建一个用于限制对方发动卡片的效果，该效果在对方场上生效
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
	-- 将上述效果注册到游戏环境，使其生效
	Duel.RegisterEffect(e1,tp)
end
-- 判断对方发动的卡片是否为宣言的类型，若为怪兽或永续魔法/陷阱则禁止发动
function c18486927.actlimit(e,re,tp)
	local ct=e:GetLabel()
	return re:IsActiveType(ct) and (ct==TYPE_MONSTER or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 判断是否为己方怪兽攻击时触发的条件
function c18486927.actcon(e)
	-- 获取当前正在攻击的怪兽
	local tc=Duel.GetAttacker()
	local tp=e:GetHandlerPlayer()
	return tc and tc:IsControler(tp)
end
-- ②：1回合1次，宣言1个「零件」怪兽的卡名才能发动。直到结束阶段，这张卡当作和宣言的卡同名卡使用。
function c18486927.nametg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local code=c:GetCode()
	getmetatable(c).announce_filter={0x51,OPCODE_ISSETCARD,TYPE_MONSTER,OPCODE_ISTYPE,OPCODE_AND,code,OPCODE_ISCODE,OPCODE_NOT,OPCODE_AND}
	-- 让玩家宣言一个「零件」怪兽的卡号
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(c).announce_filter))
	-- 将宣言的卡号设置为连锁处理的目标参数
	Duel.SetTargetParam(ac)
	-- 设置操作信息，用于提示玩家发动了宣言卡名的效果
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 将当前卡的卡号更改为玩家宣言的卡号
function c18486927.nameop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中设置的目标参数（即宣言的卡号）
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 创建一个使当前卡变为宣言卡号的永续效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(ac)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

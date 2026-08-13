--ヘクサ・トルーデ
-- 效果：
-- ①：场地区域有「急流山的金宫」存在的场合，这张卡可以不用解放作召唤。
-- ②：1回合1次，场地区域有「急流山的金宫」存在的场合，以场上1张卡为对象才能发动。那张卡破坏，这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ③：这张卡战斗破坏对方怪兽时，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升400。
function c46294982.initial_effect(c)
	-- 记录这张卡上记载着「急流山的金宫」（卡号72283691），使相关判定能识别此卡名信息。
	aux.AddCodeList(c,72283691)
	-- ①：场地区域有「急流山的金宫」存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46294982,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c46294982.ntcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，场地区域有「急流山的金宫」存在的场合，以场上1张卡为对象才能发动。那张卡破坏，这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46294982,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c46294982.descon)
	e2:SetTarget(c46294982.destg)
	e2:SetOperation(c46294982.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡战斗破坏对方怪兽时，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升400。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46294982,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置③效果的发动条件：本卡在与对方怪兽的战斗中将其破坏（由aux.bdocon判定与战斗相关且攻击对象为对方怪兽）。
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c46294982.atktg)
	e3:SetOperation(c46294982.atkop)
	c:RegisterEffect(e3)
end
-- ①效果（无需解放召唤）的召唤规则条件函数：无卡时返回true供规则查询；否则须满足无解放、等级5以上、场地区有金宫且自己怪兽区有空位。
function c46294982.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定无解放召唤条件的前半部分：minc==0（不需要解放）、此卡等级不低于5、且当前场地区域存在「急流山的金宫」（任一方有效均可）。
	return minc==0 and c:IsLevelAbove(5) and Duel.IsEnvironment(72283691,PLAYER_ALL,LOCATION_FZONE)
		-- 并且自己的主要怪兽区还有空位，才能执行这次无需解放的召唤。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- ②效果的发动条件函数：只检查当前场地区域是否有「急流山的金宫」，有即可发动。
function c46294982.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前场地区域（任一玩家的场地区）是否有「急流山的金宫」并生效。
	return Duel.IsEnvironment(72283691,PLAYER_ALL,LOCATION_FZONE)
end
-- ②效果的取对象目标函数：从双方场上选择1张卡（不能选自身）作为破坏对象；存在可选目标时进行选择并设置破坏操作信息。
function c46294982.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	local c=e:GetHandler()
	-- 在效果发动合法性检查（chk==0）时，确认场上存在至少1张除自身以外的卡可以作为破坏对象。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 给操作者发送选择提示，UI显示“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作者从双方场上选择1张卡（排除自身）作为对象，并设置为连锁对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置本次连锁的操作信息：将对象组g作为破坏目标，数量为1，用于后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：若对象卡仍关联且被成功破坏、本卡也仍在场上，则给本卡附加本回合可在同一次战斗阶段中额外攻击1次的效果（即可攻击2次）。
function c46294982.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断并执行：对象卡仍与效果关联且被效果破坏成功，同时本卡仍与效果关联时，才进行后续额外攻击效果赋予。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- ③效果的取对象目标函数：从自己场上选择1只表侧表示怪兽作为对象；存在可选目标时进行选择。
function c46294982.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 在效果发动合法性检查（chk==0）时，确认自己场上存在至少1只表侧表示怪兽可选作对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 给操作者发送选择提示，UI显示“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作者从自己场上的表侧表示怪兽中选择1只作为对象，并设置为连锁对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ③效果处理：若对象怪兽仍表侧表示且与效果关联，则给对象怪兽附加攻击力上升400的效果。
function c46294982.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力上升400。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

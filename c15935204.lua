--ストーム・サモナー
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，可以让这张卡以外的念动力族怪兽战斗破坏的对方怪兽不送去墓地，在对方卡组最上面放置。这张卡被卡的效果破坏时，这张卡的控制者受到这张卡的攻击力数值的伤害。
function c15935204.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，可以让这张卡以外的念动力族怪兽战斗破坏的对方怪兽不送去墓地，在对方卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SEND_REPLACE)
	e1:SetTarget(c15935204.reptg)
	-- 将EFFECT_SEND_REPLACE的Value设置为aux.FALSE（恒为假），使该替换效果本身不直接提供新的卡片去向；实际改送去卡组的操作由reptg中为对象怪兽注册的离场重定向效果完成。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡被卡的效果破坏时，这张卡的控制者受到这张卡的攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15935204,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c15935204.dmcon)
	e2:SetTarget(c15935204.dmtg)
	e2:SetOperation(c15935204.dmop)
	c:RegisterEffect(e2)
end
-- 筛选符合条件的战斗破坏的对方怪兽：该怪兽处于战斗破坏确定状态、不是衍生物、控制者为对方、是被念动力族怪兽战斗破坏且该念动力族怪兽不是风暴召唤师自身、尚未被其他效果指定离场去向且原本不是送去卡组（即原本会送去墓地）。
function c15935204.repfilter(c,e,tp)
	return c:IsStatus(STATUS_BATTLE_DESTROYED) and not c:IsType(TYPE_TOKEN)
		and c:IsControler(1-tp) and c:IsReason(REASON_BATTLE) and c:GetReasonCard():IsRace(RACE_PSYCHO) and c:GetReasonCard()~=e:GetHandler()
		and c:GetLeaveFieldDest()==0 and c:GetDestination()~=LOCATION_DECK
end
-- 处理第一个效果的置换判定：当场上出现被战斗破坏的对方怪兽且满足repfilter时，先确认条件成立；随后询问玩家是否发动，若发动则从符合条件的怪兽中选择一只，为其注册离场时改送去卡组的效果，并返回true使置换生效。
function c15935204.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return r&REASON_BATTLE~=0 and eg:IsExists(c15935204.repfilter,1,nil,e,tp) end
	-- 弹出YES/NO选择框，询问当前玩家是否使用“风暴召唤师”的效果，将该怪兽不送去墓地而放到对方卡组顶。
	if Duel.SelectYesNo(tp,aux.Stringid(15935204,1)) then  --"是否要使用「风暴召唤师」的效果？"
		local tc=eg:Filter(c15935204.repfilter,nil,e,tp):GetFirst()
		-- 不送去墓地，在对方卡组最上面放置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetCondition(c15935204.recon)
		e1:SetValue(LOCATION_DECK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		return true
	else return false end
end
-- 离场重定向效果的条件：目标怪兽当前预定要去的场所是墓地、且破坏原因为战斗破坏时，才将其去向改为卡组。
function c15935204.recon(e)
	local c=e:GetHandler()
	return c:GetDestination()==LOCATION_GRAVE and c:IsReason(REASON_BATTLE)
end
-- 第二个效果的发动条件：这张卡被破坏时不是战斗破坏，即对应效果原文中“被卡的效果破坏时”的条件。
function c15935204.dmcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_BATTLE)
end
-- 伤害效果的目标处理：无取对象要求，直接通过；随后将目标玩家设为这张卡破坏前的控制者，目标参数设为这张卡的攻击力，并登记本次连锁的伤害操作信息。
function c15935204.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 将本次连锁的伤害对象玩家设置为这张卡在被破坏前的控制者（即效果原文中的“这张卡的控制者”）。
	Duel.SetTargetPlayer(c:GetPreviousControler())
	-- 将伤害数值设置为这张卡的攻击力值，作为后续造成伤害时使用的参数。
	Duel.SetTargetParam(c:GetAttack())
	-- 向系统登记本次连锁将产生伤害（CATEGORY_DAMAGE），目标玩家为原控制者，预计伤害值为这张卡的攻击力，以便其他卡进行发动时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,c:GetPreviousControler(),c:GetAttack())
end
-- 伤害效果的解决操作：从当前连锁信息中取出之前登记的目标玩家和伤害值，并对其造成相应数值的效果伤害。
function c15935204.dmop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取登记的目标玩家和伤害参数，分别赋值给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害（REASON_EFFECT）的方式给予玩家p数额为d的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end

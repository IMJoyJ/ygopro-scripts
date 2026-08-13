--亡龍の旋律
-- 效果：
-- 宣言1个卡名才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，每次宣言的卡的效果发动，把那个效果发动的卡的原本持有者的基本分变成一半。这个效果适用的回合的结束阶段这张卡送去墓地。
-- ②：对方场上有怪兽存在的场合，这张卡不会被效果破坏。
function c40971261.initial_effect(c)
	-- 宣言1个卡名才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c40971261.target)
	e1:SetOperation(c40971261.activate)
	c:RegisterEffect(e1)
	-- 每次宣言的卡的效果发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetLabelObject(e1)
	e2:SetOperation(c40971261.regop)
	c:RegisterEffect(e2)
	-- 把那个效果发动的卡的原本持有者的基本分变成一半。这个效果适用的回合的结束阶段这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetLabelObject(e2)
	e3:SetCondition(c40971261.lpcon)
	e3:SetOperation(c40971261.lpop)
	c:RegisterEffect(e3)
	-- ②：对方场上有怪兽存在的场合，这张卡不会被效果破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c40971261.indcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 效果发动时的宣言处理：允许发动，让玩家宣言1个卡名，将宣言的卡号存入连锁参数，并设置卡名宣言类操作信息。
function c40971261.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向玩家tp发送“请宣言一个卡名”的选择提示，为后续的卡名宣言做准备。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让玩家tp宣言1个卡名，并返回所宣言的卡号。
	local ac=Duel.AnnounceCard(tp)
	-- 将宣言的卡号保存为当前连锁的目标参数，供之后效果处理时获取。
	Duel.SetTargetParam(ac)
	-- 设置当前连锁的操作信息，标记为卡名宣言类别（CATEGORY_ANNOUNCE），便于系统识别。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 激活处理：从连锁参数中取出宣言的卡号，存入效果标签，并在这张卡上附加所宣言卡片的提示。
function c40971261.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的宣言卡号。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	e:SetLabel(ac)
	e:GetHandler():SetHint(CHINT_CARD,ac)
end
-- 监听连锁中效果发动：若发动效果的卡与宣言的卡名一致，则给本卡注册标记，并记录该效果发动卡的原本持有者。
function c40971261.regop(e,tp,eg,ep,ev,re,r,rp)
	if eg:GetFirst():IsCode(e:GetLabelObject():GetLabel()) then
		e:GetHandler():RegisterFlagEffect(40971261,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
		e:SetLabel(eg:GetFirst():GetOwner())
	end
end
-- 作为连锁处理结束时的条件：确认本卡已有“宣言的卡效果发动”的标记，且当前连锁解决的效果正是宣言的卡的效果。
function c40971261.lpcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(40971261)~=0 and re:GetHandler():IsCode(e:GetLabelObject():GetLabelObject():GetLabel())
end
-- 实际处理：将宣言的效果发动卡的原本持有者的基本分减半；若本回合尚未设置结束阶段送墓处理，则注册一个结束阶段将这张卡送去墓地的效果。
function c40971261.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=e:GetLabelObject():GetLabel()
	-- 向全场玩家显示亡龙之旋律的卡片动画/提示，表示其①效果正在适用。
	Duel.Hint(HINT_CARD,0,40971261)
	-- 将玩家p的LP设置为其当前LP的一半并向上取整，即把基本分减半，p为宣言效果发动卡的原本持有者。
	Duel.SetLP(p,math.ceil(Duel.GetLP(p)/2))
	if c:GetFlagEffect(40971262)==0 then
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(40971262,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个效果适用的回合的结束阶段这张卡送去墓地。②：对方场上有怪兽存在的场合，这张卡不会被效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetCondition(c40971261.tgcon)
		e1:SetOperation(c40971261.tgop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将新建的结束阶段送墓地效果注册到tp方的场上环境，使它在结束阶段时按条件触发。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 确认亡龙之旋律身上的“结束阶段送墓地”标记值与当前效果保存的标识一致，确保只对本次适用的效果进行处理。
function c40971261.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffectLabel(40971262)==e:GetLabel()
end
-- 执行①效果中的结束阶段送墓地：将这张卡送去墓地。
function c40971261.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 将亡龙之旋律这张卡以效果原因送入墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
-- ②效果抗性条件：检查对方场上的怪兽区是否存在怪兽。
function c40971261.indcon(e)
	-- 若对方场上的怪兽数量大于0则返回真，即对方场上有怪兽存在时抗性适用。
	return Duel.GetFieldGroupCount(e:GetOwnerPlayer(),0,LOCATION_MZONE)>0
end

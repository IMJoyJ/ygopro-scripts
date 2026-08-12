--セイヴァー・アブソープション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以以自己场上1只「星尘龙」或者有那个卡名记述的同调怪兽为对象，从以下效果选择1个发动。
-- ●选对方场上1只表侧表示怪兽，那只怪兽当作装备卡使用给作为对象的自己怪兽装备。
-- ●这个回合，作为对象的怪兽可以直接攻击。
-- ●这个回合，每次作为对象的怪兽战斗破坏对方怪兽，给与对方那只破坏的怪兽的原本攻击力数值的伤害。
function c63144961.initial_effect(c)
	-- 在卡片中注册「星尘龙」的卡名，用于后续检测。
	aux.AddCodeList(c,44508094)
	-- 这个卡名的卡在1回合只能发动1张。①：可以以自己场上1只「星尘龙」或者有那个卡名记述的同调怪兽为对象，从以下效果选择1个发动。●选对方场上1只表侧表示怪兽，那只怪兽当作装备卡使用给作为对象的自己怪兽装备。●这个回合，作为对象的怪兽可以直接攻击。●这个回合，每次作为对象的怪兽战斗破坏对方怪兽，给与对方那只破坏的怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,63144961+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c63144961.target)
	e1:SetOperation(c63144961.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「星尘龙」或者记载了「星尘龙」卡名的同调怪兽。
function c63144961.filter(c)
	-- 判断卡片是否为表侧表示的「星尘龙」或记载了「星尘龙」卡名的同调怪兽。
	return c:IsFaceup() and (c:IsCode(44508094) or c:IsType(TYPE_SYNCHRO) and aux.IsCodeListed(c,44508094))
end
-- 过滤对方场上可以改变控制权的表侧表示怪兽（用于装备效果）。
function c63144961.eqfilter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 过滤自己场上符合条件且未获得直接攻击效果的怪兽。
function c63144961.dafilter(c)
	return c63144961.filter(c) and not c:IsHasEffect(EFFECT_DIRECT_ATTACK)
end
-- 效果发动时的目标选择与可行性检查。
function c63144961.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c63144961.filter(chkc) end
	-- 检查自己魔陷区是否有空位。
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在可以作为装备卡的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c63144961.eqfilter,tp,0,LOCATION_MZONE,1,nil)
	-- 检查当前是否处于可以进行战斗相关操作的时点或阶段（用于直接攻击效果）。
	local b2=aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
		-- 检查自己场上是否存在可以作为对象且未获得直接攻击效果的怪兽。
		and Duel.IsExistingTarget(c63144961.dafilter,tp,LOCATION_MZONE,0,1,nil)
	-- 检查当前是否处于可以进行战斗相关操作的时点或阶段（用于战破伤害效果）。
	local b3=aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
	if chk==0 then return (b1 or b2 or b3)
		-- 检查自己场上是否存在符合条件的怪兽作为效果对象。
		and Duel.IsExistingTarget(c63144961.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「星尘龙」或记载了「星尘龙」卡名的同调怪兽作为对象。
	local g=Duel.SelectTarget(tp,c63144961.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 重新判断所选对象是否可以适用直接攻击效果。
	b2=aux.bpcon(e,tp,eg,ep,ev,re,r,rp) and not g:GetFirst():IsHasEffect(EFFECT_DIRECT_ATTACK)
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(63144961,0)  --"装备对方怪兽"
		opval[off-1]=0
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(63144961,1)  --"可以直接攻击"
		opval[off-1]=1
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(63144961,2)  --"战斗破坏时给与伤害"
		opval[off-1]=2
		off=off+1
	end
	-- 提示玩家选择要发动的效果。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	-- 让玩家从可用的选项中选择一个效果发动。
	local sel=Duel.SelectOption(tp,table.unpack(ops))
	local op=opval[sel]
	e:SetLabel(op)
end
-- 效果处理的执行函数。
function c63144961.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local op=e:GetLabel()
	if op==0 then
		-- 检查自己魔陷区是否有空位。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			-- 提示玩家选择要装备的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 让玩家选择对方场上1只表侧表示怪兽。
			local g=Duel.SelectMatchingCard(tp,c63144961.eqfilter,tp,0,LOCATION_MZONE,1,1,nil)
			local ec=g:GetFirst()
			if ec then
				-- 将选择的对方怪兽作为装备卡装备给作为对象的自己怪兽，若装备失败则结束处理。
				if not Duel.Equip(tp,ec,tc) then return end
				-- ●选对方场上1只表侧表示怪兽，那只怪兽当作装备卡使用给作为对象的自己怪兽装备。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetLabelObject(tc)
				e1:SetValue(c63144961.eqlimit)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				ec:RegisterEffect(e1)
			end
		end
	elseif op==1 then
		-- ●这个回合，作为对象的怪兽可以直接攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	else
		tc:RegisterFlagEffect(63144961,RESET_EVENT+RESETS_STANDARD,0,1,tc:GetFieldID())
		-- ●这个回合，每次作为对象的怪兽战斗破坏对方怪兽，给与对方那只破坏的怪兽的原本攻击力数值的伤害。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCondition(c63144961.damcon)
		e1:SetOperation(c63144961.damop)
		-- 在全局环境注册该回合内生效的战斗破坏给与伤害的事件监听效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制装备卡只能装备给作为对象的怪兽。
function c63144961.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 检查是否为作为对象的怪兽在战斗中破坏了对方怪兽并送去墓地。
function c63144961.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local fid=tc:GetFlagEffectLabel(63144961)
	local bc=tc:GetBattleTarget()
	return fid and fid==tc:GetFieldID() and tc==eg:GetFirst() and tc:IsRelateToBattle() and bc and bc:GetPreviousControler()==1-tp
end
-- 给与对方被破坏怪兽的原本攻击力数值的伤害。
function c63144961.damop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local bc=tc:GetBattleTarget()
	if not bc then return end
	local dam=bc:GetBaseAttack()
	if dam>0 then
		-- 在决斗界面展示卡片发动动画以提示效果触发。
		Duel.Hint(HINT_CARD,0,63144961)
		-- 给与对方被破坏怪兽的原本攻击力数值的效果伤害。
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end

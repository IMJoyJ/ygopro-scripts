--死の罪宝－ルシエラ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只7星以上的魔法师族怪兽为对象才能发动。以下效果各适用。
-- ●作为对象的表侧表示怪兽在这个回合不受其他怪兽的效果影响，下个回合的准备阶段送去墓地。
-- ●对方场上的全部怪兽的攻击力下降作为对象的怪兽的攻击力数值。这个效果让攻击力变成0的场合，再把那怪兽破坏。
local s,id,o=GetID()
-- 为「死之罪宝-濡血蝠」创建并注册①效果的发动效果：设置效果说明、类别（攻击力变化）、类型（魔法卡发动）、自由时点发动、取对象+伤害步骤可发动属性、伤害步骤时点提示、1回合1次同名卡誓约限制、发动条件（伤害步骤限制）、目标选择函数和处理函数。
function s.initial_effect(c)
	-- 对应效果原文：‘这个卡名的卡在1回合只能发动1张。①：以自己场上1只7星以上的魔法师族怪兽为对象才能发动。以下效果各适用。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	-- 设置发动条件为aux.dscon：只能在非伤害步骤或伤害计算前发动，防止在伤害计算后发动该卡。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义取对象目标筛选条件：表侧表示且7星以上且魔法师族怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_SPELLCASTER)
end
-- 目标选择函数：处理连锁对象合法性检查；若为发动判定则检查是否存在符合条件的目标；然后提示玩家选择表侧表示的怪兽，并选择1只作为对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 发动时点确认（chk==0）：检查自己场上是否至少存在1只满足s.filter的怪兽，以此决定效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示选择提示，提示内容为‘请选择表侧表示的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只满足s.filter的表侧表示怪兽，并将其登记为这张卡发动时的效果对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义对方怪兽筛选条件：对方场上的表侧表示且攻击力不为0的怪兽（用于被降低攻击力）。
function s.dfilter(c)
	-- 判定条件是表侧表示且攻击力不为0（复用aux.nzatk）。
	return c:IsFaceup() and aux.nzatk(c)
end
-- 效果处理：先给对象附加‘本回合不受其他怪兽效果影响’并在下个准备阶段送墓；再使对方场上全部表侧且攻击力大于0的怪兽攻击力下降对象攻击力数值，并把因下降而变为0的怪兽破坏；两段处理用Duel.BreakEffect分开。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的作为对象的自己场上7星以上魔法师族怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local chk
	if tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 对应效果原文：‘作为对象的表侧表示怪兽在这个回合不受其他怪兽的效果影响’的部分：为对象附加不受该效果来源以外怪兽效果影响的免疫效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(s.efilter)
		tc:RegisterEffect(e1)
		-- 对应效果原文：‘下个回合的准备阶段送去墓地’的部分：为对象注册一个持续效果，在准备阶段满足条件时将其送去墓地。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCountLimit(1)
		-- 把当前回合数存入e2的标签中，作为判断‘下个回合’的时间基准。
		e2:SetLabel(Duel.GetTurnCount())
		e2:SetCondition(s.tgcon)
		e2:SetOperation(s.tgop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
		tc:RegisterEffect(e2)
		chk=true
	end
	-- 获取对方场上的全部表侧表示且攻击力不为0的怪兽，作为攻击力下降的对象集合。
	local g=Duel.GetMatchingGroup(s.dfilter,tp,0,LOCATION_MZONE,nil)
	if tc:IsFaceup() and #g>0 then
		-- 若第一段处理（免疫+送墓效果）已适用，则用Duel.BreakEffect中断连锁，使后续攻击力变化成为另一个时点处理。
		if chk then Duel.BreakEffect() end
		local atkd=tc:GetAttack()
		local dg=Group.CreateGroup()
		-- 遍历攻击力下降对象组g中的每只怪兽sc，依次进行处理。
		for sc in aux.Next(g) do
			local patk=sc:GetAttack()
			-- 对应效果原文：‘对方场上的全部怪兽的攻击力下降作为对象的怪兽的攻击力数值’的部分：使每只怪兽的攻击力下降对象怪兽的攻击力数值（down -atkd）。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-atkd)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
			if patk~=0 and sc:IsAttack(0) then dg:AddCard(sc) end
		end
		if #dg>0 then
			-- 再次中断效果处理，使攻击力变化与之后的破坏处理分开处理，避免错过时点/合并处理。
			Duel.BreakEffect()
			-- 将因攻击力变为0的怪兽以效果原因破坏。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
-- 定义免疫过滤函数：如果试图对对象适用的效果来自其他怪兽（效果拥有者不是对象自身），则使其免疫。
function s.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetHandler()
end
-- 定义送墓效果的触发条件：当前回合数与记录回合数不同，即已不是发动当回合，从而在准备阶段准备触发。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合数不等于记录回合数，表示已经进入下一个回合，触发条件成立。
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 送墓处理函数：先重置自己防止重复，然后确认当前是‘下个回合’（记录回合数+1）才展示卡片并把对象送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	e:Reset()
	-- 若当前回合数不是记录回合数+1，则退出；只有到达下个回合才执行送墓。
	if Duel.GetTurnCount()~=e:GetLabel()+1 then return end
	-- 向双方展示‘死之罪宝-濡血蝠’的卡片动画，提示送墓效果由该卡诱发。
	Duel.Hint(HINT_CARD,0,id)
	-- 将效果对象（之前选择的那只怪兽，效果处理者）以效果原因送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end

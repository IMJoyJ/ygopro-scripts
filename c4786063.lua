--超重武者装留ファイヤー・アーマー
-- 效果：
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。装备怪兽的等级变成5星。
-- ②：把这张卡从手卡丢弃，以自己场上1只守备表示的「超重武者」怪兽为对象才能发动。直到回合结束时，那只怪兽的守备力下降800，不会被战斗·效果破坏。这个效果在对方回合也能发动。
function c4786063.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4786063,0))  --"装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c4786063.eqtg)
	e1:SetOperation(c4786063.eqop)
	c:RegisterEffect(e1)
	-- 装备怪兽的等级变成5星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetValue(5)
	c:RegisterEffect(e2)
	-- ②：把这张卡从手卡丢弃，以自己场上1只守备表示的「超重武者」怪兽为对象才能发动。直到回合结束时，那只怪兽的守备力下降800，不会被战斗·效果破坏。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4786063,1))  --"破坏耐性"
	e3:SetCategory(CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetRange(LOCATION_HAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置效果发动条件为伤害步骤限定：当前阶段不是伤害步骤，或尚未进行伤害计算时才能发动，从而允许该2速效果在伤害步骤中发动但禁止在伤害计算后发动。
	e3:SetCondition(aux.dscon)
	e3:SetCost(c4786063.cost)
	e3:SetTarget(c4786063.target)
	e3:SetOperation(c4786063.operation)
	c:RegisterEffect(e3)
end
-- 装备对象过滤条件：对象必须为表侧表示且属于「超重武者」系列（0x9a）。
function c4786063.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- ①效果的取对象处理：发动时验证我方魔陷区有空位、且我方主要怪兽区存在表侧表示的超重武者怪兽（不含本卡）可作为对象；连锁处理时再次验证对象位置、控制者及过滤条件。
function c4786063.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c4786063.eqfilter(chkc) end
	-- 发动合法性检查（第1步）：我方魔陷区必须存在至少1个可用空格，以便后续将这张卡作为装备卡放置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动合法性检查（第2步）：我方主要怪兽区存在至少1只表侧表示的超重武者怪兽可被选择为装备对象（且不选择自身）。
		and Duel.IsExistingTarget(c4786063.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 发送选择提示消息，提示玩家“请选择要装备的卡”（HINTMSG_EQUIP），并缓存选择信息供后续选择使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从我方主要怪兽区选择1只表侧表示的超重武者怪兽作为这个效果的装备对象，并自动将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c4786063.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- ①效果处理：若条件允许则将这张卡装备给对象怪兽；若魔陷区无空位、对象失控/里侧/不关联等则这张卡送去墓地；装备成功后给这张卡附加仅能装备给「超重武者」怪兽的限制效果。
function c4786063.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 取得发动时选择的对象怪兽（要装备的怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查装备处理是否仍然合法：魔陷区空位不足、对象已不属于我方、对象变为里侧表示或对象与效果失去联系时，装备失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备失败时，将这张卡以效果原因（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡，由我方装备给对象怪兽（超重武者）。
	Duel.Equip(tp,c,tc)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c4786063.eqlimit)
	c:RegisterEffect(e1)
end
-- 装备限制判定：这张卡作为装备卡时，仅允许装备给持有「超重武者」字段（0x9a）的怪兽。
function c4786063.eqlimit(e,c)
	return c:IsSetCard(0x9a)
end
-- ②效果的发动代价：检查这张卡是否可以从手卡丢弃；可以则将其从手卡送去墓地（代价+丢弃）作为发动条件。
function c4786063.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 执行代价：将这张卡从手卡丢弃到墓地，代价原因标记为REASON_COST+REASON_DISCARD。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 目标过滤条件：对象必须为表侧守备表示且属于「超重武者」系列（0x9a）。
function c4786063.filter(c)
	return c:IsPosition(POS_FACEUP_DEFENSE) and c:IsSetCard(0x9a)
end
-- ②效果的取对象处理：发动时验证我方主要怪兽区存在表侧守备表示的超重武者怪兽；连锁处理时检查对象的控制者、位置和过滤条件，并让玩家选择目标。
function c4786063.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c4786063.filter(chkc) end
	-- 发动合法性检查：我方主要怪兽区是否存在至少1只满足条件（表侧守备表示的超重武者）且能成为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c4786063.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 发送选择提示消息，提示玩家“请选择表侧守备表示的怪兽”（HINTMSG_FACEUPDEFENSE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPDEFENSE)  --"请选择表侧守备表示的怪兽"
	-- 让玩家从我方主要怪兽区选择1只表侧守备表示的超重武者怪兽作为效果对象，并自动登记为连锁对象。
	Duel.SelectTarget(tp,c4786063.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果处理：对仍关联且表侧表示的对象怪兽适用“守备力下降800直到回合结束”和“不会被战斗·效果破坏”的效果；其中战斗破坏抗性与效果破坏抗性分别通过两个单效果注册。
function c4786063.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 直到回合结束时，那只怪兽的守备力下降800
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(-800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 不会被战斗·效果破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e3)
	end
end

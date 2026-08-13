--トリックスター・ブーケ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「淘气仙星」怪兽和场上1只表侧表示怪兽为对象才能发动。那只「淘气仙星」怪兽回到持有者手卡，另1只作为对象的怪兽的攻击力直到回合结束时上升回到手卡的怪兽的原本攻击力数值。
function c99890852.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「淘气仙星」怪兽和场上1只表侧表示怪兽为对象才能发动。那只「淘气仙星」怪兽回到持有者手卡，另1只作为对象的怪兽的攻击力直到回合结束时上升回到手卡的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,99890852)
	e1:SetTarget(c99890852.target)
	e1:SetOperation(c99890852.activate)
	c:RegisterEffect(e1)
end
-- 判断「淘气仙星」对象候选是否合法：该卡必须满足可回手的「淘气仙星」条件，并且场上还存在另一张表侧表示怪兽可作为第二个对象。
function c99890852.filter(c,tp)
	return c99890852.thfilter(c,tp)
		-- 在场上（自己和对方怪兽区）检索是否存在另一张表侧表示怪兽（排除当前候选卡c），以保证能凑齐两个对象。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 筛选可返回手牌的「淘气仙星」怪兽：表侧表示、属于0xfb系列、控制者为发动玩家、能够加入手牌且不是额外卡组怪兽（即必须是主卡组中的「淘气仙星」怪兽）。
function c99890852.thfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xfb) and c:IsControler(tp)
		and c:IsAbleToHand() and not c:IsExtraDeckMonster()
end
-- 用于选择两张对象的子组校验，确认所选的两张卡中至少有一张满足可回手的「淘气仙星」条件，从而符合效果的选材要求。
function c99890852.gcheck(g,tp)
	return g:IsExists(c99890852.thfilter,1,nil,tp)
end
-- 效果发动时的对象选择与登记：从双方场上所有表侧表示怪兽中选出2张（其中至少1张为可回手的「淘气仙星」怪兽），将选中的卡设为效果对象，并登记后续要执行的“返回手牌”操作信息。
function c99890852.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在效果发动时检查是否存在合法对象组合：自己场上至少存在1只满足filter条件的「淘气仙星」怪兽（即自己场上存在可回手的「淘气仙星」且场上另有表侧表示怪兽）。
	if chk==0 then return Duel.IsExistingTarget(c99890852.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 取得场上所有表侧表示怪兽（双方怪兽区）作为可选对象集合，用于后续选择两张对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	g=g:Filter(Card.IsCanBeEffectTarget,nil,e)
	-- 给出“请选择效果的对象”的提示信息，要求玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,c99890852.gcheck,false,2,2,tp)
	-- 将玩家选择的两张卡登记为当前效果的对象，确保连锁处理时能正确引用这些卡。
	Duel.SetTargetCard(sg)
	-- 登记操作信息：本效果包含“返回手牌”的类别，数量为1张（具体哪张在效果处理时确定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
-- 效果处理：从已选对象中选出1只「淘气仙星」怪兽返回持有者手卡；若返回成功且另一只对象怪兽仍表侧表示在场，则使其攻击力直到回合结束时上升返回手卡怪兽的原本攻击力数值。
function c99890852.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本连锁相关的效果对象（即发动时选择的那2张卡），用于后续处理。
	local g=Duel.GetTargetsRelateToChain()
	if #g==0 then return end
	local tg=g:Filter(c99890852.thfilter,nil,tp)
	local tc1=tg:GetFirst()
	if #tg>1 then
		-- 当对象中有多只符合条件的「淘气仙星」怪兽时，给出“请选择要返回手牌的卡”的提示，让玩家指定回手的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		tc1=tg:Select(tp,1,1,nil):GetFirst()
	end
	if not tc1 then return end
	local tc2=(g-tc1):GetFirst()
	-- 将选定的「淘气仙星」怪兽返回其持有者手卡，并确认返回成功且该卡已到手牌，以此作为后续攻击力上升的发动条件。
	if Duel.SendtoHand(tc1,nil,REASON_EFFECT)~=0 and tc1:IsLocation(LOCATION_HAND)
		and tc2 and tc2:IsFaceup() then
		local atk=tc1:GetBaseAttack()
		-- 另1只作为对象的怪兽的攻击力直到回合结束时上升回到手卡的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc2:RegisterEffect(e1)
	end
end

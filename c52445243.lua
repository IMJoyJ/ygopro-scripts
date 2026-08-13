--トライエッジ・マスター
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。那一组作为同调素材的怪兽的等级组合的以下效果适用。3只以上为素材的场合以下效果全部适用。
-- ●1星和5星：场上1张其他卡破坏。
-- ●2星和4星：自己抽1张。
-- ●3星和3星：这张卡当作调整使用。
function c52445243.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上（即至少1只调整以外的怪兽，总素材数最少为2）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的效果1回合只能使用1次。①：这张卡同调召唤的场合才能发动。那一组作为同调素材的怪兽的等级组合的以下效果适用。3只以上为素材的场合以下效果全部适用。●1星和5星：场上1张其他卡破坏。●2星和4星：自己抽1张。●3星和3星：这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,52445243)
	e1:SetCondition(c52445243.con)
	e1:SetTarget(c52445243.tg)
	e1:SetOperation(c52445243.op)
	c:RegisterEffect(e1)
	-- 那一组作为同调素材的怪兽的等级组合的以下效果适用。3只以上为素材的场合以下效果全部适用。●1星和5星：场上1张其他卡破坏。●2星和4星：自己抽1张。●3星和3星：这张卡当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c52445243.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
c52445243.treat_itself_tuner=true
-- 检查同调素材的等级组合，为①效果设置适用的标记：先将标记置0，若素材数≥3则设标记为全部（1|2|4）；否则分别检查是否存在1星和5星、2星和4星、两只3星，按位设置破坏/抽卡/变调整的标记。
function c52445243.valcheck(e,c)
	e:GetLabelObject():SetLabel(0)
	local g=c:GetMaterial()
	if #g>=3 then
		e:GetLabelObject():SetLabel(1|2|4)
		return
	end
	local b1=g:IsExists(Card.IsLevel,1,nil,1) and g:IsExists(Card.IsLevel,1,nil,5)
	local b2=g:IsExists(Card.IsLevel,1,nil,2) and g:IsExists(Card.IsLevel,1,nil,4)
	local b3=g:IsExists(Card.IsLevel,2,nil,3)
	if b1 then
		e:GetLabelObject():SetLabel(1)
	end
	if b2 then
		e:GetLabelObject():SetLabel(2)
	end
	if b3 then
		e:GetLabelObject():SetLabel(4)
	end
end
-- 发动条件：这张卡进行了同调召唤，且素材等级检查的结果不为0（即至少有一项对应的效果可以适用）。
function c52445243.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()~=0
end
-- 发动时的合法性与目标设置：根据标记位判断当前可适用的效果（破坏/抽卡/变调整），若至少一项可行则允许发动，并清空效果分类后，对破坏和抽卡分别设置操作信息及效果分类。
function c52445243.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	-- 检查场上是否存在除这张卡以外的其他卡，用于决定是否适用“1星和5星”的破坏效果。
	local des=ct&1>0 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
	-- 检查自己是否可以进行1张抽卡，用于决定是否适用“2星和4星”的抽卡效果。
	local draw=ct&2>0 and Duel.IsPlayerCanDraw(tp,1)
	local tun=ct&4>0 and not c:IsType(TYPE_TUNER)
	if chk==0 then return des or draw or tun end
	e:SetCategory(0)
	if des then
		-- 设置破坏的操作信息：不取对象地破坏场上1张卡，目标范围为双方场上。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
		e:SetCategory(CATEGORY_DESTROY)
	end
	if draw then
		-- 设置抽卡的操作信息：自己抽1张卡（目标为自己）。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
		e:SetCategory(e:GetCategory()|CATEGORY_DRAW)
	end
end
-- 效果处理：根据标记位依次执行适用的效果——若为破坏则选择场上1张其他卡破坏；若为抽卡则自己抽1张；若为变调整则给自己附加当作调整使用的效果；多个效果之间用BreakEffect错开处理时点。
function c52445243.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	-- 效果处理时再次确认场上仍存在除这张卡以外的卡，且这张卡与效果仍有联系，才执行破坏效果。
	local des=ct&1>0 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,aux.ExceptThisCard(e))
	-- 效果处理时确认自己仍可以抽1张卡，才执行抽卡效果。
	local draw=ct&2>0 and Duel.IsPlayerCanDraw(tp,1)
	local tun=ct&4>0 and not c:IsType(TYPE_TUNER) and c:IsRelateToChain() and c:IsFaceup()
	if des then
		-- 为玩家显示“请选择要破坏的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家从双方场上选择1张除这张卡以外的卡（处理时选择，不取对象）作为破坏对象。
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
		-- 显示所选中卡片的对象动画，并记录这些卡被选为对象。
		Duel.HintSelection(g)
		-- 以效果原因将选择的卡破坏。
		Duel.Destroy(g,REASON_EFFECT)
		-- 如果破坏后还需要处理抽卡或变调整效果，则中断当前效果，使后续处理不再与破坏视为同一时点。
		if draw or tun then Duel.BreakEffect() end
	end
	if draw then
		-- 以效果原因让自己抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
		-- 如果抽卡后还需要处理变调整效果，则中断效果处理，使变调整效果单独处理。
		if tun then Duel.BreakEffect() end
	end
	if tun then
		-- ●3星和3星：这张卡当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end

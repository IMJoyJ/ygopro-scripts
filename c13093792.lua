--D-HERO ダイヤモンドガイ
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。自己卡组最上面的卡翻开，那是通常魔法卡的场合，那张卡送去墓地。不是的场合，那张卡回到卡组最下面。这个效果把通常魔法卡送去墓地的场合，下次的自己回合的主要阶段可以把墓地的那张通常魔法卡的发动时的效果发动。
function c13093792.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。自己卡组最上面的卡翻开，那是通常魔法卡的场合，那张卡送去墓地。不是的场合，那张卡回到卡组最下面。这个效果把通常魔法卡送去墓地的场合，下次的自己回合的主要阶段可以把墓地的那张通常魔法卡的发动时的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13093792,0))  --"发动魔法卡效果"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c13093792.target)
	e1:SetOperation(c13093792.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的合法性判定：自己卡组有卡才能发动，并登记效果处理时将把卡组最上方1张卡送去墓地的操作信息。
function c13093792.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）检查自己卡组是否有卡，有卡才能发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 登记效果处理时可能将1张卡送去墓地的操作信息（用于连锁判定等，不指定具体对象）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
end
-- 效果处理：确认自己卡组最上方1张卡片，若为通常魔法卡则将其从卡组送去墓地，并为其在墓地设置可在下次自己回合主要阶段发动其魔法效果的效果；若不是通常魔法卡则将其放回卡组最下面。
function c13093792.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己卡组没有卡则无法处理，直接结束。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 向双方玩家确认自己卡组最上方的1张卡。
	Duel.ConfirmDecktop(tp,1)
	-- 获取卡组最上方的1张卡，形成Group对象。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:GetType()==TYPE_SPELL then
		-- 禁用本次操作后的自动洗卡检测，因为从卡组顶端取出卡并送墓或移回卡组底不涉及卡组洗切。
		Duel.DisableShuffleCheck()
		-- 将翻开的卡从卡组送去墓地，原因是效果处理。
		Duel.SendtoGrave(g,REASON_EFFECT)
		local ae=tc:GetActivateEffect()
		if tc:IsLocation(LOCATION_GRAVE) and ae then
			-- 这个效果把通常魔法卡送去墓地的场合，下次的自己回合的主要阶段可以把墓地的那张通常魔法卡的发动时的效果发动。
			local e1=Effect.CreateEffect(tc)
			e1:SetDescription(ae:GetDescription())
			e1:SetType(EFFECT_TYPE_IGNITION)
			e1:SetCountLimit(1)
			e1:SetRange(LOCATION_GRAVE)
			e1:SetReset(RESET_EVENT+0x2fe0000+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
			e1:SetCondition(c13093792.spellcon)
			e1:SetTarget(c13093792.spelltg)
			e1:SetOperation(c13093792.spellop)
			tc:RegisterEffect(e1)
		end
	else
		-- 将这张卡移动到卡组最下面，即放回卡组底部。
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- 被赋予的墓地魔法效果发动条件：该卡不是在当前回合被送去墓地，即必须等到下一个回合以后才能发动；配合起动效果的类型，使其只能在下次自己回合的主要阶段发动。
function c13093792.spellcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该卡进入墓地的回合与当前回合数不同，即不能在被送去墓地的当回合发动。
	return e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end
-- 作为被复制魔法的发动准备：获取原魔法发动效果的目标函数，并在合法性检查时调用它；若原效果是取对象效果，则继承取对象标志，并调用原目标函数完成对象选择与操作信息设置。
function c13093792.spelltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ae=e:GetHandler():GetActivateEffect()
	local ftg=ae:GetTarget()
	if chk==0 then
		e:SetCostCheck(false)
		return not ftg or ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
	if ae:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	else e:SetProperty(0) end
	if ftg then
		e:SetCostCheck(false)
		ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
-- 实际执行被复制的魔法发动效果：获取原魔法发动效果的Operation处理函数并直接调用，从而处理该魔法的发动时的效果。
function c13093792.spellop(e,tp,eg,ep,ev,re,r,rp)
	local ae=e:GetHandler():GetActivateEffect()
	local fop=ae:GetOperation()
	fop(e,tp,eg,ep,ev,re,r,rp)
end

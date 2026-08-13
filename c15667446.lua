--暗黒界の闘神 ラチナ
-- 效果：
-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。被对方的效果丢弃的场合，发动时以场上1只恶魔族怪兽为对象。那个场合，再让以下效果适用。
-- ●作为对象的恶魔族怪兽的攻击力上升500。
function c15667446.initial_effect(c)
	-- ①：这张卡被效果从手卡丢弃去墓地的场合发动。这张卡特殊召唤。被对方的效果丢弃的场合，发动时以场上1只恶魔族怪兽为对象。那个场合，再让以下效果适用。●作为对象的恶魔族怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15667446,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c15667446.spcon)
	e1:SetTarget(c15667446.sptg)
	e1:SetOperation(c15667446.spop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：记录这张卡丢弃前的控制者，并判断这张卡确实是从手卡因对方的『效果丢弃』原因（REASON_EFFECT|REASON_DISCARD）送去墓地，满足则本诱发效果发动。
function c15667446.spcon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 对象筛选：选择场上表侧表示且种族为恶魔族的怪兽。
function c15667446.atfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 发动时的目标处理：若这张卡是被对方的效果丢弃且丢弃前由自己控制，则将效果类别设为特殊召唤+攻击力变化，并变为取对象效果，从双方主要怪兽区选择1只表侧表示恶魔族怪兽为对象；否则仅设为特殊召唤。最后登记特殊召唤这张卡自身的操作信息。
function c15667446.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c15667446.atfilter(chkc) end
	if chk==0 then return true end
	if rp==1-tp and tp==e:GetLabel() then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 向玩家tp显示“请选择表侧表示的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 从双方主要怪兽区选择1只表侧表示恶魔族怪兽作为效果对象，并将该对象与当前连锁关联。
		Duel.SelectTarget(tp,c15667446.atfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	end
	-- 登记操作信息：本次连锁将特殊召唤效果持有者（这张卡）1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：满足条件时先特殊召唤这张卡，特召成功后若仍存在被选择的恶魔族对象，则中断当前效果处理，改为对该对象赋予攻击力上升500的永续效果。
function c15667446.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断这张卡是否仍与此效果关联，并把它以表侧攻击表示特殊召唤到发动玩家tp的场上；特召成功（返回>0）才继续执行后续对象处理。
	if e:GetHandler():IsRelateToEffect(e) and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 取得发动时选择的恶魔族怪兽对象，用于后续上升攻击力。
		local tc=Duel.GetFirstTarget()
		if tc and c15667446.atfilter(tc) and tc:IsRelateToEffect(e) then
			-- 中断当前效果处理，使接下来的攻击力上升效果作为另一段处理进行，避免与特殊召唤成功时点产生冲突。
			Duel.BreakEffect()
			-- ●作为对象的恶魔族怪兽的攻击力上升500。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end

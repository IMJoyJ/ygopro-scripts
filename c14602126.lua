--エクシーズ・インポート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只超量怪兽和持有那个攻击力以下的攻击力的对方场上1只怪兽为对象才能发动。那只对方怪兽在那只自己怪兽下面重叠作为超量素材。
function c14602126.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只超量怪兽和持有那个攻击力以下的攻击力的对方场上1只怪兽为对象才能发动。那只对方怪兽在那只自己怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,14602126+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c14602126.target)
	e1:SetOperation(c14602126.activate)
	c:RegisterEffect(e1)
end
-- 筛选自己场上表侧表示的超量怪兽，且对方场上存在攻击力不高于此怪兽攻击力、可作为超量素材的怪兽。
function c14602126.xyzfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查对方场上是否存在1只攻击力不大于该超量怪兽当前攻击力、且可作为超量素材的表侧表示怪兽。
		and Duel.IsExistingTarget(c14602126.matfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 筛选对方场上表侧表示且攻击力不高于给定攻击力、可作为超量素材的怪兽。
function c14602126.matfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsCanOverlay()
end
-- 效果发动时的对象选择处理：先选择自己场上1只超量怪兽，再选择对方场上1只满足攻击力条件的怪兽作为对象，并将选择的自己怪兽记录到效果标签中。
function c14602126.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在效果发动合法性检查阶段，确认自己场上是否存在可选为对象的超量怪兽，且对方场上有满足条件的怪兽；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c14602126.xyzfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 弹出选择对象的提示信息，提示玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上的1只超量怪兽作为效果对象，并返回对象组。
	local g=Duel.SelectTarget(tp,c14602126.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	-- 再次弹出选择对象的提示信息，提示玩家选择对方场上的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择对方场上1只攻击力不大于之前选择的超量怪兽当前攻击力、且可作为超量素材的怪兽作为效果对象。
	Duel.SelectTarget(tp,c14602126.matfilter,tp,0,LOCATION_MZONE,1,1,nil,tc:GetAttack())
end
-- 效果处理时执行：取出选择的自己超量怪兽和对方怪兽，检查双方卡片是否仍与效果关联、控制权、免疫等，然后将对方怪兽的原有超量素材送去墓地，再把对方怪兽叠放在自己超量怪兽下面作为超量素材。
function c14602126.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取当前连锁处理中的效果对象卡组，即发动时选择的两张对象怪兽。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and not tc:IsImmuneToEffect(e) and lc:IsRelateToEffect(e) and lc:IsControler(1-tp) and lc:IsType(TYPE_MONSTER) and not lc:IsImmuneToEffect(e) then
		local og=lc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将对方怪兽原本持有的超量素材按规则送去墓地（因为对方怪兽即将成为超量素材，其原素材必须先处理）。
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将对方怪兽作为超量素材叠放在自己选择的超量怪兽下面，完成超量素材的叠放。
		Duel.Overlay(tc,Group.FromCards(lc))
	end
end

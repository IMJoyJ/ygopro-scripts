--サイバーサル・サイクロン
-- 效果：
-- ①：以对方场上1只连接怪兽为对象才能发动。从自己墓地选连接标记数量和那只怪兽相同的1只怪兽除外，作为对象的怪兽破坏。这个效果除外的自己怪兽的原本种族是电子界族的场合，可以再选对方的魔法与陷阱区域1张表侧表示的卡破坏。
function c37007105.initial_effect(c)
	-- ①：以对方场上1只连接怪兽为对象才能发动。从自己墓地选连接标记数量和那只怪兽相同的1只怪兽除外，作为对象的怪兽破坏。这个效果除外的自己怪兽的原本种族是电子界族的场合，可以再选对方的魔法与陷阱区域1张表侧表示的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c37007105.target)
	e1:SetOperation(c37007105.activate)
	c:RegisterEffect(e1)
end
-- 对方场上的表侧表示连接怪兽，且自己墓地有连接标记数相同的可除外怪兽时，才能作为效果对象。
function c37007105.filter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
		-- 追加判断：自己墓地存在连接标记数等于该对象怪兽连接标记数、且满足rmfilter的怪兽。
		and Duel.IsExistingMatchingCard(c37007105.rmfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetLink())
end
-- 墓地中满足以下条件的卡：是怪兽、连接标记数等于指定link值、且可以被除外。
function c37007105.rmfilter(c,link)
	return c:IsType(TYPE_MONSTER) and c:IsLink(link) and c:IsAbleToRemove()
end
-- 发动时的目标选择处理：判断能否发动、选择对方场上1只连接怪兽作为对象，并设置后续破坏与除外的操作信息。
function c37007105.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c37007105.filter(chkc,tp) end
	-- 发动条件检测：对方场上有1只满足filter的怪兽可以成为对象。
	if chk==0 then return Duel.IsExistingTarget(c37007105.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 弹出选择破坏对象的消息提示，为玩家提供“请选择要破坏的卡”的选择框文本。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从对方场上选择1只满足filter的连接怪兽作为对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c37007105.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息：本次效果会破坏所选择的那1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本次效果预计会从自己墓地除外1张卡（具体哪张在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 对方魔陷区中表侧表示且位于主要魔陷区域（序号0-4，不含场地魔法格）的卡。
function c37007105.desfilter(c)
	return c:IsFaceup() and c:GetSequence()<5
end
-- 效果处理函数：取对象、从墓地除外合适怪兽、破坏对象怪兽，若除外怪兽为电子界族则再询问并破坏对方1张表侧魔陷。
function c37007105.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择要除外的卡，显示“请选择要除外的卡”的选择框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只连接标记数与对象怪兽相同，且不受王家长眠之谷影响的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c37007105.rmfilter),tp,LOCATION_GRAVE,0,1,1,nil,tc:GetLink())
	local rc=g:GetFirst()
	-- 确认选择的卡除外成功，并且该卡确实被除外到除外区。
	if rc and Duel.Remove(rc,0,REASON_EFFECT)~=0 and rc:IsLocation(LOCATION_REMOVED)
		-- 确认对象怪兽被效果破坏成功，并且被除外的自己怪兽的原本种族是电子界族。
		and Duel.Destroy(tc,REASON_EFFECT)~=0 and bit.band(rc:GetOriginalRace(),RACE_CYBERSE)>0 then
		-- 获取对方魔陷区所有满足desfilter条件的表侧表示卡。
		local sg=Duel.GetMatchingGroup(c37007105.desfilter,tp,0,LOCATION_SZONE,nil)
		-- 存在可追加破坏的卡时，询问玩家是否发动追加破坏效果。
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(37007105,0)) then  --"是否再选1张对方的魔陷破坏？"
			-- 中断当前效果处理，使后续追加破坏作为单独处理，避免产生错误的时点。
			Duel.BreakEffect()
			-- 提示玩家选择要追加破坏的卡，显示“请选择要破坏的卡”的选择框。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dg=sg:Select(tp,1,1,nil)
			-- 手动显示所选卡被选为对象的动画，并记录这些卡被选为对象。
			Duel.HintSelection(dg)
			-- 将选择的对方魔陷卡以效果原因破坏。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end

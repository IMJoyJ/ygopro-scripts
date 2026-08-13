--シンクロ・クラッカー
-- 效果：
-- ①：以自己场上1只同调怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，持有那只同调怪兽的原本攻击力以下的攻击力的对方场上的表侧表示怪兽全部破坏。
function c41097056.initial_effect(c)
	-- ①：以自己场上1只同调怪兽为对象才能发动。那只怪兽回到持有者的额外卡组，持有那只同调怪兽的原本攻击力以下的攻击力的对方场上的表侧表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c41097056.target)
	e1:SetOperation(c41097056.activate)
	c:RegisterEffect(e1)
end
-- 定义可选择为对象的同调怪兽过滤条件：必须是表侧表示的同调怪兽、能回到额外卡组，并且对方场上有攻击力在其原本攻击力以下的表侧表示怪兽存在。
function c41097056.filter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
		-- 追加判定：对方场上至少存在1只攻击力不高于该同调怪兽原本攻击力（负数攻击力按0处理）的表侧表示怪兽，以保证破坏效果有可处理对象。
		and Duel.IsExistingMatchingCard(c41097056.desfilter,tp,0,LOCATION_MZONE,1,nil,math.max(0,c:GetTextAttack()))
end
-- 定义被破坏怪兽的过滤条件：对方场上的表侧表示怪兽，且攻击力不高于传入的atk数值。
function c41097056.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 效果发动时的目标选择与操作信息设置：检查可发动性，选择自己场上1只同调怪兽作为对象，并收集对方场上当前满足破坏条件的怪兽，然后设置回额外卡组与破坏的操作信息。
function c41097056.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c41097056.filter(chkc,tp) end
	-- 在发动时点检查是否存在可取对象：自己场上有满足条件的同调怪兽（且对方场上有可破坏怪兽）时才能发动。
	if chk==0 then return Duel.IsExistingTarget(c41097056.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 弹出选择提示信息，提示玩家选择要返回额外卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 由玩家从自己场上选择1只符合条件的同调怪兽，并将其设为该连锁的效果对象。
	local g1=Duel.SelectTarget(tp,c41097056.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 根据已选同调怪兽的原本攻击力，获取对方场上当前所有攻击力在其以下的表侧表示怪兽集合，用于后续设置破坏的操作信息。
	local g2=Duel.GetMatchingGroup(c41097056.desfilter,tp,0,LOCATION_MZONE,nil,math.max(0,g1:GetFirst():GetTextAttack()))
	-- 设置操作信息：本次效果包含回额外卡组，目标为已选同调怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g1,1,0,0)
	-- 设置操作信息：本次效果包含破坏，可能被破坏的对象为g2集合，数量为g2中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,g2:GetCount(),0,0)
end
-- 效果处理函数：先取出效果对象，若对象仍与效果关联且成功回到持有者额外卡组，则再根据其原本攻击力破坏对方场上符合条件的表侧表示怪兽。
function c41097056.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象卡（之前选择的那只同调怪兽）。
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetTextAttack()
	if atk<0 then atk=0 end
	-- 判断该同调怪兽仍与效果关联、能成功返回持有者卡组并洗牌，且返回后位于额外卡组（确认是额外怪兽），才继续执行破坏处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
		-- 按该同调怪兽原本攻击力，重新筛选当前对方场上攻击力在其以下的所有表侧表示怪兽，作为实际破坏对象。
		local g=Duel.GetMatchingGroup(c41097056.desfilter,tp,0,LOCATION_MZONE,nil,atk)
		-- 将筛选出的对方怪兽全部破坏，破坏原因为效果。
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--識無辺世壊
-- 效果：
-- ①：场上有「维舍斯-阿修特罗德」存在的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，破坏的卡的原本卡名是「维舍斯-阿修特罗德」的场合，可以选除外的1只自己的「维萨斯-斯塔弗罗斯特」特殊召唤。「维舍斯-阿修特罗德」以外的场合，可以选自己场上1只「维舍斯-阿修特罗德」，那个攻击力上升1500。
function c44553392.initial_effect(c)
	-- 将卡号56099748（维萨斯-斯塔弗罗斯特）登记到本卡的代码列表中，表示本卡效果记述了该卡名，用于规则上的关联查询。
	aux.AddCodeList(c,56099748)
	-- ①：场上有「维舍斯-阿修特罗德」存在的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，破坏的卡的原本卡名是「维舍斯-阿修特罗德」的场合，可以选除外的1只自己的「维萨斯-斯塔弗罗斯特」特殊召唤。「维舍斯-阿修特罗德」以外的场合，可以选自己场上1只「维舍斯-阿修特罗德」，那个攻击力上升1500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c44553392.condition)
	e1:SetTarget(c44553392.target)
	e1:SetOperation(c44553392.activate)
	c:RegisterEffect(e1)
end
-- 定义本效果的发动条件函数：检查场上是否存在表侧表示的「维舍斯-阿修特罗德」，满足效果文的发动条件。
function c44553392.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定双方场上是否存在至少1张表侧表示且卡号为65815684（维舍斯-阿修特罗德）的卡；只有存在时效果才可发动。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,65815684)
end
-- 定义本效果的发动时目标选择函数：从场上选择1张除本卡以外的卡作为破坏对象，并登记破坏效果的操作信息。
function c44553392.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 在发动合法性的chk=0检查中，确认场上存在除本卡以外可被选为对象的卡，保证有对象可选。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家弹出选择提示“请选择要破坏的卡”，将选择消息写入缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择1张除本卡以外的卡作为对象（取对象），并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置连锁操作信息：本次处理将破坏所选择的1张卡（CATEGORY_DESTROY），供相关效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义特殊召唤的过滤函数：筛选除外区表侧表示、卡号为56099748（维萨斯-斯塔弗罗斯特）且能被通常特殊召唤的怪兽。
function c44553392.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(56099748) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果处理函数：先破坏对象卡；若成功且对象原本卡名是「维舍斯-阿修特罗德」，则从除外区特殊召唤1只「维萨斯-斯塔弗罗斯特」；否则选自己场上1只「维舍斯-阿修特罗德」上升1500攻击力。
function c44553392.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果相关（未离场等），然后以效果原因将其破坏；只有破坏成功才继续后续分支处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 计算己方主怪兽区空位数，用于判断是否具备特殊召唤所需空位。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取除外区中满足特殊召唤条件的「维萨斯-斯塔弗罗斯特」集合，供后续选择。
		local sg=Duel.GetMatchingGroup(c44553392.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
		-- 获取己方场上表侧表示的「维舍斯-阿修特罗德」集合，供后续选择攻击力上升对象。
		local ag=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_MZONE,0,nil,65815684)
		if tc:IsOriginalCodeRule(65815684) and ft>0 and #sg>0
			-- 在破坏对象的原本卡名为「维舍斯-阿修特罗德」、主怪兽区有空位且除外区有符合条件的怪兽时，询问玩家是否选择除外的怪兽特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(44553392,0)) then  --"是否选除外的怪兽特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤与之前的破坏视为不同时处理，避免错失时点。
			Duel.BreakEffect()
			-- 显示“请选择要特殊召唤的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg1=sg:Select(tp,1,1,nil)
			-- 将选中的「维萨斯-斯塔弗罗斯特」以表侧表示特殊召唤到己方场上（不检查召唤条件与苏生限制）。
			Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
		elseif not tc:IsOriginalCodeRule(65815684) and #ag>0
			-- 在破坏对象的原本卡名不是「维舍斯-阿修特罗德」且己方场上有「维舍斯-阿修特罗德」时，询问玩家是否选择怪兽上升攻击力。
			and Duel.SelectYesNo(tp,aux.Stringid(44553392,1)) then  --"是否选怪兽上升攻击力？"
			-- 中断当前效果处理，使后续的攻击力上升与之前的破坏视为不同时处理，避免错失时点。
			Duel.BreakEffect()
			-- 显示“请选择表侧表示的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			local ag1=ag:Select(tp,1,1,nil)
			-- 手动为选中的「维舍斯-阿修特罗德」播放被选择动画，并将其记录为被选为对象（广义），以便触发相关时点。
			Duel.HintSelection(ag1)
			-- 「维舍斯-阿修特罗德」以外的场合，可以选自己场上1只「维舍斯-阿修特罗德」，那个攻击力上升1500。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ag1:GetFirst():RegisterEffect(e1)
		end
	end
end

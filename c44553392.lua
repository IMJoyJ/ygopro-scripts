--識無辺世壊
-- 效果：
-- ①：场上有「维舍斯-阿修特罗德」存在的场合，以场上1张卡为对象才能发动。那张卡破坏。那之后，破坏的卡的原本卡名是「维舍斯-阿修特罗德」的场合，可以选除外的1只自己的「维萨斯-斯塔弗罗斯特」特殊召唤。「维舍斯-阿修特罗德」以外的场合，可以选自己场上1只「维舍斯-阿修特罗德」，那个攻击力上升1500。
function c44553392.initial_effect(c)
	-- 记录此卡具有「维舍斯-阿修特罗德」的卡名
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
-- 检查场上是否存在「维舍斯-阿修特罗德」
function c44553392.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「维舍斯-阿修特罗德」
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,65815684)
end
-- 设置效果目标选择
function c44553392.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 检查是否存在可选择的目标
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的卡
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置效果操作信息为破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义特殊召唤过滤器，筛选可特殊召唤的「维萨斯-斯塔弗罗斯特」
function c44553392.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(56099748) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理效果发动
function c44553392.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果目标
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡存在且成功破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 获取玩家场上可用怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取可特殊召唤的「维萨斯-斯塔弗罗斯特」
		local sg=Duel.GetMatchingGroup(c44553392.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
		-- 获取玩家场上的「维舍斯-阿修特罗德」
		local ag=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_MZONE,0,nil,65815684)
		if tc:IsOriginalCodeRule(65815684) and ft>0 and #sg>0
			-- 询问是否选择特殊召唤除外的「维萨斯-斯塔弗罗斯特」
			and Duel.SelectYesNo(tp,aux.Stringid(44553392,0)) then  --"是否选除外的怪兽特殊召唤？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg1=sg:Select(tp,1,1,nil)
			-- 将选中的「维萨斯-斯塔弗罗斯特」特殊召唤
			Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
		elseif not tc:IsOriginalCodeRule(65815684) and #ag>0
			-- 询问是否选择「维舍斯-阿修特罗德」攻击力上升
			and Duel.SelectYesNo(tp,aux.Stringid(44553392,1)) then  --"是否选怪兽上升攻击力？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择表侧表示的「维舍斯-阿修特罗德」
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			local ag1=ag:Select(tp,1,1,nil)
			-- 显示选中的「维舍斯-阿修特罗德」被选为对象
			Duel.HintSelection(ag1)
			-- 给选中的「维舍斯-阿修特罗德」攻击力上升1500
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ag1:GetFirst():RegisterEffect(e1)
		end
	end
end

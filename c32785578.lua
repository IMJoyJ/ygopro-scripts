--フェアーウェルカム・ラビュリンス
-- 效果：
-- ①：自己场上有恶魔族怪兽存在的场合，自己或者对方的怪兽的攻击宣言时，以场上1张卡为对象才能发动。那次攻击无效，作为对象的卡破坏。那之后，可以从手卡·卡组选「拉比林斯迷宫」卡以外的1张通常陷阱卡在自己场上盖放。
function c32785578.initial_effect(c)
	-- ①：自己场上有恶魔族怪兽存在的场合，自己或者对方的怪兽的攻击宣言时，以场上1张卡为对象才能发动。那次攻击无效，作为对象的卡破坏。那之后，可以从手卡·卡组选「拉比林斯迷宫」卡以外的1张通常陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c32785578.condition)
	e1:SetTarget(c32785578.target)
	e1:SetOperation(c32785578.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判定怪兽是否为表侧表示的恶魔族，用于筛查自己场上存在的符合条件的恶魔族怪兽。
function c32785578.cfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsFaceup()
end
-- 效果发动条件：自己场上存在表侧表示恶魔族怪兽时才满足发动条件。
function c32785578.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示恶魔族怪兽。
	return Duel.IsExistingMatchingCard(c32785578.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标处理：选择场上1张卡作为对象（不能选择本卡），并登记破坏该卡的操作信息。
function c32785578.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 发动合法性检查：确认场上存在除了本卡以外可以作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 弹出卡片选择提示，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张卡作为效果对象（不能选择本卡），并登记为攻击无效并破坏的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 将这次效果处理的信息登记为破坏1张卡（对象为已选择的g），供相关效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤函数：筛选出可以盖放的通常陷阱卡，且不属于「拉比林斯迷宫」字段（用于从手卡·卡组选1张盖放）。
function c32785578.stfilter(c)
	return c:GetType()==TYPE_TRAP and not c:IsSetCard(0x17e) and c:IsSSetable()
end
-- 效果处理：无效攻击，破坏作为对象的卡；若破坏成功，则可以从手牌·卡组选1张符合条件的通常陷阱卡盖放到自己场上（由玩家选择是否进行）。
function c32785578.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	local res=0
	-- 若攻击无效成功，且对象卡与本次效果仍有联系，则继续执行破坏处理。
	if Duel.NegateAttack() and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡，返回值res记录实际破坏数量，用于后续判断。
		res=Duel.Destroy(tc,REASON_EFFECT)
		-- 从手牌和卡组中筛选出符合条件的（可盖放的非「拉比林斯迷宫」通常陷阱）卡片集合。
		local g=Duel.GetMatchingGroup(c32785578.stfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		-- 若破坏成功、存在可选卡且玩家选择“是”，则执行后续盖放处理。
		if res>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(32785578,0)) then  --"是否选卡盖放？"
			-- 中断当前效果处理，使后续的盖放处理与前面的攻击无效/破坏错开时点，避免错过时点。
			Duel.BreakEffect()
			-- 弹出卡片选择提示，提示玩家选择要盖放的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选择的卡以里侧表示盖放到自己场上。
			Duel.SSet(tp,sg)
		end
	end
	-- 调用辅助函数：若本次效果成功破坏了卡，且满足「白银之城」等联动条件，则追加选择并破坏场上1张卡。
	aux.LabrynthDestroyOp(e,tp,res)
end

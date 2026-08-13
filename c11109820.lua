--エクシーズ・ユニバース
-- 效果：
-- ①：以场上2只超量怪兽为对象才能发动。那2只怪兽送去墓地。那之后，把持有和那2只超量怪兽的阶级合计相同或低1阶的阶级的1只「No.」怪兽以外的超量怪兽从额外卡组特殊召唤，把这张卡在下面重叠作为超量素材。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
function c11109820.initial_effect(c)
	-- ①：以场上2只超量怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11109820,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c11109820.target)
	e1:SetOperation(c11109820.operation)
	c:RegisterEffect(e1)
end
-- 作为第一只对象的选择过滤器：要求候选卡是表侧表示的超量怪兽，且场上还存在另一只可选的超量怪兽，以保证可以取2只超量怪兽为对象。
function c11109820.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 该行检查场上是否存在另一只超量怪兽，使filter2成立（即其与当前候选c的阶级合计能在额外卡组找到可特招的非No.超量怪兽），确保后续送墓与特招可行。
		and Duel.IsExistingTarget(c11109820.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,e,tp,c,c:GetRank())
end
-- 作为第二只对象的选择过滤器：要求候选卡是表侧表示的超量怪兽，且额外卡组存在阶级为传入rk与自身阶级之和（或低1阶）的可特殊召唤非No.超量怪兽；同时把自身和第一只对象mc作为待送墓组传递下去，以便计算特招空格。
function c11109820.filter2(c,e,tp,mc,rk)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查额外卡组是否有满足spfilter的超量怪兽，其阶级为rk+c:GetRank()或低1阶，且非No.、可特招；并把c和mc组成的Group作为“送墓后腾出位置”的参照传入过滤函数。
		and Duel.IsExistingMatchingCard(c11109820.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,rk+c:GetRank(),Group.FromCards(c,mc))
end
-- 定义可特殊召唤的额外超量怪兽条件：阶级等于rk或rk-1、卡名不含No.、能够被当前效果特殊召唤，并且在把mg（两只对象）送去墓地后仍有额外怪兽区空格可特殊召唤。
function c11109820.spfilter(c,e,tp,rk,mg)
	return (c:IsRank(rk) or c:IsRank(rk-1)) and not c:IsSetCard(0x48) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认在把选定的两只对象怪兽mg送去墓地后，己方场上仍有额外卡组怪兽可用的区域，以保证特殊召唤能够进行。
		and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- 效果发动阶段检查：该效果是魔法卡发动效果，发动卡本体可作为超量素材叠放（IsCanOverlay），且场上存在可选择的超量怪兽组合，满足发动条件。
function c11109820.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and e:GetHandler():IsCanOverlay()
		-- 确认场上至少存在一只超量怪兽能使filter1成立，也就是存在第一只对象，且连带能找到第二只对象，从而能够选择两只超量怪兽发动。
		and Duel.IsExistingTarget(c11109820.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 在选择第一只对象前，给玩家显示“请选择要送去墓地的卡”的提示消息，引导选择要送墓的超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从双方主要怪兽区选择1只满足filter1的超量怪兽作为第一只对象，并登记为连锁对象。
	local g1=Duel.SelectTarget(tp,c11109820.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	local tc=g1:GetFirst()
	-- 在选择第二只对象前，给玩家显示“请选择要送去墓地的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从场上选择1只满足filter2的超量怪兽作为第二只对象，排除第一只对象tc，并以tc的阶级作为rk参数进行筛选；同时登记为连锁对象。
	local g2=Duel.SelectTarget(tp,c11109820.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc,e,tp,tc,tc:GetRank())
	g1:Merge(g2)
	-- 设置连锁操作信息：本效果将要把g1（两只对象）送去墓地，数量为2，用于给其他卡（如星尘龙）进行效果判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,2,0,0)
	-- 设置连锁操作信息：本效果将会从额外卡组特殊召唤1只怪兽，持有者为tp，位置为额外卡组，用于效果判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：先给对方玩家附加“受到伤害变成0”的永续效果（持续到结束阶段），再取得对象两只超量怪兽；若两者仍与效果相关则送去墓地；确认至少2只已入墓后，从额外卡组选出符合条件的超量怪兽；若成功特殊召唤且此卡仍在有效位置，则将这张魔法卡叠放在该怪兽下面作为超量素材。
function c11109820.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 那2只怪兽送去墓地。那之后，把持有和那2只超量怪兽的阶级合计相同或低1阶的阶级的1只「No.」怪兽以外的超量怪兽从额外卡组特殊召唤，把这张卡在下面重叠作为超量素材。这张卡的发动后，直到回合结束时对方受到的全部伤害变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将e1（EFFECT_CHANGE_DAMAGE，把对方受到的效果伤害变为0）注册到当前玩家tp上，持续到结束阶段。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将e2（EFFECT_NO_EFFECT_DAMAGE，给对方玩家标记“已适用效果伤害变成0”的状态）注册到当前玩家tp上，持续到结束阶段。
		Duel.RegisterEffect(e2,tp)
	end
	-- 从当前连锁中获取发动时选择的对象卡片组，即那两只超量怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if not tc1:IsRelateToEffect(e) or not tc2:IsRelateToEffect(e) then return end
	-- 将取对象的两只超量怪兽以效果原因送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
	-- 获取上一步送墓操作实际处理的卡片组，用于确认两只怪兽是否都已成功被送至墓地。
	local og=Duel.GetOperatedGroup()
	if og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<2 then return end
	-- 从己方额外卡组筛选满足spfilter的超量怪兽，阶级为两只对象阶级合计或低1阶，且非No.卡、可特殊召唤的候选集合。
	local sg=Duel.GetMatchingGroup(c11109820.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,tc1:GetRank()+tc2:GetRank(),nil)
	if sg:GetCount()==0 then return end
	-- 特招前给玩家显示“请选择要特殊召唤的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local ssg=sg:Select(tp,1,1,nil)
	local sc=ssg:GetFirst()
	if sc then
		-- 将选中的超量怪兽以正面表示特殊召唤到己方场上。
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		if c:IsRelateToEffect(e) then
			c:CancelToGrave()
			-- 将发动后的这张魔法卡作为超量素材叠放在特殊召唤的超量怪兽下方。
			Duel.Overlay(sc,Group.FromCards(c))
		end
	end
end

--剣の王 フローディ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「剑界王战 弗罗德王」在自己场上只能有1只表侧表示存在。
-- ②：把自己场上的「王战」怪兽或者战士族怪兽任意数量解放，以那个数量的场上的怪兽为对象才能发动。那些怪兽破坏。那之后，对方可以从卡组抽出破坏的对方场上的怪兽的数量。这个效果在对方回合也能发动。
function c40998517.initial_effect(c)
	c:SetUniqueOnField(1,0,40998517)
	-- 这个卡名的②的效果1回合只能使用1次。②：把自己场上的「王战」怪兽或者战士族怪兽任意数量解放，以那个数量的场上的怪兽为对象才能发动。那些怪兽破坏。那之后，对方可以从卡组抽出破坏的对方场上的怪兽的数量。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40998517,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,40998517)
	e1:SetCost(c40998517.descost)
	e1:SetTarget(c40998517.destg)
	e1:SetOperation(c40998517.desop)
	c:RegisterEffect(e1)
end
-- 作为代价候选的怪兽需满足：是「王战」怪兽或战士族怪兽，且场上还存在除它以外至少1只可被选为对象的怪兽。
function c40998517.costfilter(c,tp)
	return (c:IsSetCard(0x134) or c:IsRace(RACE_WARRIOR))
		-- 检查场上是否存在至少1只除候选解放怪兽 c 以外的可被选为对象的怪兽（保证解放后仍有对象可选）。
		and Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- SelectSubGroup的子组选择完成判断：当前已选解放组 g 必须满足场上有不少于 g:GetCount() 只不在 g 中的可破坏对象，且 g 中的卡均属于可解放组。
function c40998517.fselect(g,tp)
	-- 检查场上存在至少 g:GetCount() 只不包含在已选解放组 g 中的可被选为对象的怪兽，以满足破坏对象数量。
	return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,g:GetCount(),g)
		-- 检查已选解放组 g 的所有卡都是当前玩家可解放的卡（通过 aux.IsInGroup 调用）。
		and Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
end
-- 发动代价处理：从可解放的「王战」怪兽或战士族怪兽中任意选择至少1张解放，把实际解放数量存入效果标签，供目标选择使用。
function c40998517.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：chk==0 时，确认场上存在至少1张满足costfilter条件的可解放怪兽（即「王战」或战士族且场上还有可被选对象的怪兽）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c40998517.costfilter,1,nil,tp) end
	-- 获取当前玩家所有可解放的怪兽，并筛选出满足costfilter条件的候选组。
	local rg=Duel.GetReleaseGroup(tp):Filter(c40998517.costfilter,nil,tp)
	-- 向玩家显示『请选择要解放的卡』的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c40998517.fselect,false,1,rg:GetCount(),tp)
	-- 若存在代替解放等效果，强制使用并消耗替代解放的额外次数。
	aux.UseExtraReleaseCount(sg,tp)
	-- 将选中的怪兽组作为代价解放，返回实际解放数量并记录到效果的Label中。
	local ct=Duel.Release(sg,REASON_COST)
	e:SetLabel(ct)
end
-- 目标选择处理：根据代价解放的数量，选择相同数量的场上怪兽作为效果对象，并写入破坏相关的操作信息。
function c40998517.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	local ct=e:GetLabel()
	-- 向玩家显示『请选择要破坏的卡』的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方怪兽区选择 ct 只因上次解放的怪兽作为效果对象（SelectTarget会将所选卡登记为当前连锁的对象）。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,ct,ct,nil)
	-- 设置当前连锁的操作信息：本效果将破坏选中的 g 中的全部对象，数量为 g:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：先破坏所有仍与效果关联的对象；若有对方怪兽被破坏，则询问对方是否抽取相应数量的卡；若对方选择是则让其抽卡。
function c40998517.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁取对象的目标组，并过滤出仍然与这个效果存在关联的对象（排除已离场或关系被重置的卡）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 执行破坏；若没有任何卡被破坏成功，则直接终止后续抽卡处理。
	if Duel.Destroy(tg,REASON_EFFECT)==0 then return end
	-- 统计刚才被破坏的卡中，在破坏前由对方玩家（1-tp）操控的怪兽数量。
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsPreviousControler,nil,1-tp)
	-- 若被破坏的对方怪兽数量>0，且对方可以抽卡，则询问对方是否要抽卡（效果原文为‘可以’，故需选择）。
	if ct>0 and Duel.IsPlayerCanDraw(1-tp,ct) and Duel.SelectYesNo(1-tp,aux.Stringid(40998517,1)) then  --"是否抽卡？"
		-- 中断当前效果处理，使后续抽卡不被视为与怪兽破坏同时进行，避免影响时点判定。
		Duel.BreakEffect()
		-- 让对方玩家（1-tp）以效果原因抽 ct 张卡。
		Duel.Draw(1-tp,ct,REASON_EFFECT)
	end
end

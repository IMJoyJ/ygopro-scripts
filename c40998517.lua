--剣の王 フローディ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「剑界王战 弗罗德王」在自己场上只能有1只表侧表示存在。
-- ②：把自己场上的「王战」怪兽或者战士族怪兽任意数量解放，以那个数量的场上的怪兽为对象才能发动。那些怪兽破坏。那之后，对方可以从卡组抽出破坏的对方场上的怪兽的数量。这个效果在对方回合也能发动。
function c40998517.initial_effect(c)
	c:SetUniqueOnField(1,0,40998517)
	-- 效果原文内容：②：把自己场上的「王战」怪兽或者战士族怪兽任意数量解放，以那个数量的场上的怪兽为对象才能发动。那些怪兽破坏。那之后，对方可以从卡组抽出破坏的对方场上的怪兽的数量。这个效果在对方回合也能发动。
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
-- 检索满足条件的卡片组：必须是「王战」怪兽或战士族怪兽，并且场上至少存在1只怪兽可以成为效果对象。
function c40998517.costfilter(c,tp)
	return (c:IsSetCard(0x134) or c:IsRace(RACE_WARRIOR))
		-- 检查场上是否存在至少1只怪兽可以成为效果对象。
		and Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 筛选函数：检查是否能选择指定数量的怪兽作为效果对象，并且满足解放条件。
function c40998517.fselect(g,tp)
	-- 检查是否能选择指定数量的怪兽作为效果对象。
	return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,g:GetCount(),g)
		-- 检查是否能从场上解放指定数量的卡片。
		and Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
end
-- 效果处理：检查是否满足解放条件，选择要解放的卡片并进行解放操作。
function c40998517.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c40998517.costfilter,1,nil,tp) end
	-- 获取玩家可解放的卡片组，并筛选出符合条件的卡片。
	local rg=Duel.GetReleaseGroup(tp):Filter(c40998517.costfilter,nil,tp)
	-- 提示玩家选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=rg:SelectSubGroup(tp,c40998517.fselect,false,1,rg:GetCount(),tp)
	-- 强制使用代替解放效果次数。
	aux.UseExtraReleaseCount(sg,tp)
	-- 实际执行解放操作。
	local ct=Duel.Release(sg,REASON_COST)
	e:SetLabel(ct)
end
-- 效果处理：选择要破坏的怪兽。
function c40998517.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	local ct=e:GetLabel()
	-- 提示玩家选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择指定数量的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,ct,ct,nil)
	-- 设置效果操作信息，记录要破坏的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：执行破坏并判断是否抽卡。
function c40998517.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定效果的对象卡片组，并筛选出与当前效果相关的卡片。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 执行破坏操作。
	if Duel.Destroy(tg,REASON_EFFECT)==0 then return end
	-- 统计被破坏的对方怪兽数量。
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsPreviousControler,nil,1-tp)
	-- 判断是否可以抽卡并询问对方是否抽卡。
	if ct>0 and Duel.IsPlayerCanDraw(1-tp,ct) and Duel.SelectYesNo(1-tp,aux.Stringid(40998517,1)) then  --"是否抽卡？"
		-- 中断当前效果处理。
		Duel.BreakEffect()
		-- 对方玩家抽卡。
		Duel.Draw(1-tp,ct,REASON_EFFECT)
	end
end

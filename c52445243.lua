--トライエッジ・マスター
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡同调召唤的场合才能发动。那一组作为同调素材的怪兽的等级组合的以下效果适用。3只以上为素材的场合以下效果全部适用。
-- ●1星和5星：场上1张其他卡破坏。
-- ●2星和4星：自己抽1张。
-- ●3星和3星：这张卡当作调整使用。
function c52445243.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和任意数量的调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。那一组作为同调素材的怪兽的等级组合的以下效果适用。3只以上为素材的场合以下效果全部适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,52445243)
	e1:SetCondition(c52445243.con)
	e1:SetTarget(c52445243.tg)
	e1:SetOperation(c52445243.op)
	c:RegisterEffect(e1)
	-- ●1星和5星：场上1张其他卡破坏。●2星和4星：自己抽1张。●3星和3星：这张卡当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c52445243.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
c52445243.treat_itself_tuner=true
-- 检查同调召唤时使用的素材等级组合，根据组合设置效果标签值
function c52445243.valcheck(e,c)
	e:GetLabelObject():SetLabel(0)
	local g=c:GetMaterial()
	if #g>=3 then
		e:GetLabelObject():SetLabel(1|2|4)
		return
	end
	local b1=g:IsExists(Card.IsLevel,1,nil,1) and g:IsExists(Card.IsLevel,1,nil,5)
	local b2=g:IsExists(Card.IsLevel,1,nil,2) and g:IsExists(Card.IsLevel,1,nil,4)
	local b3=g:IsExists(Card.IsLevel,2,nil,3)
	if b1 then
		e:GetLabelObject():SetLabel(1)
	end
	if b2 then
		e:GetLabelObject():SetLabel(2)
	end
	if b3 then
		e:GetLabelObject():SetLabel(4)
	end
end
-- 判断是否为同调召唤且已设置效果标签值
function c52445243.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()~=0
end
-- 设置效果的发动条件和处理目标
function c52445243.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	-- 判断是否满足1星和5星的组合条件并检查场上是否存在可破坏的卡
	local des=ct&1>0 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
	-- 判断是否满足2星和4星的组合条件并检查玩家是否可以抽卡
	local draw=ct&2>0 and Duel.IsPlayerCanDraw(tp,1)
	local tun=ct&4>0 and not c:IsType(TYPE_TUNER)
	if chk==0 then return des or draw or tun end
	e:SetCategory(0)
	if des then
		-- 设置操作信息为破坏效果，指定目标为场上的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
		e:SetCategory(CATEGORY_DESTROY)
	end
	if draw then
		-- 设置操作信息为抽卡效果，指定目标为发动者自己
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
		e:SetCategory(e:GetCategory()|CATEGORY_DRAW)
	end
end
-- 执行效果处理，根据标签值决定执行破坏、抽卡或变为调整的效果
function c52445243.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	-- 判断是否满足1星和5星的组合条件并检查场上是否存在可破坏的卡（排除自身）
	local des=ct&1>0 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,aux.ExceptThisCard(e))
	-- 判断是否满足2星和4星的组合条件并检查玩家是否可以抽卡
	local draw=ct&2>0 and Duel.IsPlayerCanDraw(tp,1)
	local tun=ct&4>0 and not c:IsType(TYPE_TUNER) and c:IsRelateToChain() and c:IsFaceup()
	if des then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上一张其他卡作为破坏目标
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
		-- 显示选中的卡被选为对象的动画效果
		Duel.HintSelection(g)
		-- 以效果原因将选中的卡破坏
		Duel.Destroy(g,REASON_EFFECT)
		-- 如果后续有抽卡或变为调整的效果则中断当前效果处理
		if draw or tun then Duel.BreakEffect() end
	end
	if draw then
		-- 让玩家以效果原因抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
		-- 如果后续有变为调整的效果则中断当前效果处理
		if tun then Duel.BreakEffect() end
	end
	if tun then
		-- 为自身添加调整类型，使其可以作为调整使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end

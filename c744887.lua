--虚の王 ウートガルザ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「虚界王战 乌特加德王」在自己场上只能有1只表侧表示存在。
-- ②：把自己场上的「王战」怪兽或者岩石族怪兽合计2只解放，以场上1张卡为对象才能发动。那张卡除外。这个效果在对方回合也能发动。
function c744887.initial_effect(c)
	c:SetUniqueOnField(1,0,744887)
	-- ②：把自己场上的「王战」怪兽或者岩石族怪兽合计2只解放，以场上1张卡为对象才能发动。那张卡除外。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(744887,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,744887)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c744887.rmcost)
	e1:SetTarget(c744887.rmtg)
	e1:SetOperation(c744887.rmop)
	c:RegisterEffect(e1)
end
-- 过滤可作为解放代价的「王战」怪兽或岩石族怪兽
function c744887.costfilter(c)
	return c:IsSetCard(0x134) or c:IsRace(RACE_ROCK)
end
-- 检查选择的解放卡片组是否合法（即排除解放卡后场上仍有可除外对象，且所选卡片可被解放）
function c744887.fselect(g,tp)
	-- 检查在排除当前选定解放卡片后，场上是否存在至少1张可以作为除外对象的卡
	return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,g)
		-- 检查选定的卡片组是否全部属于玩家场上可解放的卡片
		and Duel.CheckReleaseGroup(tp,aux.IsInGroup,#g,nil,g)
end
-- 效果②的发动代价（Cost）处理函数
function c744887.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上所有可解放的「王战」怪兽或岩石族怪兽
	local g=Duel.GetReleaseGroup(tp):Filter(c744887.costfilter,nil)
	if chk==0 then return g:CheckSubGroup(c744887.fselect,2,2,tp) end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:SelectSubGroup(tp,c744887.fselect,false,2,2,tp)
	-- 扣除可能存在的代替解放效果的使用次数
	aux.UseExtraReleaseCount(rg,tp)
	-- 将选定的卡片作为代价解放
	Duel.Release(rg,REASON_COST)
end
-- 效果②的发动准备与目标选择（Target）处理函数
function c744887.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，表示该效果会除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果②的效果处理（Operation）函数
function c744887.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的那张卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡片以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end

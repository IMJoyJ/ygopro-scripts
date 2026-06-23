--バスター・スナイパー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。从手卡·卡组把「爆裂狙击手」以外的1只有「爆裂模式」的卡名记述的怪兽特殊召唤。这个效果发动过的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：以自己场上1只表侧表示怪兽为对象才能发动。把额外卡组1只同调怪兽给对方观看，作为对象的怪兽的种族·属性直到回合结束时变成和给人观看的怪兽相同。
function c39015.initial_effect(c)
	-- 记录此卡效果文本上记载着「爆裂模式」的卡名
	aux.AddCodeList(c,80280737)
	-- ①：把这张卡解放才能发动。从手卡·卡组把「爆裂狙击手」以外的1只有「爆裂模式」的卡名记述的怪兽特殊召唤。这个效果发动过的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39015,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,39015)
	e1:SetCost(c39015.spcost)
	e1:SetTarget(c39015.sptg)
	e1:SetOperation(c39015.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只表侧表示怪兽为对象才能发动。把额外卡组1只同调怪兽给对方观看，作为对象的怪兽的种族·属性直到回合结束时变成和给人观看的怪兽相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39015,1))  --"改变种族·属性"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,39016)
	e2:SetTarget(c39015.chtg)
	e2:SetOperation(c39015.chop)
	c:RegisterEffect(e2)
end
-- 支付效果代价：解放此卡
function c39015.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡从游戏中解放作为支付代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤的过滤函数：检查是否为「爆裂模式」的怪兽且不是此卡本身
function c39015.spfilter(c,e,tp)
	-- 检查目标是否为「爆裂模式」的怪兽且不是此卡本身
	return aux.IsCodeListed(c,80280737) and not c:IsCode(39015) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件：场上存在空怪兽区且手卡或卡组存在满足条件的怪兽
function c39015.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在空怪兽区
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查手卡或卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c39015.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息：准备特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行特殊召唤效果：选择并特殊召唤符合条件的怪兽，并设置后续限制效果
function c39015.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在空怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c39015.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置限制效果：发动①效果的回合，自己不能从额外卡组特殊召唤非同调怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c39015.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制效果注册到游戏环境
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的判断函数：禁止非同调怪兽从额外卡组特殊召唤
function c39015.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果对象的过滤函数：检查场上是否有表侧表示的怪兽且其额外卡组存在满足条件的同调怪兽
function c39015.filter(c,tp)
	-- 检查场上是否有表侧表示的怪兽且其额外卡组存在满足条件的同调怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c39015.cfilter,tp,LOCATION_EXTRA,0,1,nil,c)
end
-- 同调怪兽的过滤函数：检查是否为同调怪兽且种族或属性与目标怪兽不同
function c39015.cfilter(c,tc)
	return c:IsType(TYPE_SYNCHRO) and (not c:IsRace(tc:GetRace()) or not c:IsAttribute(tc:GetAttribute()))
end
-- 设置改变种族·属性效果的目标选择条件：选择自己场上的表侧表示怪兽
function c39015.chtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c39015.filter(chkc,tp) end
	-- 检查是否存在满足条件的怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c39015.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c39015.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 执行改变种族·属性效果：选择并确认额外卡组的同调怪兽，使对象怪兽的种族和属性变为与之相同
function c39015.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的同调怪兽
	local cg=Duel.SelectMatchingCard(tp,c39015.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,tc)
	if cg:GetCount()==0 then return end
	-- 向对方确认所选的同调怪兽
	Duel.ConfirmCards(1-tp,cg)
	local ec=cg:GetFirst()
	-- 设置改变种族效果：使对象怪兽的种族变为与确认的同调怪兽相同
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(ec:GetRace())
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(ec:GetAttribute())
	tc:RegisterEffect(e2)
end

--バスター・スナイパー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。从手卡·卡组把「爆裂狙击手」以外的1只有「爆裂模式」的卡名记述的怪兽特殊召唤。这个效果发动过的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：以自己场上1只表侧表示怪兽为对象才能发动。把额外卡组1只同调怪兽给对方观看，作为对象的怪兽的种族·属性直到回合结束时变成和给人观看的怪兽相同。
function c39015.initial_effect(c)
	-- 给「爆裂狙击手」登记卡名列表中包含「爆裂模式」(80280737)，用于之后判断这张卡的文本是否记载了该卡名。
	aux.AddCodeList(c,80280737)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把这张卡解放才能发动。从手卡·卡组把「爆裂狙击手」以外的1只有「爆裂模式」的卡名记述的怪兽特殊召唤。这个效果发动过的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
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
-- ①效果的代价函数：检查「爆裂狙击手」自身是否可作为解放代价；若可，则将其解放作为发动代价。
function c39015.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 把「爆裂狙击手」自身解放（送去墓地）作为效果的发动代价，REASON_COST表示是代价动作。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义特殊召唤的怪兽过滤函数：从手卡·卡组中找出“卡名记载了「爆裂模式」”且不是「爆裂狙击手」自身、并能被效果特殊召唤的怪兽。
function c39015.spfilter(c,e,tp)
	-- 过滤条件为：怪兽卡的效果文本中记载有「爆裂模式」(80280737)，且不是「爆裂狙击手」自身，且满足特殊召唤条件。
	return aux.IsCodeListed(c,80280737) and not c:IsCode(39015) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：解放自身后仍有可用的主要怪兽区，且手卡·卡组存在符合条件的特殊召唤候选。
function c39015.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查解放「爆裂狙击手」后自己场上是否还有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 同时检查手卡·卡组中是否存在至少1只满足特殊召唤过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c39015.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次连锁的效果信息登记为：从手卡·卡组特殊召唤1只怪兽（数量1），供其他卡牌（如「星尘龙」等）进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果处理：从手卡·卡组选1只符合条件的怪兽特殊召唤，并在这之后给发动者附加“本回合不是同调怪兽不能从额外卡组特殊召唤”的自肃。
function c39015.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己场上是否存在可用的主要怪兽区。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向操作者显示选择提示“请选择要特殊召唤的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡·卡组中选择1只符合条件的怪兽（spfilter）。
		local g=Duel.SelectMatchingCard(tp,c39015.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果发动过的回合，自己不是同调怪兽不能从额外卡组特殊召唤。②：以自己场上1只表侧表示怪兽为对象才能发动。把额外卡组1只同调怪兽给对方观看，作为对象的怪兽的种族·属性直到回合结束时变成和给人观看的怪兽相同。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c39015.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把刚创建的限制效果e1注册到场上，使其对玩家tp生效（自肃：不能从额外卡组特殊召唤非同步怪兽）。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的限制条件：从额外卡组特殊召唤的怪兽如果不是同步怪兽，则不能进行该特殊召唤。
function c39015.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的对象过滤函数：自己场上的表侧表示怪兽，并且额外卡组中存在能与其种族或属性不同的同步怪兽可供选择。
function c39015.filter(c,tp)
	-- 对象条件为：该怪兽表侧表示，且额外卡组中至少存在1只种族或属性与其不同的同步怪兽，用来改变它的种族/属性。
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c39015.cfilter,tp,LOCATION_EXTRA,0,1,nil,c)
end
-- 额外卡组候选同步怪兽的过滤条件：是同步怪兽，且种族或属性与目标怪兽至少有一项不同（这样改变才有意义）。
function c39015.cfilter(c,tc)
	return c:IsType(TYPE_SYNCHRO) and (not c:IsRace(tc:GetRace()) or not c:IsAttribute(tc:GetAttribute()))
end
-- ②效果的发动目标判定与选择：选择自己场上1只满足条件的表侧表示怪兽作为对象。
function c39015.chtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c39015.filter(chkc,tp) end
	-- 检查自己场上是否存在满足条件的表侧表示怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c39015.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 显示“请选择效果的对象”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的表侧表示怪兽作为效果对象，并自动登记为连锁对象。
	Duel.SelectTarget(tp,c39015.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- ②效果处理：确认对象仍关联且表侧表示后，从额外卡组选择1只同步怪兽给对方确认，将对象的种族和属性改变为那只同步怪兽的种族和属性，直到回合结束。
function c39015.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象怪兽（即之前选中的自己场上的表侧表示怪兽）。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 显示“请选择给对方确认的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从额外卡组选择1只符合条件的同步怪兽（种族/属性与对象不同）用于给对方确认。
	local cg=Duel.SelectMatchingCard(tp,c39015.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,tc)
	if cg:GetCount()==0 then return end
	-- 将选出的同步怪兽给对手确认。
	Duel.ConfirmCards(1-tp,cg)
	local ec=cg:GetFirst()
	-- 作为对象的怪兽的种族·属性直到回合结束时变成和给人观看的怪兽相同。
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

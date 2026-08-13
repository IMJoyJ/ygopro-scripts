--星遺物の胎導
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从手卡把1只9星怪兽特殊召唤。
-- ●以自己场上1只9星怪兽为对象才能发动。和那只怪兽是原本的种族·属性不同的2只9星怪兽从卡组特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。
function c14604710.initial_effect(c)
	-- ●从手卡把1只9星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14604710,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,14604710+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c14604710.target1)
	e1:SetOperation(c14604710.activate1)
	c:RegisterEffect(e1)
	-- ●以自己场上1只9星怪兽为对象才能发动。和那只怪兽是原本的种族·属性不同的2只9星怪兽从卡组特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽不能攻击，结束阶段破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14604710,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,14604710+EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(c14604710.target2)
	e2:SetOperation(c14604710.activate2)
	c:RegisterEffect(e2)
end
-- 定义从手卡特殊召唤的过滤器：怪兽须为9星且可以被效果特殊召唤。
function c14604710.spfilter1(c,e,tp)
	return c:IsLevel(9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件判定：自己主要怪兽区有空位，且手牌存在满足条件的9星怪兽。
function c14604710.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足等级9且可特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c14604710.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：效果处理时将把手卡的1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：选择手牌1只9星怪兽，以表侧表示特殊召唤到自己场上。
function c14604710.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 主要怪兽区没有空位时，效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择特殊召唤卡牌的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1只满足spfilter1条件的9星怪兽。
	local g=Duel.SelectMatchingCard(tp,c14604710.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 选择对象的过滤器：对象必须为表侧表示且等级9，并且卡组中存在至少2只与其原本种族、属性均不同的9星怪兽可供特殊召唤。
function c14604710.tgfilter2(c,e,tp)
	if c:IsFacedown() or not c:IsLevel(9) then return false end
	-- 获取卡组中与对象怪兽原本种族、属性不同的9星怪兽集合。
	local g=Duel.GetMatchingGroup(c14604710.spfilter2,tp,LOCATION_DECK,0,nil,e,tp,c)
	return g:GetClassCount(Card.GetCode)>1
end
-- 定义卡组特殊召唤的过滤器：9星怪兽，且原本种族、属性均与对象怪兽不同，并且可以被效果特殊召唤。
function c14604710.spfilter2(c,e,tp,tc)
	return c:IsLevel(9) and c:GetOriginalRace()~=tc:GetOriginalRace() and c:GetOriginalAttribute()~=tc:GetOriginalAttribute()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 第二个效果的发动条件：青眼精灵龙效果不在适用中、主要怪兽区空位大于1，且自己场上有符合条件的目标可选。
function c14604710.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14604710.tgfilter2(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查主要怪兽区空位是否大于1，确保能特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己场上是否存在符合条件的9星怪兽可作为对象。
		and Duel.IsExistingTarget(c14604710.tgfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只9星怪兽作为对象。
	Duel.SelectTarget(tp,c14604710.tgfilter2,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：效果处理时将自卡组特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：若条件仍满足且对象有效，选择2只卡名不同且与对象原本种族、属性不同的9星怪兽特殊召唤，并为其附加不能攻击和结束阶段破坏效果。
function c14604710.activate2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取该效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 获取自己主要怪兽区当前可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取卡组中所有满足spfilter2条件的怪兽组。
	local g=Duel.GetMatchingGroup(c14604710.spfilter2,tp,LOCATION_DECK,0,nil,e,tp,tc)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		and ft>1 and g:GetClassCount(Card.GetCode)>1 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要特殊召唤的卡牌。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从符合条件的卡组怪兽中选择2张卡名不同的卡。
		local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选择的2只怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		local fid=c:GetFieldID()
		local sc=g1:GetFirst()
		while sc do
			-- 这个效果特殊召唤的怪兽不能攻击
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
			sc:RegisterFlagEffect(14604710,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			sc=g1:GetNext()
		end
		g1:KeepAlive()
		-- 结束阶段破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCountLimit(1)
		e2:SetLabel(fid)
		e2:SetLabelObject(g1)
		e2:SetCondition(c14604710.descon)
		e2:SetOperation(c14604710.desop)
		-- 将结束阶段破坏效果注册到当前玩家场上，使其在结束阶段触发。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断怪兽是否带有本效果的特殊标记（fid），用于确定哪些怪兽需要被破坏。
function c14604710.desfilter(c,fid)
	return c:GetFlagEffectLabel(14604710)==fid
end
-- 结束阶段破坏效果的发动条件：若仍存在带有该标记的怪兽则生效，否则清理并重置效果。
function c14604710.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c14604710.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段的处理：获取所有带标记的怪兽并执行破坏。
function c14604710.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c14604710.desfilter,nil,e:GetLabel())
	-- 以效果原因将这些怪兽破坏。
	Duel.Destroy(tg,REASON_EFFECT)
end

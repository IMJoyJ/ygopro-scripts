--四天の龍 クリアウィング・シンクロ・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名在规则上也当作「疾行机人」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。对方场上1只效果怪兽破坏，这张卡的攻击力上升那个原本攻击力数值。
-- ②：对方把效果发动时才能发动。从自己的手卡·墓地把1只4星以下的风属性调整效果无效特殊召唤。那之后，可以进行1只风属性同调怪兽的同调召唤。
local s,id,o=GetID()
-- 注册卡片的效果：添加同调召唤手续并启用苏生限制；①特殊召唤成功时诱发破坏对方场上1只效果怪兽并上升其原本攻击力数值的效果，②对方发动效果时诱发即时特殊召唤自己手牌或墓地1只4星以下风属性调整且可选进行同调召唤的效果。
function s.initial_effect(c)
	-- 为当前卡片添加同调召唤的手续：需要1只调整怪兽以及1只以上调整以外的怪兽作为同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。对方场上1只效果怪兽破坏，这张卡的攻击力上升那个原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏效果"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：对方把效果发动时才能发动。从自己的手卡·墓地把1只4星以下的风属性调整效果无效特殊召唤。那之后，可以进行1只风属性同调怪兽的同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义破坏怪兽过滤函数：过滤出在对方场上表侧表示且属于效果怪兽的卡片。
function s.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 破坏效果的发动准备和检测：确认对方场上存在表侧表示的效果怪兽，设置破坏操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索对方场上所有符合过滤条件的表侧效果怪兽并放入卡片组中。
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息：包含破坏对方场上1张卡片的分类，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的实际处理过程：提示玩家，并让其选择对方场上1只效果怪兽进行破坏。若破坏成功，且该怪兽的原本攻击力在0以上，且本卡在场上表侧表示，则本卡的攻击力上升该怪兽的原本攻击力数值。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送选择提示信息：请选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上的1只符合破坏过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 手动为选中的怪兽显示被选择的动画效果，并记录其为效果影响卡片。
		Duel.HintSelection(g)
		-- 以效果原因为由破坏选中的怪兽卡片，并确认是否成功破坏。
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			local rc=g:GetFirst()
			if rc:GetTextAttack()>=0
				and c:IsRelateToChain() and c:IsFaceup() then
				-- 这张卡的攻击力上升那个原本攻击力数值。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				e1:SetValue(rc:GetTextAttack())
				c:RegisterEffect(e1)
			end
		end
	end
end
-- 特召效果的发动条件检查：确保当前发动的连锁是由对方玩家发动的效果触发。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 定义特召调整怪兽过滤函数：过滤出属于调整、等级在4星以下、属性为风属性且可以被正常特殊召唤的卡片。
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特召效果的发动准备和检测：确认自己怪兽区域有空位，且手牌或墓地中存在符合特召过滤条件的风属性调整，设置特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为效果发动检测，确认自己主要怪兽区域是否还有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手牌和墓地中是否至少存在1只符合特殊召唤条件的风属性调整怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：包含特殊召唤1只怪兽的分类，数量为1，目标区域为手牌和墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 定义同调怪兽过滤函数：过滤出属于风属性的同调怪兽，且可以使用当前场上的怪兽作为素材对其进行合法的同调召唤。
function s.syncfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO) and c:IsSynchroSummonable(nil)
end
-- 特召效果的实际处理过程：检查区域空位后，提示玩家，并让其从手牌或墓地选择1只符合条件的风属性调整怪兽以效果无效的表侧形式特殊召唤。随后，若存在风属性同调怪兽可以进行同调召唤，询问玩家是否进行同调召唤。若是，则中断效果并让玩家选择风属性同调怪兽进行同调召唤手续。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自己主要怪兽区域可用的空格数大于等于1，否则直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向玩家发送选择提示信息：请选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌和墓地中选择1张不受王家长眠之谷影响的、符合特殊召唤条件的风属性调整怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		-- 以表侧表示的形式将该调整怪兽卡片特殊召唤到玩家场上（不完成最后的结算）。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成对上述进行的特殊召唤步骤的最终结算处理。
		Duel.SpecialSummonComplete()
		-- 手动立即刷新并更新场上所有卡片的状态信息。
		Duel.AdjustAll()
		-- 判断额外卡组中是否存在可同调召唤的风属性同调怪兽，并询问玩家是否需要进行同调召唤。
		if Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_EXTRA,0,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否同调召唤？"
			-- 中断当前的特殊召唤效果处理，使得特殊召唤操作与后续的同调召唤操作不同时进行（会使时点错开）。
			Duel.BreakEffect()
			-- 向玩家发送选择提示信息：请选择要特殊召唤的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从额外卡组中选择1张符合同调过滤条件的同调怪兽卡片。
			local g=Duel.SelectMatchingCard(tp,s.syncfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
			-- 以自己场上的怪兽为素材，让玩家对选中的同调怪兽进行同调召唤手续。
			Duel.SynchroSummon(tp,g:GetFirst(),nil)
		end
	end
end

--ギャラクリボー
-- 效果：
-- ①：对方怪兽的攻击宣言时，把这张卡从手卡丢弃才能发动。从手卡·卡组把1只「银河眼光子龙」特殊召唤。那之后，攻击对象转移为那只怪兽。并且，可以再选自己或者对方场上1只超量怪兽把墓地的这张卡在那只怪兽下面重叠作为超量素材。
-- ②：自己场上的「光子」怪兽或者「银河」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c46261704.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时，把这张卡从手卡丢弃才能发动。从手卡·卡组把1只「银河眼光子龙」特殊召唤。那之后，攻击对象转移为那只怪兽。并且，可以再选自己或者对方场上1只超量怪兽把墓地的这张卡在那只怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46261704,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c46261704.spcon)
	e1:SetCost(c46261704.spcost)
	e1:SetTarget(c46261704.sptg)
	e1:SetOperation(c46261704.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「光子」怪兽或者「银河」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c46261704.reptg)
	e2:SetValue(c46261704.repval)
	e2:SetOperation(c46261704.repop)
	c:RegisterEffect(e2)
end
-- 诱发选发效果的发动条件：仅在对方操作怪兽进行攻击宣言时，该效果才满足发动条件。
function c46261704.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认攻击宣言的怪兽是对方操控（控制者为1-tp），以此限定『对方怪兽的攻击宣言时』。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 发动COST的检测与执行：效果发动时，判定手卡的此卡可否丢弃；确定发动后，把此卡从手卡丢弃并送去墓地作为发动代价。
function c46261704.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 把此卡从手卡丢弃并送入墓地，作为效果发动所需的COST（丢弃+代价）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 特殊召唤对象的筛选条件：被选卡必须是「银河眼光子龙」（卡号93717133），并且可以被当前效果以表侧表示特殊召唤到我方场上。
function c46261704.spfilter(c,e,tp)
	return c:IsCode(93717133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标的合法检查：确认我方主要怪兽区有空位，且手卡·卡组中存在至少1只符合条件的「银河眼光子龙」可供特殊召唤。
function c46261704.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有可以用于特殊召唤的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在至少1只满足条件的「银河眼光子龙」；两者同时满足，效果才可发动。
		and Duel.IsExistingMatchingCard(c46261704.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 将已经作为代价送去墓地的此卡登记为当前连锁的对象（用于后续关联判定，比如能否作为超量素材）。
	Duel.SetTargetCard(e:GetHandler())
	-- 登记操作信息：本次效果预定从手卡·卡组特殊召唤1只怪兽（用于星尘龙等卡的连锁检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 超量素材选择对象的筛选条件：场上表侧表示的超量怪兽。
function c46261704.mfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- 效果处理流程：先从手卡·卡组特殊召唤「银河眼光子龙」，成功后若攻击怪兽可攻击且不免疫此效果，则将攻击对象转移给它；随后可选择场上1只表侧超量怪兽，把墓地的此卡重叠为超量素材。
function c46261704.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次检查我方主要怪兽区是否存在空格，若没有则本次特殊召唤不能进行，直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 给出提示文字：请选择要特殊召唤的卡（用于选择卡片时的消息显示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选择1只符合条件的「银河眼光子龙」作为特殊召唤对象。
	local tc=Duel.SelectMatchingCard(tp,c46261704.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	-- 若成功选择了「银河眼光子龙」并特殊召唤成功，且它仍在主要怪兽区，则继续后续处理；否则不再处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsLocation(LOCATION_MZONE) then
		-- 取得当前进行攻击宣言的对方怪兽，用于后续把攻击对象转移给特殊召唤的「银河眼光子龙」。
		local a=Duel.GetAttacker()
		if a:IsAttackable() and not a:IsImmuneToEffect(e) then
			-- 中断当前效果处理，使随后的处理视为新的独立动作，以产生正确时点。
			Duel.BreakEffect()
			-- 检索双方场上所有表侧表示的超量怪兽，作为之后可能把此卡重叠为素材的候选。
			local mg=Duel.GetMatchingGroup(c46261704.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
			-- 若攻击对象成功转移为特殊召唤的怪兽，且场上存在可选超量怪兽，才进入后续超量素材重叠选择。
			if Duel.ChangeAttackTarget(tc) and mg:GetCount()>0
				-- 追加判定：此卡仍与当前连锁相关、位于墓地且不受王家长眠之谷影响，才能把墓地的此卡作为超量素材。
				and c:IsRelateToChain() and c:IsLocation(LOCATION_GRAVE) and aux.NecroValleyFilter()(c)
				-- 确认此卡可以作为超量素材，并询问玩家是否选择超量怪兽把此卡作为超量素材；玩家同意后才继续。
				and c:IsCanOverlay() and Duel.SelectYesNo(tp,aux.Stringid(46261704,2)) then  --"是否选超量怪兽把这张卡作为超量素材？"
				-- 再次中断效果处理，把选择超量怪兽并叠放素材作为独立步骤处理。
				Duel.BreakEffect()
				-- 提示玩家选择场上表侧表示的超量怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
				local sc=mg:Select(tp,1,1,nil):GetFirst()
				if not sc:IsImmuneToEffect(e) then
					-- 把从墓地选中的此卡叠放在所选超量怪兽下面，成为其超量素材。
					Duel.Overlay(sc,Group.FromCards(c))
				end
			end
		end
	end
end
-- 代替破坏效果的适用对象：自己场上表侧表示的「光子」或「银河」怪兽，正要被战斗或对方效果破坏，且不是由代替效果导致的破坏。
function c46261704.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsSetCard(0x55,0x7b)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的触发判定与玩家选择：墓地此卡可除外，且存在符合条件将要被破坏的怪兽时，向玩家询问是否使用此卡代替破坏。
function c46261704.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c46261704.repfilter,1,nil,tp) end
	-- 用墓地此卡发动代替破坏的确认询问（效果提示编号96）。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 作为EFFECT_DESTROY_REPLACE的判定函数：对每一只将被破坏的怪兽，判断其是否符合用此卡代替破坏的条件。
function c46261704.repval(e,c)
	return c46261704.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的实际处理：将墓地中的此卡除外，以此作为代替破坏动作。
function c46261704.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 把墓地中的此卡除外（代替原本会发生的破坏）。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

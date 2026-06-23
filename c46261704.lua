--ギャラクリボー
-- 效果：
-- ①：对方怪兽的攻击宣言时，把这张卡从手卡丢弃才能发动。从手卡·卡组把1只「银河眼光子龙」特殊召唤。那之后，攻击对象转移为那只怪兽。并且，可以再选自己或者对方场上1只超量怪兽把墓地的这张卡在那只怪兽下面重叠作为超量素材。
-- ②：自己场上的「光子」怪兽或者「银河」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c46261704.initial_effect(c)
	-- 创建一个诱发效果，对方怪兽攻击宣言时可以发动。
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
	-- 创建一个永续效果，当自己场上的「光子」或「银河」怪兽被战斗或对方的效果破坏时，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c46261704.reptg)
	e2:SetValue(c46261704.repval)
	e2:SetOperation(c46261704.repop)
	c:RegisterEffect(e2)
end
-- 效果条件：攻击方不是自己。
function c46261704.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击方是否不是自己。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 效果代价：将此卡从手卡丢弃。
function c46261704.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡送去墓地作为发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 特殊召唤的过滤器，用于筛选「银河眼光子龙」。
function c46261704.spfilter(c,e,tp)
	return c:IsCode(93717133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标：检查是否有满足条件的「银河眼光子龙」可特殊召唤。
function c46261704.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在「银河眼光子龙」。
		and Duel.IsExistingMatchingCard(c46261704.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置此卡为效果对象。
	Duel.SetTargetCard(e:GetHandler())
	-- 设置操作信息：特殊召唤1只「银河眼光子龙」。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 超量怪兽的过滤器，用于筛选场上表侧表示的超量怪兽。
function c46261704.mfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- 效果处理：特殊召唤「银河眼光子龙」并转移攻击对象，可选择是否将此卡作为超量素材。
function c46261704.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有足够的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的「银河眼光子龙」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组中选择1只「银河眼光子龙」进行特殊召唤。
	local tc=Duel.SelectMatchingCard(tp,c46261704.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	-- 若成功特殊召唤且该怪兽在场上，则继续处理后续效果。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsLocation(LOCATION_MZONE) then
		-- 获取当前攻击的怪兽。
		local a=Duel.GetAttacker()
		if a:IsAttackable() and not a:IsImmuneToEffect(e) then
			-- 中断当前连锁，使之后的效果视为错时点处理。
			Duel.BreakEffect()
			-- 获取自己场上的所有表侧表示的超量怪兽。
			local mg=Duel.GetMatchingGroup(c46261704.mfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
			-- 尝试将攻击对象转移为特殊召唤出的「银河眼光子龙」。
			if Duel.ChangeAttackTarget(tc) and mg:GetCount()>0
				-- 判断此卡是否与当前连锁相关且在墓地，且不受王家长眠之谷影响。
				and c:IsRelateToChain() and c:IsLocation(LOCATION_GRAVE) and aux.NecroValleyFilter()(c)
				-- 判断此卡是否可以作为超量素材，并询问玩家是否发动该效果。
				and c:IsCanOverlay() and Duel.SelectYesNo(tp,aux.Stringid(46261704,2)) then  --"是否选超量怪兽把这张卡作为超量素材？"
				-- 再次中断当前连锁，使之后的效果视为错时点处理。
				Duel.BreakEffect()
				-- 提示玩家选择要叠放的超量怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
				local sc=mg:Select(tp,1,1,nil):GetFirst()
				if not sc:IsImmuneToEffect(e) then
					-- 将此卡叠放在选中的超量怪兽下面作为超量素材。
					Duel.Overlay(sc,Group.FromCards(c))
				end
			end
		end
	end
end
-- 破坏代替效果的过滤器，用于筛选自己场上的「光子」或「银河」怪兽。
function c46261704.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsSetCard(0x55,0x7b)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否可以发动破坏代替效果。
function c46261704.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c46261704.repfilter,1,nil,tp) end
	-- 询问玩家是否发动此卡的效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 返回破坏代替效果的值。
function c46261704.repval(e,c)
	return c46261704.repfilter(c,e:GetHandlerPlayer())
end
-- 效果处理：将此卡从墓地除外。
function c46261704.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡从墓地除外作为代替效果。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

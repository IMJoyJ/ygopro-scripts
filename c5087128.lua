--シェルヴァレット・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，选和这张卡存在过的区域相同纵列1只怪兽破坏，那些相邻区域有怪兽存在的场合，那些也破坏。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「霰弹弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
function c5087128.initial_effect(c)
	-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，选和这张卡存在过的区域相同纵列1只怪兽破坏，那些相邻区域有怪兽存在的场合，那些也破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5087128,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,5087128)
	e1:SetCondition(c5087128.descon)
	e1:SetTarget(c5087128.destg)
	e1:SetOperation(c5087128.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「霰弹弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c5087128.regop)
	c:RegisterEffect(e2)
end
-- 判定①效果的发动条件：当前连锁的效果必须是取对象效果且对象中包含这张卡，并且该效果是由连接怪兽发动的效果。
function c5087128.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得当前连锁效果的对象卡组，用于判断这张卡是否被该效果选为对象。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- 过滤函数：判断候选卡是否属于指定集合g，这里用于筛选出这张卡同一纵列中的卡。
function c5087128.desfilter(c,g)
	return g:IsContains(c)
end
-- 过滤函数：判断候选怪兽是否位于主怪兽区、与指定纵列序号相邻，并且控制者与指定玩家相同，用于找出被选中怪兽相邻区域的怪兽。
function c5087128.desfilter2(c,s,tp)
	local seq=c:GetSequence()
	return seq<5 and math.abs(seq-s)==1 and c:IsControler(tp)
end
-- ①效果的发动目标判定与操作信息设定：确认这张卡可破坏且同一纵列存在可选怪兽，并预设后续破坏这张卡及可能送去墓地的信息。
function c5087128.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取场上与这张卡处于同一纵列的所有怪兽，作为选择“同一纵列的怪兽”的候选集合。
	local g=Duel.GetMatchingGroup(c5087128.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c:GetColumnGroup())
	if chk==0 then return c:IsDestructable() and g:GetCount()>0 end
	-- 向系统预宣告本次效果会破坏这张卡（数量1），供连锁和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 向系统预宣告本次效果可能将同一纵列中选出的怪兽送去墓地，这里用送去墓地标识配合破坏后的移动。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 处理①效果：先破坏这张卡；若破坏成功，则从这张卡原本所在纵列当前剩余的怪兽中选择1只（超过1只时由玩家选择）破坏，并且如果被选中的怪兽有相邻区域的同控制者怪兽，将这些相邻怪兽也破坏。
function c5087128.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=c:GetColumnGroup()
	-- 确认这张卡在效果处理时仍与效果关联，且自身被效果破坏成功，才继续后续的纵列怪兽破坏处理。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 重新获取这张卡原本所在纵列上当前存在的怪兽（这张卡已破坏，所以只剩同列其他怪兽），作为“选1只怪兽破坏”的候选。
		local g=Duel.GetMatchingGroup(c5087128.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,lg)
		if g:GetCount()==0 then return end
		-- 中断当前连锁的效果处理，使“这张卡破坏”和后续的“选择纵列怪兽破坏”被视为不同时点的处理。
		Duel.BreakEffect()
		local tc=nil
		if g:GetCount()==1 then
			tc=g:GetFirst()
		else
			-- 给当前玩家显示“请选择要破坏的卡”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			tc=g:Select(tp,1,1,nil):GetFirst()
		end
		local seq=tc:GetSequence()
		local dg=Group.CreateGroup()
		-- 如果被选中的怪兽在主怪兽区，则获取它左右相邻区域中由同一控制者控制的怪兽，作为之后要一并破坏的对象。
		if seq<5 then dg=Duel.GetMatchingGroup(c5087128.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil,seq,tc:GetControler()) end
		-- 被选中的怪兽被效果破坏成功，并且存在相邻怪兽时，才进入相邻怪兽的破坏处理。
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and dg:GetCount()>0 then
			-- 将之前筛选出的相邻区域的怪兽全部破坏。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
-- 在卡片因战斗或效果被破坏并送去墓地时，检查是否满足②效果的条件；若满足，则在墓地注册一个结束阶段发动的特殊召唤效果。
function c5087128.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「霰弹弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(5087128,1))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,5087129)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c5087128.sptg)
		e1:SetOperation(c5087128.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数：判断卡组中的卡是否为「弹丸」怪兽、不是「霰弹弹丸龙」本身，并且可以被当前效果特殊召唤。
function c5087128.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and not c:IsCode(5087128) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件判定：自己场上有可用的主要怪兽区空位，并且卡组中存在符合条件的「弹丸」怪兽可供特殊召唤。
function c5087128.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动判定时检查自己场上是否有可用的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在至少1张符合条件的「弹丸」怪兽（不能是「霰弹弹丸龙」自身）可供特殊召唤。
		and Duel.IsExistingMatchingCard(c5087128.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统预宣告本次效果需要从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理②效果：从卡组选择1只符合条件的「弹丸」怪兽，以表侧表示特殊召唤到自己的主要怪兽区。
function c5087128.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己场上是否有可用主要怪兽区空位，若没有则效果无法处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给当前玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 当前玩家从卡组选择1张符合条件的「弹丸」怪兽。
	local g=Duel.SelectMatchingCard(tp,c5087128.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「弹丸」怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

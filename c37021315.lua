--泥岩の霊長－マンドストロング
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
-- ②：盖放的这张卡被对方的效果破坏送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。那之后，可以从自己墓地选「泥岩灵长-强壮泥岩山魈」以外的1只怪兽加入手卡。
function c37021315.initial_effect(c)
	-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被对方的效果破坏送去墓地的回合的结束阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c37021315.regcon)
	e2:SetOperation(c37021315.regop)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：盖放的这张卡被对方的效果破坏送去墓地的回合的结束阶段才能发动。这张卡特殊召唤。那之后，可以从自己墓地选「泥岩灵长-强壮泥岩山魈」以外的1只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37021315,0))  --"这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,37021315)
	e3:SetCondition(c37021315.spcon)
	e3:SetTarget(c37021315.sptg)
	e3:SetOperation(c37021315.spop)
	c:RegisterEffect(e3)
end
-- 判定这张卡是否满足②的触发条件：此前在场上且为里侧表示，因对方发动的效果被破坏并送去墓地，且破坏前控制权在自己场上、该效果的发动者是对方。
function c37021315.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and rp==1-tp
end
-- 给这张卡注册一个标记，记录它本回合已经因对方效果被破坏送去墓地；该标记会在离开场地/回合结束等标准重置时机后清除，供结束阶段判断②能否发动。
function c37021315.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(37021315,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查这张卡是否带有上述标记，若带有标记则说明本回合满足被对方效果破坏送墓的条件，从而允许在结束阶段发动②。
function c37021315.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(37021315)>0
end
-- 效果发动时的合法性检查：自己的主要怪兽区存在可用空格，并且这张卡可以以表侧表示被特殊召唤（不检查召唤条件/苏生限制）；满足则返回true。
function c37021315.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否有空位，以保证特殊召唤有可用区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁的操作信息设定为特殊召唤，指定对象为这张卡（数量1），以便其他卡能正确响应/检测该特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 检索/选择用过滤器：目标是墓地中的怪兽，能够加入手卡，且卡名不是「泥岩灵长-强壮泥岩山魈」本身，对应可加入手卡的对象。
function c37021315.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(37021315)
end
-- 效果处理：若这张卡仍与效果关联且特殊召唤成功，在墓地存在符合条件的其他怪兽时，询问玩家是否进行追加处理；若选择是，则中断效果处理，选择1只怪兽加入手卡并向对方展示。
function c37021315.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍然与效果相关（没有被中途移走），并成功以表侧表示特殊召唤到自己场上（返回特殊召唤成功数量不为0）。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查墓地中是否存在1张以上符合过滤器（且不受王家长眠之谷影响）的怪兽，作为是否允许选择加入手卡的前提条件。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c37021315.cfilter),tp,LOCATION_GRAVE,0,1,nil)
		-- 弹出是/否选择，让玩家决定是否要执行“从自己墓地选1只怪兽加入手卡”的后续效果。
		and Duel.SelectYesNo(tp,aux.Stringid(37021315,1)) then  --"是否从墓地把怪兽加入手卡？"
		-- 中断当前效果链的处理，使特殊召唤和后续的回手处理变成不同时处理，避免错误时点/漏掉时点。
		Duel.BreakEffect()
		-- 显示选择提示：请选择要加入手牌的卡（HINTMSG_ATOHAND），供后续选择卡片时使用。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己墓地选择1只符合条件的怪兽（加入了王家长眠之谷过滤），作为要加入手卡的对象。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c37021315.cfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选择的怪兽加入其持有者的手卡（根据效果处理），完成“从自己墓地选1只怪兽加入手卡”。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认，符合公开信息的要求。
		Duel.ConfirmCards(1-tp,g)
	end
end

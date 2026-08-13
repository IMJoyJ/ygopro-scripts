--バージェストマ・カンブロラスター
-- 效果：
-- 「伯吉斯异兽」怪兽2只
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：场上的这张卡不受其他怪兽的效果影响。
-- ②：以魔法与陷阱区域盖放的1张卡为对象才能发动。那张卡送去墓地，从卡组选1张「伯吉斯异兽」陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
-- ③：自己场上盖放的卡被效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
function c36346532.initial_effect(c)
	-- 以「伯吉斯异兽」怪兽2只为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xd4),2,2)
	c:EnableReviveLimit()
	-- ①：场上的这张卡不受其他怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c36346532.efilter)
	c:RegisterEffect(e1)
	-- ②：以魔法与陷阱区域盖放的1张卡为对象才能发动。那张卡送去墓地，从卡组选1张「伯吉斯异兽」陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36346532,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,36346532)
	e2:SetTarget(c36346532.settg)
	e2:SetOperation(c36346532.setop)
	c:RegisterEffect(e2)
	-- ③：自己场上盖放的卡被效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetCountLimit(1,36346533)
	e3:SetTarget(c36346532.desreptg)
	e3:SetValue(c36346532.desrepval)
	e3:SetOperation(c36346532.desrepop)
	c:RegisterEffect(e3)
end
-- 免疫判定条件：来自其他怪兽的效果且效果发动者不是这张卡自身时，使这张卡不受该效果影响。
function c36346532.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER) and re:GetOwner()~=e:GetOwner()
end
-- 筛选②效果的对象：魔陷区里侧盖放、可送墓、送墓后场上有空格，且卡组中存在可盖放的「伯吉斯异兽」陷阱卡。
function c36346532.cfilter(c,tp)
	-- 对象需位于主要魔陷区（非场地格）、里侧表示、能被效果送去墓地，且该卡离场后自己魔陷区仍有空位。
	return c:GetSequence()<5 and c:IsFacedown() and c:IsAbleToGrave() and Duel.GetSZoneCount(tp,c)>0
		-- 确认卡组中存在至少1张符合条件的「伯吉斯异兽」陷阱卡可供盖放。
		and Duel.IsExistingMatchingCard(c36346532.setfilter,tp,LOCATION_DECK,0,1,nil,c,tp)
end
-- 筛选可从卡组盖放的「伯吉斯异兽」陷阱卡；若对象卡不在自己场上或由对方控制，则按普通规则盖放，否则按允许当回合发动的形式盖放。
function c36346532.setfilter(c,mc,tp)
	if not (c:IsSetCard(0xd4) and c:IsType(TYPE_TRAP)) then return false end
	if not mc or mc:IsControler(1-tp) then
		return c:IsSSetable()
	else
		return c:IsSSetable(true)
	end
end
-- ②效果发动时的目标选择处理：选择魔陷区1张里侧盖放的卡作为对象，并登记送去墓地的操作信息。
function c36346532.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c36346532.cfilter(chkc,tp) end
	-- 发动合法性检查：场上是否存在满足cfilter条件的卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c36346532.cfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,tp) end
	-- 向玩家显示“请选择要送去墓地的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从双方魔陷区选择1张满足cfilter的里侧盖放卡作为效果对象。
	local g=Duel.SelectTarget(tp,c36346532.cfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,tp)
	-- 将选择的对象登记为要送去墓地的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ②效果处理：把对象卡送去墓地，从卡组选1张「伯吉斯异兽」陷阱卡盖放，并使其在盖放回合也能发动。
function c36346532.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联，且已被成功送去墓地，才继续执行盖放处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 向玩家显示“请选择要盖放的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组选择1张满足setfilter条件的「伯吉斯异兽」陷阱卡。
		local g=Duel.SelectMatchingCard(tp,c36346532.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		local sc=g:GetFirst()
		-- 若成功将选择的陷阱卡盖放到自己场上，则继续赋予其当回合可发动的效果。
		if sc and Duel.SSet(tp,sc)~=0 then
			-- 这个效果盖放的卡在盖放的回合也能发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(36346532,1))  --"适用「伯吉斯异兽·寒武耙虾」的效果来发动"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
		end
	end
end
-- ③效果代替破坏的判定条件：破坏对象是自己场上里侧表示的卡，破坏原因为效果，且不是由代替破坏产生。
function c36346532.repfilter(c,tp)
	return c:IsFacedown() and c:IsControler(tp) and c:IsOnField() and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ③效果的触发判断：存在满足条件的将被效果破坏的卡，自身可除外，并询问玩家是否发动代替除外。
function c36346532.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c36346532.repfilter,1,c,tp) and c:IsAbleToRemove() and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 让玩家选择是否发动代替除外效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 作为代替破坏的Value函数，判断每张被破坏的卡是否满足代替条件。
function c36346532.desrepval(e,c)
	return c36346532.repfilter(c,e:GetHandlerPlayer())
end
-- ③效果处理：将这张卡除外，代替那些卡的破坏。
function c36346532.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡从场上或墓地以表侧表示除外，作为破坏的代替处理。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end

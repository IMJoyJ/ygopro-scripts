--バージェストマ・カンブロラスター
-- 效果：
-- 「伯吉斯异兽」怪兽2只
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：场上的这张卡不受其他怪兽的效果影响。
-- ②：以魔法与陷阱区域盖放的1张卡为对象才能发动。那张卡送去墓地，从卡组选1张「伯吉斯异兽」陷阱卡在自己场上盖放。这个效果盖放的卡在盖放的回合也能发动。
-- ③：自己场上盖放的卡被效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
function c36346532.initial_effect(c)
	-- 连接召唤手续：使用至少2个且至多2个满足「伯吉斯异兽」连接素材条件的怪兽作为连接素材进行连接召唤
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
-- 效果过滤函数：当其他怪兽的效果发动时，若该效果的发动者不是自己，则该效果无效
function c36346532.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER) and re:GetOwner()~=e:GetOwner()
end
-- 目标过滤函数：判断目标是否为盖放于魔法与陷阱区域且满足条件的卡（包括是否能被送去墓地、是否能进行盖放操作）
function c36346532.cfilter(c,tp)
	-- 目标过滤函数：判断目标是否为盖放于魔法与陷阱区域且满足条件的卡（包括是否能被送去墓地、是否能进行盖放操作）
	return c:GetSequence()<5 and c:IsFacedown() and c:IsAbleToGrave() and Duel.GetSZoneCount(tp,c)>0
		-- 目标过滤函数：判断目标是否为盖放于魔法与陷阱区域且满足条件的卡（包括是否能被送去墓地、是否能进行盖放操作）
		and Duel.IsExistingMatchingCard(c36346532.setfilter,tp,LOCATION_DECK,0,1,nil,c,tp)
end
-- 盖放卡过滤函数：判断是否为「伯吉斯异兽」陷阱卡，并根据是否为对象卡决定是否能盖放
function c36346532.setfilter(c,mc,tp)
	if not (c:IsSetCard(0xd4) and c:IsType(TYPE_TRAP)) then return false end
	if not mc or mc:IsControler(1-tp) then
		return c:IsSSetable()
	else
		return c:IsSSetable(true)
	end
end
-- 效果处理函数：设置效果目标，选择魔法与陷阱区域盖放的卡作为对象
function c36346532.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c36346532.cfilter(chkc,tp) end
	-- 效果处理函数：设置效果目标，选择魔法与陷阱区域盖放的卡作为对象
	if chk==0 then return Duel.IsExistingTarget(c36346532.cfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,tp) end
	-- 效果处理函数：提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 效果处理函数：选择魔法与陷阱区域盖放的卡作为对象
	local g=Duel.SelectTarget(tp,c36346532.cfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,tp)
	-- 效果处理函数：设置操作信息，记录将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果处理函数：执行效果操作，将目标卡送去墓地并从卡组选择陷阱卡盖放
function c36346532.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理函数：获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 效果处理函数：判断目标卡是否有效并执行送去墓地操作
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 效果处理函数：提示玩家选择要盖放的陷阱卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 效果处理函数：从卡组中选择一张「伯吉斯异兽」陷阱卡
		local g=Duel.SelectMatchingCard(tp,c36346532.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		local sc=g:GetFirst()
		-- 效果处理函数：将选中的陷阱卡盖放
		if sc and Duel.SSet(tp,sc)~=0 then
			-- 效果处理函数：为盖放的陷阱卡添加效果，使其在盖放的回合也能发动
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
-- 代替破坏过滤函数：判断目标卡是否为盖放于场上的卡且因效果破坏
function c36346532.repfilter(c,tp)
	return c:IsFacedown() and c:IsControler(tp) and c:IsOnField() and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏处理函数：判断是否满足代替破坏条件并提示玩家选择是否发动
function c36346532.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c36346532.repfilter,1,c,tp) and c:IsAbleToRemove() and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 代替破坏处理函数：提示玩家选择是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏值函数：返回是否满足代替破坏条件
function c36346532.desrepval(e,c)
	return c36346532.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏操作函数：将自身从场上除外
function c36346532.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 代替破坏操作函数：将自身从场上除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end

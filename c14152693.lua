--月光翠鳥
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从手卡把1张「月光」卡送去墓地，自己抽1张。
-- ②：这张卡被效果送去墓地的场合，以除「月光翠鸟」外的自己的墓地·除外状态的1只4星以下的「月光」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c14152693.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从手卡把1张「月光」卡送去墓地，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14152693,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,14152693)
	e1:SetTarget(c14152693.drtg)
	e1:SetOperation(c14152693.drop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果送去墓地的场合，以除「月光翠鸟」外的自己的墓地·除外状态的1只4星以下的「月光」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(14152693,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,14152694)
	e3:SetCondition(c14152693.spcon)
	e3:SetTarget(c14152693.sptg)
	e3:SetOperation(c14152693.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断手卡中是否存在「月光」卡且可以送去墓地
function c14152693.tgfilter(c)
	return c:IsSetCard(0xdf) and c:IsAbleToGrave()
end
-- 效果处理时的处理函数，用于设置效果发动时的处理目标和操作信息
function c14152693.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查玩家手卡中是否存在满足条件的「月光」卡
		and Duel.IsExistingMatchingCard(c14152693.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息，表示将要从手卡送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息，表示将要进行抽卡操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时的处理函数，用于执行效果的具体操作
function c14152693.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的1张手卡「月光」卡
	local g=Duel.SelectMatchingCard(tp,c14152693.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 判断是否成功将卡送去墓地且在墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 执行抽卡操作
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断墓地或除外区中是否存在满足条件的「月光」怪兽
function c14152693.spfilter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsLevelBelow(4) and c:IsSetCard(0xdf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(14152693)
end
-- 条件函数，判断此卡是否因效果被送去墓地
function c14152693.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 效果处理时的处理函数，用于设置效果发动时的处理目标和操作信息
function c14152693.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c14152693.spfilter(chkc,e,tp) end
	-- 检查玩家场上是否有可用的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地或除外区是否存在满足条件的「月光」怪兽
		and Duel.IsExistingTarget(c14152693.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的1只「月光」怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c14152693.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时的处理函数，用于执行效果的具体操作
function c14152693.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 创建一个使特殊召唤怪兽效果无效化的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 创建一个使特殊召唤怪兽的怪兽效果无效化的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤操作
	Duel.SpecialSummonComplete()
end

--月光翠鳥
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从手卡把1张「月光」卡送去墓地，自己抽1张。
-- ②：这张卡被效果送去墓地的场合，以除「月光翠鸟」外的自己的墓地·除外状态的1只4星以下的「月光」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c14152693.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从手卡把1张「月光」卡送去墓地，自己抽1张。（这里以“召唤成功时”触发效果注册。）
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
-- 该过滤函数用于选择手卡中1张能够送去墓地的「月光」卡。
function c14152693.tgfilter(c)
	return c:IsSetCard(0xdf) and c:IsAbleToGrave()
end
-- ①效果发动时点检查发动条件：自己可以抽1张卡，且手卡存在符合条件的「月光」卡。
function c14152693.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以进行抽卡，作为①效果的发动条件之一。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查手卡是否存在1张可作为①效果COST送去墓地的「月光」卡。
		and Duel.IsExistingMatchingCard(c14152693.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置本次连锁包含“送去墓地”的操作信息，使其他卡能对此效果作出响应。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置本次连锁包含“抽卡”的操作信息，指定抽1张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果处理：从手卡选择1张「月光」卡送去墓地，成功送去墓地后自己抽1张。
function c14152693.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让玩家选择要送去墓地的「月光」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选出1张满足tgfilter条件的「月光」卡。
	local g=Duel.SelectMatchingCard(tp,c14152693.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 当确实选到了卡且效果成功将其送去墓地，并且该卡仍在墓地时才继续抽卡。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 自己抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- ②效果的对象筛选条件：位于自己墓地或表侧除外状态、4星以下、不是「月光翠鸟」、可以被特殊召唤为表侧守备表示的「月光」怪兽。
function c14152693.spfilter(c,e,tp)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsLevelBelow(4) and c:IsSetCard(0xdf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(14152693)
end
-- ②效果的发动条件：这张卡是被“效果”送去墓地的场合（REASON_EFFECT）。
function c14152693.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- ②效果发动时选择对象：从自己墓地或除外区选择1只符合条件的「月光」怪兽作为对象，且自己场上要有可用怪兽区。
function c14152693.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c14152693.spfilter(chkc,e,tp) end
	-- 发动条件之一：自己场上存在可以特殊召唤的怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己墓地或除外区存在1只可特殊召唤且符合条件的「月光」怪兽，并能成为对象。
		and Duel.IsExistingTarget(c14152693.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 显示选择提示，让玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地或除外区选择1只符合条件的「月光」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c14152693.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置本次连锁包含“特殊召唤”的操作信息，并指定对象为已选择的g。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将对象怪兽以表侧守备表示特殊召唤，并对其施加“效果无效化”效果。
function c14152693.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍然与效果关联后，将其以表侧守备表示作为特殊召唤的第一步进行处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽的效果无效化。（赋予EFFECT_DISABLE，使怪兽在场上的效果无效。）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。（赋予EFFECT_DISABLE_EFFECT，使其发动的效果也被无效化。）
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤处理，使通过SpecialSummonStep进行的特殊召唤最终成立。
	Duel.SpecialSummonComplete()
end

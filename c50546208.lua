--月光黄鼬
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以「月光黄鼬」以外的自己场上1张「月光」卡为对象才能发动。那张卡回到手卡，这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把1张「月光」魔法·陷阱卡加入手卡。
function c50546208.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，以「月光黄鼬」以外的自己场上1张「月光」卡为对象才能发动。那张卡回到手卡，这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50546208,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,50546208)
	e1:SetTarget(c50546208.sptg)
	e1:SetOperation(c50546208.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把1张「月光」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50546208,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,50546209)
	e2:SetCondition(c50546208.thcon)
	e2:SetTarget(c50546208.thtg)
	e2:SetOperation(c50546208.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判定场上的一张「月光」卡能否作为①效果的对象；条件为表侧表示、属于「月光」字段、不是本卡（月光黄鼬）、能被返回手牌，并且该卡返回手牌后自己场上仍有空余的怪兽区用于特殊召唤本卡。
function c50546208.thfilter1(c,tp)
	-- 判断候选对象是否为表侧表示且属于「月光」字段、不是本卡、能够加入手牌，并且该对象离场后自己场上仍有可用怪兽区空格。
	return c:IsFaceup() and c:IsSetCard(0xdf) and not c:IsCode(50546208) and c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果发动时的目标选择函数：若进行连锁指定对象（chkc），则验证对象必须在我方场上且满足筛选条件；若为发动合法性检查（chk==0），则确认本卡能够被特殊召唤，且场上有满足条件的「月光」卡可以作为对象。
function c50546208.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c50546208.thfilter1(chkc,tp) end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 在发动合法性检查中，进一步确认存在至少1张满足条件的取对象目标（自己场上的表侧「月光」卡，且非本卡、可回手、离场后仍有格子）。
		and Duel.IsExistingTarget(c50546208.thfilter1,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 向玩家显示“选择要返回手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己场上选择1张满足条件的「月光」卡作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c50546208.thfilter1,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置操作信息：本次连锁将处理把对象卡返回手牌的效果分类（CATEGORY_TOHAND），目标数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：本次连锁将处理特殊召唤本卡的效果分类（CATEGORY_SPECIAL_SUMMON），预定特殊召唤本卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：获取对象卡，若对象仍与效果关联且成功返回手牌，则本卡以表侧守备表示特殊召唤；特殊召唤成功时，给本卡附加一个不可被无效的“离场时除外”效果。
function c50546208.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择登记的1张对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判定条件：对象卡仍与当前效果关联，对象卡实际返回手牌成功且现在位于手牌，同时本卡仍与效果关联，否则后续处理不执行。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) and c:IsRelateToEffect(e)
		-- 判定条件：本卡成功以表侧守备表示特殊召唤到己方场上（经过召唤条件与苏生限制的检查），返回召唤成功的数量不为0。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：这张卡被效果送去墓地的场合才能发动。从卡组把1张「月光」魔法·陷阱卡加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 触发条件：本卡被效果（REASON_EFFECT）送去墓地时才满足②效果的发动条件。
function c50546208.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数：检索目标需为「月光」字段的魔法·陷阱卡，且能够加入手牌。
function c50546208.thfilter2(c)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的发动合法性与目标设定函数：检查卡组中是否存在至少1张符合条件的「月光」魔陷；若存在，设置操作信息为从卡组将1张卡加入手牌。
function c50546208.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查（chk==0）时，确认卡组中存在至少1张满足检索条件的「月光」魔陷卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c50546208.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将从卡组把1张卡加入手牌（CATEGORY_TOHAND），处理时在卡组中检索。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理函数：从卡组选择1张符合条件的「月光」魔陷加入手牌，并将该卡展示给对方确认。
function c50546208.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的「月光」魔陷卡。
	local g=Duel.SelectMatchingCard(tp,c50546208.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的那张卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的那张卡展示给对方玩家确认（用于证明检索结果）。
		Duel.ConfirmCards(1-tp,g)
	end
end

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
-- 过滤函数，用于判断场上是否满足条件的「月光」卡（非月光黄鼬且可返回手牌且有可用怪兽区）
function c50546208.thfilter1(c,tp)
	-- 返回卡是表侧表示、属于「月光」系列、不是月光黄鼬、可以回到手牌、该玩家场上存在可用怪兽区
	return c:IsFaceup() and c:IsSetCard(0xdf) and not c:IsCode(50546208) and c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果处理时的判断函数，用于确认是否满足特殊召唤条件（目标卡存在且可返回手牌）
function c50546208.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c50546208.thfilter1(chkc,tp) end
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查场上是否存在满足条件的目标卡
		and Duel.IsExistingTarget(c50546208.thfilter1,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的目标卡
	local g=Duel.SelectTarget(tp,c50546208.thfilter1,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置操作信息：将目标卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行特殊召唤并设置特殊效果
function c50546208.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选中的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡和自身是否有效且满足处理条件（返回手牌成功且在手牌）
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) and c:IsRelateToEffect(e)
		-- 判断是否成功特殊召唤
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 创建一个效果，使该卡从场上离开时被移除
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 判断该卡是否因效果而进入墓地
function c50546208.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数，用于检索卡组中满足条件的「月光」魔法或陷阱卡
function c50546208.thfilter2(c)
	return c:IsSetCard(0xdf) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置检索效果的目标信息
function c50546208.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c50546208.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将一张「月光」魔法·陷阱卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理检索效果，选择并加入手牌
function c50546208.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c50546208.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

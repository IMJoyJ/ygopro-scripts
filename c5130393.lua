--千年の血族
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己因战斗·效果受到1000以上的伤害时才能发动。这张卡从手卡特殊召唤。
-- ②：以对方墓地1只攻击力是?以外的怪兽为对象才能发动。对方可以从卡组选1只攻击力是?以外的怪兽。没选的场合或者作为对象的怪兽攻击力更高的场合，作为对象的怪兽在自己场上特殊召唤。选的怪兽回到卡组。那以外的场合，对方把选的怪兽加入手卡。
function c5130393.initial_effect(c)
	-- 初始化卡片效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5130393,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCountLimit(1,5130393)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(c5130393.spcon)
	e1:SetTarget(c5130393.sptg)
	e1:SetOperation(c5130393.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡在主要阶段反转的场合发动。以下效果各适用。●对方可以从自身卡组把1只怪兽加入手卡。●这张卡的控制权移给对方。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5130393,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,5130394)
	e2:SetTarget(c5130393.tdtg)
	e2:SetOperation(c5130393.tdop)
	c:RegisterEffect(e2)
end
-- 反转效果发动条件：主要阶段反转
function c5130393.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and ev>=1000 and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。场上有里侧表示怪兽存在的场合，也能作为代替在自己场上表侧表示特殊召唤。
function c5130393.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 反转效果目标检查与操作信息
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：转移自身控制权
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤条件：怪兽卡且可以加入手卡
function c5130393.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 反转效果处理函数
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 获取对方卡组中的怪兽
function c5130393.filter(c,e,tp)
	return c:GetTextAttack()>=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 对方选择是否将怪兽加入手卡
function c5130393.thfilter(c,p)
	return c:GetTextAttack()>=0 and c:IsType(TYPE_MONSTER) and c:IsAbleToHand(p)
end
-- 提示对方选择要加入手卡的怪兽
function c5130393.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c5130393.filter(chkc,e,tp) end
	-- 对方从卡组选择1只怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 将选中的怪兽加入对方手卡
		and Duel.IsExistingTarget(c5130393.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向自己确认对方加入手卡的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 中断效果处理
	local g=Duel.SelectTarget(tp,c5130393.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 这张卡的控制权移给对方
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤条件：场上有里侧怪兽时可表侧特殊召唤到自己场上
function c5130393.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在里侧表示怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local vc=tc:GetTextAttack()
	local sel=1
	-- 过滤条件：可里侧守备特殊召唤到对方场上
	local g=Duel.GetMatchingGroup(c5130393.thfilter,tp,0,LOCATION_DECK,nil,1-tp)
	-- 特殊召唤效果目标检查
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(5130393,2))  --"是否从卡组选1只怪兽？"
	if g:GetCount()>0 then
		-- 检查是否能特殊召唤到自己场上
		sel=Duel.SelectOption(1-tp,1213,1214)
	else
		-- 或是否能特殊召唤到对方场上
		sel=Duel.SelectOption(1-tp,1214)+1
	end
	if sel==0 then
		-- 设置操作信息：特殊召唤自身
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 特殊召唤效果处理函数
		local sg=Duel.SelectMatchingCard(1-tp,c5130393.thfilter,tp,0,LOCATION_DECK,1,1,nil,1-tp)
		-- 判断是否可以表侧特殊召唤到自己场上
		Duel.ConfirmCards(tp,sg)
		if sg:GetFirst():GetTextAttack()<vc then
			-- 判断是否可以里侧守备特殊召唤到对方场上
			Duel.ShuffleDeck(1-tp)
			-- 让玩家选择特殊召唤到哪一方场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 表侧表示特殊召唤到自己场上
			Duel.SendtoHand(sg,nil,REASON_EFFECT,1-tp)
			-- 里侧守备表示特殊召唤到对方场上
			Duel.ConfirmCards(1-tp,sg)
		end
	else
		-- 自己确认该里侧表示怪兽
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

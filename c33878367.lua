--壱世壊に渦巻く反響
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的卡组·墓地选1只「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」特殊召唤。那之后，选种族或者属性和这个效果特殊召唤的怪兽相同的自己场上1只怪兽送去墓地。
-- ②：这张卡被效果送去墓地的场合，以除外的1张自己的「珠泪哀歌族」陷阱卡为对象才能发动。那张卡加入手卡。
function c33878367.initial_effect(c)
	-- 记录这张卡文本中记载的「维萨斯-斯塔弗罗斯特」（卡号56099748），供与卡名相关的效果判断使用。
	aux.AddCodeList(c,56099748)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：从自己的卡组·墓地选1只「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」特殊召唤。那之后，选种族或者属性和这个效果特殊召唤的怪兽相同的自己场上1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,33878367)
	e1:SetTarget(c33878367.sptg)
	e1:SetOperation(c33878367.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合，以除外的1张自己的「珠泪哀歌族」陷阱卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,33878367)
	e2:SetCondition(c33878367.thcon)
	e2:SetTarget(c33878367.thtg)
	e2:SetOperation(c33878367.thop)
	c:RegisterEffect(e2)
end
-- spfilter是特殊召唤的过滤函数，筛选出卡组·墓地中属于「珠泪哀歌族」（0x181）或卡名为「维萨斯-斯塔弗罗斯特」（56099748）且可以被效果特殊召唤的怪兽。
function c33878367.spfilter(c,e,tp)
	return (c:IsSetCard(0x181) or c:IsCode(56099748)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- sptg是①效果的发动条件判定函数，在发动时检查己方场上是否有主怪兽区空格，且卡组·墓地是否存在符合条件的特殊召唤对象。
function c33878367.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否存在可用的主怪兽区空格，确保特殊召唤能够执行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组·墓地是否存在至少1张满足spfilter过滤条件的怪兽，确保有特殊召唤的对象。
		and Duel.IsExistingMatchingCard(c33878367.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设定本效果包含特殊召唤操作信息：从持有者tp的卡组·墓地选择1只怪兽进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	-- 设定本效果包含送墓操作信息：效果处理时要把己方场上1只怪兽送去墓地，具体对象届时选择，因此targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
-- spop是①效果的实际处理函数：先确认有可用主怪兽区，再让玩家从卡组·墓地选择1只符合条件的怪兽特殊召唤；召唤成功后，选择己方场上1只与召唤怪兽种族或属性相同的表侧怪兽送去墓地。
function c33878367.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查主怪兽区是否有空位，若无空格则直接结束，不进行后续操作。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的卡组·墓地筛选并选择1张满足spfilter的怪兽（并过滤掉受王家长眠之谷影响的卡）作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c33878367.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功将选择的那只怪兽以表侧攻击表示特殊召唤到己方场上（返回值大于0），则继续执行后续送墓处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取己方场上所有表侧表示且种族或属性与特殊召唤怪兽相同的怪兽，作为可能被送去墓地的候选集合。
		local sg=Duel.GetMatchingGroup(c33878367.tgfilter,tp,LOCATION_MZONE,0,nil,tc:GetRace(),tc:GetAttribute())
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续送墓处理与特殊召唤不在同一时点结算，避免错过时点。
			Duel.BreakEffect()
			-- 向玩家显示选择提示：请选择要送去墓地的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local sc=sg:Select(tp,1,1,nil)
			-- 将玩家选择的怪兽以效果原因送去墓地，即①效果后半段的送墓处理。
			Duel.SendtoGrave(sc,REASON_EFFECT)
		end
	end
end
-- tgfilter是送墓候选的过滤函数：筛选己方场上表侧表示、种族或属性与特殊召唤怪兽相同、且可以被效果送去墓地的怪兽。
function c33878367.tgfilter(c,race,attr)
	return c:IsFaceup() and (c:IsRace(race) or c:IsAttribute(attr)) and c:IsAbleToGrave()
end
-- thcon是②效果的发动条件：该卡被效果送去墓地时才能发动，通过判断送墓原因是REASON_EFFECT来确定。
function c33878367.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- thfilter是②效果取对象的过滤函数：筛选除外区中自己持有的「珠泪哀歌族」陷阱卡，且该卡表侧表示并能加入手卡。
function c33878367.thfilter(c)
	return c:IsSetCard(0x181) and c:IsType(TYPE_TRAP) and c:IsFaceup() and c:IsAbleToHand()
end
-- thtg是②效果的发动时目标函数：先验证连锁处理时指定对象是否合法，再检查除外区是否有符合条件的对象；并让玩家选择1张设为效果对象，设定回手操作信息。
function c33878367.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c33878367.thfilter(chkc) end
	-- 发动时检查除外区是否存在至少1张满足thfilter的卡，确保有合法对象可选取。
	if chk==0 then return Duel.IsExistingTarget(c33878367.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己除外区选择1张满足thfilter的陷阱卡，并设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c33878367.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设定本效果的操作信息为将选中的1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- thop是②效果的实际处理函数：取得连锁对象卡，若它仍与该效果关联，则将其加入持有者的手卡。
function c33878367.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取得第一个对象卡，即之前选择的除外中的珠泪陷阱卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因加入手卡（nil表示加入持有者手卡），完成②效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

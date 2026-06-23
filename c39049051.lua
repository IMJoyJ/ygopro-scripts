--歌氷麗月
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把1只4星以下的天使族·魔法师族·鸟兽族·兽战士族怪兽特殊召唤，把这张卡装备。那之后，可以让场上的龙族怪兽全部回到持有者手卡。
-- ②：魔法与陷阱区域的表侧表示的这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1张「融合」魔法卡或者1只「寄生融合虫」加入手卡。
function c39049051.initial_effect(c)
	-- ①：从手卡把1只4星以下的天使族·魔法师族·鸟兽族·兽战士族怪兽特殊召唤，把这张卡装备。那之后，可以让场上的龙族怪兽全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,39049051)
	e1:SetTarget(c39049051.target)
	e1:SetOperation(c39049051.activate)
	c:RegisterEffect(e1)
	-- 魔法与陷阱区域的表侧表示的这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1张「融合」魔法卡或者1只「寄生融合虫」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c39049051.regcon)
	e2:SetOperation(c39049051.regop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,39049052)
	e3:SetCondition(c39049051.thcon)
	e3:SetTarget(c39049051.thtg)
	e3:SetOperation(c39049051.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查以玩家来看的手卡是否存在满足条件的怪兽（种族为天使族、魔法师族、鸟兽族、兽战士族，等级不超过4，且可以特殊召唤）
function c39049051.spfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY+RACE_SPELLCASTER+RACE_WINDBEAST+RACE_BEASTWARRIOR) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足①效果的发动条件（场上存在可特殊召唤的怪兽）
function c39049051.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位可以特殊召唤怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c39049051.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：将要装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,LOCATION_HAND)
end
-- 装备限制效果函数，确保只有装备卡的持有者才能装备
function c39049051.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤函数，检查场上是否存在可以送回手卡的龙族怪兽
function c39049051.drfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsFaceup() and c:IsAbleToHand()
end
-- ①效果的处理函数：选择并特殊召唤符合条件的怪兽，装备自身，并可选择是否将龙族怪兽送回手卡
function c39049051.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c39049051.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 特殊召唤选中的怪兽
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 将自身装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 设置装备限制效果，防止其他怪兽装备此卡
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c39049051.eqlimit)
		c:RegisterEffect(e1)
		-- 获取场上的所有龙族怪兽
		local hg=Duel.GetMatchingGroup(c39049051.drfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 判断是否选择将龙族怪兽送回手卡
		if hg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(39049051,2)) then  --"是否把龙族怪兽全部回到持有者手卡？"
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将龙族怪兽送回持有者手卡
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
		end
	end
end
-- 判断此卡是否从魔法与陷阱区域表侧表示送去墓地
function c39049051.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 注册标记，表示此卡已进入墓地并可发动②效果
function c39049051.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(39049051,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数，检查卡组中是否存在「融合」魔法卡或「寄生融合虫」
function c39049051.thfilter(c)
	return (c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) or c:IsCode(6205579)) and c:IsAbleToHand()
end
-- 判断是否满足②效果的发动条件（此卡已进入墓地并注册标记）
function c39049051.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(39049051)>0
end
-- 判断是否满足②效果的发动条件（卡组中存在可加入手牌的卡）
function c39049051.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c39049051.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数：从卡组选择1张「融合」魔法卡或1只「寄生融合虫」加入手牌
function c39049051.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c39049051.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

--スターダスト・イルミネイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「星尘」怪兽送去墓地。自己场上有着「星尘龙」或者有那个卡名记述的同调怪兽存在的场合，也能不送去墓地特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只「星尘」怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升或下降1星。
function c37750912.initial_effect(c)
	-- 记录这张卡的卡文本中记述了「星尘龙」。
	aux.AddCodeList(c,44508094)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从卡组把1只「星尘」怪兽送去墓地。自己场上有着「星尘龙」或者有那个卡名记述的同调怪兽存在的场合，也能不送去墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37750912)
	e1:SetTarget(c37750912.target)
	e1:SetOperation(c37750912.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「星尘」怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升或下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37750912,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,37750913)
	-- 设置②效果的发动代价为将墓地的这张卡表侧除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c37750912.lvltg)
	e2:SetOperation(c37750912.lvlop)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查卡片是否为可送墓或（在满足条件时）可特殊召唤的「星尘」怪兽。
function c37750912.tgfilter(c,e,tp,check)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa3)
		and (c:IsAbleToGrave() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 过滤条件：检查怪兽是否为表侧表示的「星尘龙」或文本中记述了「星尘龙」卡名的同调怪兽。
function c37750912.cfilter(c)
	-- 判断自己怪兽区是否存在表侧表示的「星尘龙」或记述「星尘龙」的同调怪兽。
	return c:IsFaceup() and (c:IsCode(44508094) or c:IsType(TYPE_SYNCHRO) and aux.IsCodeListed(c,44508094))
end
-- ①效果的目标处理函数：检查是否满足特殊召唤条件并确认卡组存在可操作的「星尘」怪兽。
function c37750912.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否存在「星尘龙」或记述「星尘龙」的同调怪兽。
		local check=Duel.IsExistingMatchingCard(c37750912.cfilter,tp,LOCATION_MZONE,0,1,nil)
			-- 检查自己主要怪兽区是否存在可用于特殊召唤的空位。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己卡组存在至少1只可送去墓地或在满足条件时可特殊召唤的「星尘」怪兽。
		return Duel.IsExistingMatchingCard(c37750912.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check)
	end
end
-- ①效果的处理函数：重新判定是否满足替代特招条件，从卡组选1只「星尘」怪兽送墓或特殊召唤。
function c37750912.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时检查自己场上是否存在「星尘龙」或记述「星尘龙」的同调怪兽。
	local check=Duel.IsExistingMatchingCard(c37750912.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己主要怪兽区是否存在可用于特殊召唤的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 发送提示信息，引导玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组选择1只满足条件的「星尘」怪兽。
	local g=Duel.SelectMatchingCard(tp,c37750912.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check)
	local tc=g:GetFirst()
	if tc then
		if check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 若满足特招条件且所选怪兽无法送墓或玩家选择特殊召唤，则进入特殊召唤分支。
			and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1191,1152)==1) then
			-- 将所选「星尘」怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将所选「星尘」怪兽以效果送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- 过滤条件：检查怪兽是否为表侧表示且拥有等级的「星尘」怪兽。
function c37750912.lvlfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa3) and c:IsLevelAbove(0)
end
-- ②效果的目标处理函数：检查并让己方选择自己场上1只符合条件的「星尘」怪兽作为等级调整对象。
function c37750912.lvltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c37750912.lvlfilter(chkc) end
	-- 发动条件检查：确认自己怪兽区存在至少1只拥有等级的表侧表示「星尘」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c37750912.lvlfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 发送提示信息，引导玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让己方从自己怪兽区选择1只满足条件的「星尘」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c37750912.lvlfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的处理函数：让玩家选择上升或下降1星（1星时只能选上升），并赋予对象怪兽持续至回合结束的等级变化效果。
function c37750912.lvlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁指定的对象「星尘」怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local opt=0
		if tc:IsLevel(1) then
			-- 当对象怪兽等级为1时，只提供「等级上升」选项供己方选择。
			opt=Duel.SelectOption(tp,aux.Stringid(37750912,1))  --"等级上升"
		else
			-- 当对象怪兽等级不为1时，提供「等级上升」和「等级下降」供己方选择。
			opt=Duel.SelectOption(tp,aux.Stringid(37750912,1),aux.Stringid(37750912,2))  --"等级上升/等级下降"
		end
		-- 那只怪兽的等级直到回合结束时上升或下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		if opt==0 then
			e1:SetValue(1)
		else
			e1:SetValue(-1)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

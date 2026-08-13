--マシュマオ☆ヤミー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有兽族·光属性怪兽的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己墓地把1张「味美喵」魔法·陷阱卡加入手卡。同调怪兽的效果特殊召唤的场合，也能作为代替把自己的卡组·除外状态的1张「味美喵」场地魔法卡或「味美喵」永续魔法·永续陷阱卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 初始化效果注册：为这张卡注册①手卡起动特殊召唤效果、②召唤/特殊召唤时的回收/放置效果（e2/e3共用1回合1次，e3对应特殊召唤时点），以及用于记录同调怪兽效果特殊召唤的辅助效果（e4）。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上的怪兽不存在的场合或者只有兽族·光属性怪兽的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从自己墓地把1张「味美喵」魔法·陷阱卡加入手卡。同调怪兽的效果特殊召唤的场合，也能作为代替把自己的卡组·除外状态的1张「味美喵」场地魔法卡或「味美喵」永续魔法·永续陷阱卡在自己场上表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收效果"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 同调怪兽的效果特殊召唤的场合，也能作为代替把自己的卡组·除外状态的1张「味美喵」场地魔法卡或「味美喵」永续魔法·永续陷阱卡在自己场上表侧表示放置。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetOperation(s.checkop)
	c:RegisterEffect(e4)
end
-- 过滤函数：检查怪兽是否为里侧表示或不是光属性·兽族，用于判断场上是否满足‘无怪兽或只有兽族·光属性怪兽’的发动条件。
function s.cfilter(c)
	return c:IsFacedown() or not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST))
end
-- 发动条件判断：自己场上不存在里侧表示或非光属性·兽族的怪兽，即场上没有怪兽或全部表侧怪兽均为光属性·兽族。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回‘场上不存在不符合条件的怪兽’的判定结果：若场上无怪兽或所有怪兽都是光属性·兽族则条件成立。
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时判定：确认自己场上怪兽区域有空位，且手卡的这张卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本效果将特殊召唤这张卡（1张），用于连锁相关的判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与当前连锁关联，则将其从手卡表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到自己场上（会检查召唤条件和苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 墓地过滤：属于「味美喵」系列的魔法·陷阱卡，且可以加入手牌。
function s.thfilter(c)
	return c:IsSetCard(0x1ca) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 放置过滤：属于「味美喵」系列，且满足：永续魔法/永续陷阱（自己魔陷区有空位）或场地魔法，不是禁止卡且不受同名卡限制，可表侧放置的卡。
function s.pfilter(c,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1ca)
		-- 若候选卡是永续魔法/永续陷阱，则必须在自己魔陷区有空位时才可选择。
		and (c:IsType(TYPE_CONTINUOUS) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		or c:IsType(TYPE_FIELD))
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 发动时判定：墓地存在可回收的「味美喵」魔陷，或（卡组/除外存在可放置的「味美喵」卡且本卡具有同调特殊召唤标记）；同时设置回手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在1张符合条件的「味美喵」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查卡组·除外区是否存在1张符合条件的可放置「味美喵」卡。
		or Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,tp)
		and e:GetHandler():GetFlagEffect(id)>0 end
	if e:GetHandler():GetFlagEffect(id)>0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	-- 设置操作信息：预计将1张卡从墓地加入手牌（用于效果发动后的连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：若墓地回收可用且玩家未选择代替放置，则从墓地选1张「味美喵」魔陷加入手牌；否则若有代替放置选项，则从卡组/除外选1张「味美喵」场地魔法或永续魔陷表侧放置到自己的场地/魔陷区。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断墓地是否存在可回收的「味美喵」魔法·陷阱卡（已过滤王家长眠之谷影响）。
	local b1=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
	-- 判断是否满足代替放置条件：本卡带有同调特殊召唤标记，且卡组/除外区存在可放置的「味美喵」卡。
	local b2=e:GetLabel()==1 and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,tp)
	-- 若墓地回收可用且（代替放置不可用或玩家选择‘否’），则走回收分支；否则若代替放置可用，则走放置分支。
	if b1 and (not b2 or not Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否放置永续·场地卡？"
		-- 显示选择提示：请选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从墓地选择1张符合条件的「味美喵」魔法·陷阱卡（不受王家长眠之谷影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入其持有者的手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	elseif b2 then
		-- 显示选择提示：请选择要放置到场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从卡组和除外区选择1张符合条件的「味美喵」卡，并取得选择结果。
		local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,tp):GetFirst()
		if tc then
			if tc:IsType(TYPE_CONTINUOUS) then
				-- 将选中的永续魔法/永续陷阱卡以表侧表示放置到自己的魔陷区。
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			else
				-- 将选中的场地魔法卡以表侧表示放置到自己的场地魔法区域。
				Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			end
		end
	end
end
-- 特殊召唤成功时辅助记录：若此次特殊召唤是由同调怪兽的效果发动的，则给这张卡设置标记，用于②效果中代替放置选项的可用性判断。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	if re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsType(TYPE_SYNCHRO) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TEMP_REMOVE,0,1)
	end
end

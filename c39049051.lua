--歌氷麗月
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把1只4星以下的天使族·魔法师族·鸟兽族·兽战士族怪兽特殊召唤，把这张卡装备。那之后，可以让场上的龙族怪兽全部回到持有者手卡。
-- ②：魔法与陷阱区域的表侧表示的这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1张「融合」魔法卡或者1只「寄生融合虫」加入手卡。
function c39049051.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从手卡把1只4星以下的天使族·魔法师族·鸟兽族·兽战士族怪兽特殊召唤，把这张卡装备。那之后，可以让场上的龙族怪兽全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,39049051)
	e1:SetTarget(c39049051.target)
	e1:SetOperation(c39049051.activate)
	c:RegisterEffect(e1)
	-- 魔法与陷阱区域的表侧表示的这张卡被送去墓地的回合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c39049051.regcon)
	e2:SetOperation(c39049051.regop)
	c:RegisterEffect(e2)
	-- ②：魔法与陷阱区域的表侧表示的这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1张「融合」魔法卡或者1只「寄生融合虫」加入手卡。
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
-- 筛选①可特殊召唤的怪兽：4星以下且种族为天使族·魔法师族·鸟兽族·兽战士族，并且可以被特殊召唤。
function c39049051.spfilter(c,e,tp)
	return c:IsRace(RACE_FAIRY+RACE_SPELLCASTER+RACE_WINDBEAST+RACE_BEASTWARRIOR) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①的发动条件判定：自己主要怪兽区有空位，且手牌存在满足条件的可特殊召唤怪兽。
function c39049051.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手牌是否存在至少1只满足spfilter条件的怪兽（即可被特殊召唤的4星以下指定种族怪兽）。
		and Duel.IsExistingMatchingCard(c39049051.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本次效果的特殊召唤操作信息：从手牌特殊召唤1只怪兽（用于连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 登记本次效果的装备操作信息：将这张歌冰丽月装备给特殊召唤的怪兽（用于连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,LOCATION_HAND)
end
-- 装备限制：该怪兽只能被这张歌冰丽月装备。
function c39049051.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 筛选可弹回手牌的龙族怪兽：场上表侧表示且可以被送回持有者手卡的龙族怪兽。
function c39049051.drfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsFaceup() and c:IsAbleToHand()
end
-- ①效果处理：从手牌选1只符合条件的怪兽特殊召唤，将这张卡装备给它，然后可选将场上龙族怪兽全部弹回持有者手卡。
function c39049051.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出“请选择要特殊召唤的卡”的提示，要求玩家选择怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1只满足spfilter条件的怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c39049051.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择的怪兽表侧表示特殊召唤到自己场上；若特殊召唤成功则继续装备处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 将这张歌冰丽月作为装备卡装备给刚刚特殊召唤的怪兽。
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c39049051.eqlimit)
		c:RegisterEffect(e1)
		-- 获取场上所有满足drfilter条件的表侧表示龙族怪兽（用于可选弹回手牌）。
		local hg=Duel.GetMatchingGroup(c39049051.drfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 若存在符合条件的龙族怪兽且玩家选择“是”，则执行龙族怪兽回手处理。
		if hg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(39049051,2)) then  --"是否把龙族怪兽全部回到持有者手卡？"
			-- 中断当前效果处理，使后续回手处理成为独立效果处理（避免时点被错过）。
			Duel.BreakEffect()
			-- 将选中的龙族怪兽全部送回持有者手卡（效果处理）。
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
		end
	end
end
-- 记录条件：这张卡从魔法与陷阱区域表侧表示被送去墓地。
function c39049051.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 在这张卡送去墓地时设置标记，使其在结束阶段可发动②（标记持续到结束阶段重置）。
function c39049051.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(39049051,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 筛选②可检索的卡：「融合」魔法卡（具有0x46字段）或「寄生融合虫」（6205579），且可以加入手牌。
function c39049051.thfilter(c)
	return (c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) or c:IsCode(6205579)) and c:IsAbleToHand()
end
-- ②发动条件：这张卡在墓地且本回合已从魔法与陷阱区域表侧表示被送去墓地（有标记）。
function c39049051.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(39049051)>0
end
-- ②发动条件检查与操作信息登记：卡组存在可检索目标，并登记将卡组1张卡加入手牌。
function c39049051.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在至少1张满足thfilter条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c39049051.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次效果将卡组1张卡加入手牌的操作信息（用于连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选1张「融合」魔法卡或「寄生融合虫」加入手牌，并让对方确认。
function c39049051.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的提示，要求玩家选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c39049051.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者手牌（效果处理）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end

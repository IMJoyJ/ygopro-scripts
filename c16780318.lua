--超勝負！
-- 效果：
-- ①：选自己场上1只同调怪兽回到持有者的额外卡组，从自己墓地选4只「花札卫」怪兽特殊召唤。那之后，自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽无视召唤条件特殊召唤。不是的场合，自己场上的怪兽全部破坏，自己基本分变成一半。
-- ②：这张卡被「花札卫」怪兽的效果送去墓地的回合的结束阶段才能发动。从自己墓地选1张魔法·陷阱卡加入手卡。
function c16780318.initial_effect(c)
	-- ①：选自己场上1只同调怪兽回到持有者的额外卡组，从自己墓地选4只「花札卫」怪兽特殊召唤。那之后，自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽无视召唤条件特殊召唤。不是的场合，自己场上的怪兽全部破坏，自己基本分变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c16780318.target)
	e1:SetOperation(c16780318.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被「花札卫」怪兽的效果送去墓地的回合的结束阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c16780318.regcon)
	e2:SetOperation(c16780318.regop)
	c:RegisterEffect(e2)
end
-- 定义选择要返回额外卡组的同调怪兽的过滤条件：表侧表示、同调怪兽、可以返回额外卡组，且该怪兽离开后自己场上仍有至少4个可用怪兽区。
function c16780318.exfilter(c,tp)
	-- 判断c是否为表侧表示的同调怪兽且能返回额外卡组，并通过Duel.GetMZoneCount(tp,c)确认移走c后tp场上可用怪兽区不少于4个，以保证后续能特殊召唤4只怪兽。
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra() and Duel.GetMZoneCount(tp,c)>=4
end
-- 定义墓地中可特殊召唤的「花札卫」怪兽的过滤条件：属于「花札卫」系列，且能被效果以表侧表示特殊召唤。
function c16780318.spfilter(c,e,tp)
	return c:IsSetCard(0xe6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 效果①的发动条件判定：自己场上有满足exfilter的同调怪兽、墓地有至少4只可特殊召唤的「花札卫」怪兽、自己能抽1张卡，且“青眼精灵龙”的效果不在适用（不能同时特殊召唤2只以上怪兽）。
function c16780318.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c16780318.exfilter,tp,LOCATION_MZONE,0,1,nil,tp) and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查墓地是否存在至少4只满足spfilter的「花札卫」怪兽，且自己能够进行1张卡的抽卡。
		and Duel.IsExistingMatchingCard(c16780318.spfilter,tp,LOCATION_GRAVE,0,4,nil,e,tp) and Duel.IsPlayerCanDraw(tp,1)
	end
	-- 将当前连锁的对象玩家设为tp，记录后续抽卡操作的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，记录后续抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 声明本次效果包含抽卡操作：玩家tp预计抽1张卡（具体抽到哪张处理时确定，targets设为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 声明本次效果包含返回额外卡组的操作：从tp怪兽区选1张卡返回额外卡组（对象在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_MZONE)
	-- 声明本次效果包含特殊召唤操作：从tp墓地特殊召唤4只怪兽（对象处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,LOCATION_GRAVE)
end
-- 效果①发动后的处理：选择1只同调怪兽返回额外卡组；若成功且位于额外卡组、场上可用怪兽区≥4且不受青眼精灵龙限制，则从墓地选4只「花札卫」怪兽特殊召唤；特召成功后中断效果处理，然后让tp抽1张并给对方确认；若抽到的是「花札卫」怪兽且玩家选择是，则无视召唤条件将其特殊召唤；否则破坏自己场上所有怪兽，并将基本分变为一半。
function c16780318.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“选择要返回卡组的卡”的提示信息，引导玩家进行选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让tp从自己场上选择1只满足exfilter条件的同调怪兽，作为返回额外卡组的对象。
	local g=Duel.SelectMatchingCard(tp,c16780318.exfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tg=g:GetFirst()
	-- 确认选到了怪兽，且将其返回持有者卡组（额外卡组）洗牌成功，并且该怪兽现在位于额外卡组，才继续执行后续特殊召唤处理。
	if tg and Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tg:IsLocation(LOCATION_EXTRA) then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<4 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
		-- 显示“选择要特殊召唤的卡”的提示信息，引导玩家从墓地选择怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让tp从墓地选择4只满足spfilter且不受王家长眠之谷影响（如被王谷限制则不可选）的「花札卫」怪兽，作为特殊召唤的对象。
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16780318.spfilter),tp,LOCATION_GRAVE,0,4,4,nil,e,tp)
		if #sg>0 then
			-- 将选择的4只「花札卫」怪兽以表侧表示特殊召唤到tp的怪兽区；若特殊召唤成功（至少1只成功）则继续处理。
			if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
				-- 中断当前效果处理，使接下来的抽卡/追加处理不在同一时点，以正确应对时点。
				Duel.BreakEffect()
				-- 获取当前连锁中记录的对象玩家p和参数d，即之前设置的抽卡玩家和抽卡数量（tp, 1）。
				local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
				-- 让玩家p抽d张卡（即tp抽1张）；若实际抽卡成功，则继续处理抽到的卡。
				if Duel.Draw(p,d,REASON_EFFECT)~=0 then
					-- 获取上一次抽卡操作实际抽到的那张卡，并赋值给tc。
					local tc=Duel.GetOperatedGroup():GetFirst()
					-- 将抽到的tc给玩家1-p（即对方）确认。
					Duel.ConfirmCards(1-p,tc)
					if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
						-- 检查抽到的卡是否可以被无视召唤条件特殊召唤（并检查苏生限制）且tp场上还有可用怪兽区，决定能否追加特殊召唤。
						if tc:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
							-- 弹出“是否特殊召唤？”的选择框，由玩家tp决定是否将抽到的「花札卫」怪兽特殊召唤。
							and Duel.SelectYesNo(tp,aux.Stringid(16780318,0)) then  --"是否特殊召唤？"
							-- 将抽到的那只怪兽无视召唤条件、以表侧表示特殊召唤到tp场上。
							Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
						end
					else
						-- 获取tp自己场上的全部怪兽，用于后续全部破坏。
						local rg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
						-- 若自己场上存在怪兽，则将其全部破坏；破坏成功后才继续执行半血处理。
						if #rg>0 and Duel.Destroy(rg,REASON_EFFECT)>0 then
							-- 将tp的基本分设置为当前基本分的一半（向上取整）。
							Duel.SetLP(tp,math.ceil(Duel.GetLP(tp)/2))
						end
					end
				end
			end
		end
	end
end
-- 效果②的登记条件：这张卡是被「花札卫」怪兽的效果送去墓地（送墓原因必须包含效果）时才满足条件，从而允许登记结束阶段发动的效果。
function c16780318.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0xe6) and re:GetHandler():IsType(TYPE_MONSTER) and bit.band(r,REASON_EFFECT)>0
end
-- 当满足登记条件时，在墓地给这张卡注册一个结束阶段可发动的效果：该效果为可选触发效果，1回合1次，用于②的魔法·陷阱回收。
function c16780318.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从自己墓地选1张魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16780318,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetTarget(c16780318.thtg)
	e1:SetOperation(c16780318.thop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 定义回收对象的过滤条件：墓地中的魔法·陷阱卡，且能够加入手卡。
function c16780318.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的发动条件判定与操作信息设置：墓地存在至少1张可加入手卡的魔法·陷阱卡时，声明本次效果将1张卡从墓地加入手卡。
function c16780318.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定墓地是否存在至少1张满足回收条件的魔法·陷阱卡，作为效果②能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c16780318.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 声明本次效果包含从墓地加入手卡的操作，预计处理1张。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的实际处理：从自己墓地选择1张魔法·陷阱卡加入手卡，并给对手确认。
function c16780318.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“选择要加入手牌的卡”的提示信息，引导玩家选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让tp从墓地选择1张满足thfilter且不受王家长眠之谷影响的魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16780318.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡以效果原因加入其持有者的手卡（nil表示返回持有者手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end

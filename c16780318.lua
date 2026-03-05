--超勝負！
-- 效果：
-- ①：选自己场上1只同调怪兽回到持有者的额外卡组，从自己墓地选4只「花札卫」怪兽特殊召唤。那之后，自己从卡组抽1张，给双方确认。那是「花札卫」怪兽的场合，可以把那只怪兽无视召唤条件特殊召唤。不是的场合，自己场上的怪兽全部破坏，自己基本分变成一半。
-- ②：这张卡被「花札卫」怪兽的效果送去墓地的回合的结束阶段才能发动。从自己墓地选1张魔法·陷阱卡加入手卡。
function c16780318.initial_effect(c)
	-- 效果①：发动时选择自己场上1只同调怪兽送入额外卡组，从自己墓地特殊召唤4只「花札卫」怪兽，之后自己抽1张卡并确认。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOEXTRA+CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c16780318.target)
	e1:SetOperation(c16780318.activate)
	c:RegisterEffect(e1)
	-- 效果②：这张卡被「花札卫」怪兽的效果送入墓地的回合的结束阶段才能发动，从自己墓地选1张魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c16780318.regcon)
	e2:SetOperation(c16780318.regop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检测场上是否有满足条件的同调怪兽（表侧表示、同调怪兽、可送入额外卡组、自己场上怪兽区数量大于等于4）
function c16780318.exfilter(c,tp)
	-- 满足条件的同调怪兽需为表侧表示、同调怪兽类型、可送入额外卡组、自己场上怪兽区数量大于等于4
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra() and Duel.GetMZoneCount(tp,c)>=4
end
-- 过滤函数：检测墓地是否有满足条件的「花札卫」怪兽（属于花札卫卡组、可特殊召唤）
function c16780318.spfilter(c,e,tp)
	return c:IsSetCard(0xe6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 判断是否满足效果①的发动条件：场上存在满足条件的同调怪兽、未受青眼精灵龙效果影响、墓地存在4只「花札卫」怪兽、自己可以抽卡
function c16780318.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c16780318.exfilter,tp,LOCATION_MZONE,0,1,nil,tp) and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 墓地存在4只「花札卫」怪兽、自己可以抽卡
		and Duel.IsExistingMatchingCard(c16780318.spfilter,tp,LOCATION_GRAVE,0,4,nil,e,tp) and Duel.IsPlayerCanDraw(tp,1)
	end
	-- 设置连锁处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为1
	Duel.SetTargetParam(1)
	-- 设置操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置操作信息：将1只怪兽送入额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_MZONE)
	-- 设置操作信息：特殊召唤4只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,4,tp,LOCATION_GRAVE)
end
-- 效果①的处理流程：选择1只同调怪兽送入额外卡组，再从墓地特殊召唤4只「花札卫」怪兽，然后抽1张卡并确认，若抽到的是「花札卫」怪兽则可无视召唤条件特殊召唤，否则破坏场上所有怪兽并将LP减半
function c16780318.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送入卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c16780318.exfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local tg=g:GetFirst()
	-- 若选择的怪兽成功送入额外卡组，则继续处理后续效果
	if tg and Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tg:IsLocation(LOCATION_EXTRA) then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<4 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
		-- 提示玩家选择要特殊召唤的4只「花札卫」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地选择4只满足条件的「花札卫」怪兽
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16780318.spfilter),tp,LOCATION_GRAVE,0,4,4,nil,e,tp)
		if #sg>0 then
			-- 将选择的4只怪兽特殊召唤
			if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
				-- 中断当前效果处理，使后续效果视为不同时处理
				Duel.BreakEffect()
				-- 获取连锁处理的目标玩家和参数
				local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
				-- 自己抽1张卡
				if Duel.Draw(p,d,REASON_EFFECT)~=0 then
					-- 获取抽卡操作实际处理的卡片
					local tc=Duel.GetOperatedGroup():GetFirst()
					-- 给对方确认抽到的卡片
					Duel.ConfirmCards(1-p,tc)
					if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0xe6) then
						-- 判断抽到的卡片是否为「花札卫」怪兽且可无视召唤条件特殊召唤
						if tc:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
							-- 询问玩家是否特殊召唤该卡片
							and Duel.SelectYesNo(tp,aux.Stringid(16780318,0)) then  --"是否特殊召唤？"
							-- 若选择特殊召唤，则无视召唤条件将该卡片特殊召唤
							Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
						end
					else
						-- 获取自己场上的所有怪兽
						local rg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
						-- 若场上存在怪兽，则破坏所有怪兽
						if #rg>0 and Duel.Destroy(rg,REASON_EFFECT)>0 then
							-- 将自己LP减半
							Duel.SetLP(tp,math.ceil(Duel.GetLP(tp)/2))
						end
					end
				end
			end
		end
	end
end
-- 判断是否满足效果②的发动条件：该卡被「花札卫」怪兽的效果送入墓地
function c16780318.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0xe6) and re:GetHandler():IsType(TYPE_MONSTER) and bit.band(r,REASON_EFFECT)>0
end
-- 注册效果②：在结束阶段发动，从墓地选1张魔法·陷阱卡加入手卡
function c16780318.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果②：在结束阶段发动，从自己墓地选1张魔法·陷阱卡加入手卡
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
-- 过滤函数：检测墓地是否有满足条件的魔法·陷阱卡（类型为魔法或陷阱、可加入手牌）
function c16780318.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②的处理流程：判断墓地是否存在魔法·陷阱卡，若存在则选择1张加入手牌
function c16780318.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断墓地是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c16780318.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：将1张魔法·陷阱卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的处理流程：选择1张魔法·陷阱卡加入手牌并确认
function c16780318.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1张满足条件的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16780318.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的魔法·陷阱卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的魔法·陷阱卡
		Duel.ConfirmCards(1-tp,g)
	end
end

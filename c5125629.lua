--Sin Paradigm Shift
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡也能把基本分支付一半从手卡发动。
-- ①：从自己的卡组·墓地选1张「罪 世界」加入手卡或在自己的场地区域表侧表示放置。那之后，从卡组·额外卡组把1只「罪」怪兽无视召唤条件守备表示特殊召唤。那之后，对方场上有攻击力2500以上的怪兽存在的场合，对方场上的全部怪兽的攻击力直到回合结束时下降2500。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包括记录相关卡名「罪 世界」，以及注册陷阱发动效果与手牌支付一半基本分发动的效果
function s.initial_effect(c)
	-- 在脚本中记录这张卡涉及到的特定卡名「罪 世界」
	aux.AddCodeList(c,27564031)
	-- ①：从自己的卡组·墓地选1张「罪 世界」加入手卡或在自己的场地区域表侧表示放置。那之后，从卡组·额外卡组把1只「罪」怪兽无视召唤条件守备表示特殊召唤。那之后，对方场上有攻击力2500以上的怪兽存在的场合，对方场上的全部怪兽的攻击力直到回合结束时下降2500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DRAW_PHASE,TIMING_DRAW_PHASE+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这张卡也能把基本分支付一半从手卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"适用「罪 范式转移」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCost(s.cost)
	c:RegisterEffect(e2)
end
-- 从卡组·墓地检索「罪 世界」并加入手牌或放置于场地区域的的过滤条件
function s.thfilter(c,tp)
	return c:IsCode(27564031)
		and (c:IsAbleToHand() or (c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(tp)))
end
-- 从卡组·额外卡组特殊召唤「罪」怪兽的过滤条件，检查位置以及对应格子的空余情况
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x23) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENSE) and c:IsType(TYPE_MONSTER)
		-- 如果怪兽在卡组中，检查主怪兽区是否有空位
		and (c:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 或者如果怪兽在额外卡组中，检查额外怪兽区或相关区域是否有空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 效果发动的目标检测，检查是否满足检索与特殊召唤的过滤条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组·墓地是否存在可以检索或放置的「罪 世界」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
		-- 检查卡组·额外卡组是否存在可以特殊召唤的「罪」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置在效果处理时从卡组或额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 对方场上攻击力2500以上的表侧表示怪兽的过滤条件
function s.atkfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2500)
end
-- 效果的处理逻辑：检索/放置「罪 世界」，特殊召唤「罪」怪兽，并在满足条件时使对方场上全部怪兽攻击力下降2500
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示，指示选择要操作的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组或墓地选择1张满足条件的「罪 世界」，在墓地选择时受「王家长眠之谷」影响
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		local res=false
		local tfchk=not tc:IsForbidden() and tc:CheckUniqueOnField(tp)
		-- 判断玩家选择的操作：加入手牌或放置在场地区域
		if tc:IsAbleToHand() and (not tfchk or Duel.SelectOption(tp,1190,aux.Stringid(id,1))==0) then  --"表侧表示放置"
			-- 将选择的卡加入手牌并确认是否成功加入
			if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
				res=true
				-- 向对方玩家展示并确认加入手牌的卡
				Duel.ConfirmCards(1-tp,tc)
			end
		elseif tfchk then
			-- 获取自己场地区域的卡
			local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if fc then
				-- 因规则将自己原本场地区域的卡送去墓地
				Duel.SendtoGrave(fc,REASON_RULE)
				-- 中断当前效果，以进行下一步表侧表示放置
				Duel.BreakEffect()
			end
			-- 将「罪 世界」表侧表示放置在自己的场地区域
			res=Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		end
		if res then
			-- 向玩家发送提示，指示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从卡组或额外卡组选择1只满足条件的「罪」怪兽
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
			if #g>0 then
				-- 中断效果，用于进行接下来的特殊召唤
				Duel.BreakEffect()
				-- 无视召唤条件守备表示特殊召唤选择的「罪」怪兽，并判断是否成功
				if Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP_DEFENSE)~=0
					-- 检查对方场上是否存在攻击力2500以上的怪兽
					and Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil) then
					-- 获取对方场上所有表侧表示的怪兽
					local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
					if #sg>0 then
						-- 中断效果，用于进行对方场上怪兽的攻击力下降处理
						Duel.BreakEffect()
						-- 遍历所有获取的对方场上的怪兽
						for mc in aux.Next(sg) do
							-- 对方场上的全部怪兽的攻击力直到回合结束时下降2500。
							local e1=Effect.CreateEffect(e:GetHandler())
							e1:SetType(EFFECT_TYPE_SINGLE)
							e1:SetCode(EFFECT_UPDATE_ATTACK)
							e1:SetValue(-2500)
							e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
							mc:RegisterEffect(e1)
						end
					end
				end
			end
		end
	end
end
-- 手牌发动效果的代价处理：支付一半的基本分
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 让玩家支付当前生命值一半的基本分
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end

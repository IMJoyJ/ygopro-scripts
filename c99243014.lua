--シンクロ・オーバーテイク
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ①：把额外卡组1只同调怪兽给对方观看，从自己的卡组·墓地选那只怪兽有卡名记述的1只同调素材怪兽加入手卡或特殊召唤。
function c99243014.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤。①：把额外卡组1只同调怪兽给对方观看，从自己的卡组·墓地选那只怪兽有卡名记述的1只同调素材怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,99243014+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c99243014.cost)
	e1:SetTarget(c99243014.target)
	e1:SetOperation(c99243014.activate)
	c:RegisterEffect(e1)
	-- 注册一个编号为99243014的特殊召唤活动计数器（按ACTIVITY_SPSUMMON统计），用c99243014.counterfilter作为过滤函数：当玩家进行特殊召唤时，若怪兽不是从额外卡组特殊召唤的或是同调怪兽则不计入，否则计数加1；用于记录本回合是否进行过被禁止的“从额外卡组特殊召唤非同调怪兽”操作。
	Duel.AddCustomActivityCounter(99243014,ACTIVITY_SPSUMMON,c99243014.counterfilter)
end
-- 特殊召唤计数器的过滤函数：返回true表示此次特殊召唤不会计入违规计数器；若返回false（从额外卡组特殊召唤且不是同调怪兽）则计数器加1，即记录一次被本卡自肃禁止的行为。
function c99243014.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO)
end
-- 发动代价处理：先确认本回合特殊召唤计数器中没有违规记录，然后给自己（玩家tp）注册一个持续到结束阶段的誓约效果：不能从额外卡组特殊召唤非同调怪兽。这对应“这张卡发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤”的自肃，在效果发动时立即生效。
function c99243014.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价合法性检查阶段（chk==0）返回是否满足发动条件：编号99243014的特殊召唤活动计数器的计数必须为0，即本回合尚未从额外卡组特殊召唤过非同调怪兽。
	if chk==0 then return Duel.GetCustomActivityCount(99243014,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是同调怪兽不能从额外卡组特殊召唤。①：把额外卡组1只同调怪兽给对方观看，从自己的卡组·墓地选那只怪兽有卡名记述的1只同调素材怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c99243014.splimit)
	-- 将创建的自肃效果e1注册给玩家tp，使该玩家从此刻起到回合结束为止，不能从额外卡组特殊召唤非同调怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制的判定函数：当被特殊召唤的怪兽位于额外卡组且不是同调怪兽时返回true，表示该特殊召唤被禁止；即只有从额外卡组来的非同调怪兽会被限制。
function c99243014.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end
-- 额外卡组同调怪兽的过滤条件：该怪兽必须为同调怪兽，并且卡组·墓地中存在至少1只满足c99243014.spfilter的同调素材怪兽（即可作为其素材且能被加入手卡或特殊召唤），用于作为可给对方观看的候选。
function c99243014.ffilter(c,e,tp,ft)
	-- 判定额外卡组中的这张同调怪兽是否可被选择：它本身是同调怪兽，并且自己的卡组·墓地中存在至少1只其记述素材且可被加入手卡或特殊召唤的怪兽。
	return c:IsType(TYPE_SYNCHRO) and Duel.IsExistingMatchingCard(c99243014.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c,e,tp,ft)
end
-- 卡组·墓地中同调素材怪兽的过滤条件：候选素材的卡名被所选额外卡组同调怪兽记述为素材（aux.IsMaterialListCode），并且该素材能够加入手卡，或者场上有空格且能够特殊召唤。
function c99243014.spfilter(c,fc,e,tp,ft)
	-- 返回候选素材是否可用：它必须是所展示同调怪兽的记述素材，且满足“能加入手卡”或“场上有空位且能特殊召唤”的其中一项。
	return aux.IsMaterialListCode(fc,c:GetCode()) and (c:IsAbleToHand() or ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果发动时的目标处理：先取得我方怪兽区域空位数；检查额外卡组是否存在符合条件的同调怪兽（其素材可被加入手卡或特殊召唤）；若存在，则登记本效果可能从卡组·墓地执行加入手卡或特殊召唤的操作。
function c99243014.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取我方当前可用的怪兽区域空格数，用于后续判断同调素材是加入手卡还是特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在目标阶段检查能否发动：额外卡组中存在至少1只满足ffilter的同调怪兽（即其素材可被检索或特召），否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c99243014.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,ft) end
	-- 登记操作信息：本效果可能从卡组·墓地选1张卡加入手卡（具体卡牌在效果处理时选择），用于连锁效果与卡片检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	-- 登记操作信息：本效果可能从卡组·墓地选1张卡特殊召唤（具体卡牌在效果处理时选择），用于连锁效果与卡片检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：从额外卡组选择1只满足条件的同调怪兽给对方确认；然后从自己卡组·墓地选择那只怪兽记述的1只同调素材怪兽；根据素材能否特殊召唤、是否有空位以及玩家选择，将其加入手卡或特殊召唤。
function c99243014.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取我方怪兽区域空格数，用来判断素材是否能特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 向操作玩家发送“请选择给对方确认的卡”的提示，引导其选择额外卡组中要展示的同调怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家从额外卡组选择1只满足ffilter的同调怪兽作为要展示的卡，并取为tc。
	local tc=Duel.SelectMatchingCard(tp,c99243014.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,ft):GetFirst()
	if tc then
		-- 将选中的同调怪兽tc展示给对方玩家确认（满足“给对方观看”的要求）。
		Duel.ConfirmCards(1-tp,tc)
		-- 向操作玩家发送“请选择要操作的卡”的提示，让其在卡组·墓地中选择要加入手卡或特殊召唤的同调素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 玩家从自己的卡组·墓地选择1只满足spfilter的同调素材怪兽；使用aux.NecroValleyFilter确保墓地中受“王家长眠之谷”等效果影响而无法移动的卡不会被选择。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c99243014.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc,e,tp,ft)
		local cc=g:GetFirst()
		if cc then
			-- 判断素材的处理方式：若素材能够加入手卡，并且（它不能特殊召唤、或没有可用怪兽区域空位、或玩家选择“加入手卡”）则加入手卡；否则执行特殊召唤。
			if cc:IsAbleToHand() and (not cc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
				-- 将选中的同调素材怪兽cc加入其持有者的手卡（效果移动原因）。
				Duel.SendtoHand(cc,nil,REASON_EFFECT)
				-- 将因效果加入手卡的素材cc展示给对方玩家确认。
				Duel.ConfirmCards(1-tp,cc)
			else
				-- 将选中的同调素材怪兽cc以表侧表示特殊召唤到自己的怪兽区域（效果处理中的特殊召唤）。
				Duel.SpecialSummon(cc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

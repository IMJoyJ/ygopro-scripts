--GMX - VELOX
-- 效果：
-- 「GMX」怪兽＋恐龙族怪兽
-- 每次对方把怪兽召唤·特殊召唤，自己回复200基本分。
-- 对方回合（诱发即时效果）：可以以对方场上1张卡为对象；直到「GMX」怪兽或者恐龙族怪兽出现为止从自己卡组上面翻卡，自己失去翻开的卡的数量×400的基本分，那只「GMX」怪兽或者恐龙族怪兽加入手卡或特殊召唤，剩下的卡回到卡组，并且，再把作为对象的卡破坏。「GMX-似鸟人龙」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合素材，注册对方召唤/特殊召唤时自己回复基本分的效果，以及在对方回合翻卡检索/特召并破坏对方卡片的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤手续，以1只「GMX」怪兽和1只恐龙族怪兽为融合素材
	aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)
	-- 每次对方把怪兽召唤·特殊召唤，自己回复200基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.reccon)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 对方回合（诱发即时效果）：可以以对方场上1张卡为对象；直到「GMX」怪兽或者恐龙族怪兽出现为止从自己卡组上面翻卡，自己失去翻开的卡的数量×400的基本分，那只「GMX」怪兽或者恐龙族怪兽加入手卡或特殊召唤，剩下的卡回到卡组，并且，再把作为对象的卡破坏。「GMX-似鸟人龙」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤出「GMX」融合素材怪兽
function s.matfilter1(c)
	return c:IsFusionSetCard(0x1dd)
end
-- 过滤出恐龙族融合素材怪兽
function s.matfilter2(c)
	return c:IsRace(RACE_DINOSAUR)
end
-- 过滤出进行召唤或特殊召唤的玩家
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 检查是否是对方玩家进行了召唤或特殊召唤
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 处理回复基本分效果的具体操作：展示此卡并回复200基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示该卡片效果发动的动画
	Duel.Hint(HINT_CARD,0,id)
	-- 让玩家自己回复200基本分
	Duel.Recover(tp,200,REASON_EFFECT)
end
-- 检查当前是否是对方回合
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前的回合玩家是否是对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤出卡组中能够加入手牌或特殊召唤的「GMX」怪兽或恐龙族怪兽
function s.thfilter(c,e,tp,chk)
	return (c:IsSetCard(0x1dd) and c:IsType(TYPE_MONSTER) or c:IsRace(RACE_DINOSAUR))
		-- 检测该怪兽是否可以加入手卡，或者在怪兽区域有空位时是否可以特殊召唤
		and (not chk or c:IsAbleToHand() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 处理翻卡检索/特召并破坏效果发动时的目标检测，确认对方场上有卡片可作为对象，且卡组存在符合条件的卡片，选择对方场上1张卡作为对象，并设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 在效果发动时，检测对方场上是否存在可以作为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
		-- 且检测自己卡组中是否存在能够加入手卡或特殊召唤的「GMX」怪兽或恐龙族怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,true) end
	-- 提示玩家选择要破坏的对象卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡作为效果的目标对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选择的目标卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 翻卡检索/特召并破坏效果处理，依次翻开卡组上方的卡直至翻出特定的怪兽，根据翻卡数量失去基本分，将该怪兽加入手卡或特殊召唤，其余卡洗回卡组，最后将作为对象的目标卡片破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标对象卡片
	local tc=Duel.GetFirstTarget()
	-- 获取卡组中所有符合加入手牌或特殊召唤条件的卡片
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,e,tp,false)
	-- 获取当前自己卡组的卡片总数
	local dct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local hc
	-- 遍历卡组中所有符合条件的卡片，找出最靠近卡组顶端的那一张
	for dc in aux.Next(g) do
		local sq=dc:GetSequence()
		if sq>seq then
			seq=sq
			hc=dc
		end
	end
	if seq>-1 then
		-- 向玩家确认从卡组最上方开始翻开的卡片
		Duel.ConfirmDecktop(tp,dct-seq)
		if e:GetHandler():IsSetCard(0x1dd) then
			-- 触发翻开特定系列卡片相关的自定义时点事件
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
		end
		-- 本次操作不进行卡组洗切检测
		Duel.DisableShuffleCheck()
		-- 使自己失去相当于翻开的卡片数量乘400的基本分数值
		Duel.SetLP(tp,Duel.GetLP(tp)-(dct-seq)*400)
		-- 判断怪兽区域是否有空位且该翻出的怪兽是否可以特殊召唤
		local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and hc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若该怪兽可加入手卡且玩家选择将其加入手卡（或者无法特殊召唤）
		if hc:IsAbleToHand() and (not spchk or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将该怪兽加入玩家的手卡
			Duel.SendtoHand(hc,nil,REASON_EFFECT)
			-- 将加入手卡的怪兽展示给对方玩家确认
			Duel.ConfirmCards(1-tp,hc)
		elseif spchk then
			-- 将翻出的该怪兽在自己场上正面表示特殊召唤
			Duel.SpecialSummon(hc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 若该怪兽无法加入手卡也无法特殊召唤，根据规则送去墓地
			Duel.SendtoGrave(hc,REASON_RULE)
		end
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
	end
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 中断效果处理，使后续的破坏处理不视为与前方的翻卡加入手卡/特殊召唤同时处理
		Duel.BreakEffect()
		-- 将作为效果对象的目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

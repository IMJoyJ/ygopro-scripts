--GMX - VELOX
-- 效果：
-- 「GMX」怪兽＋恐龙族怪兽
-- 每次对方把怪兽召唤·特殊召唤，自己回复200基本分。
-- 对方回合（诱发即时效果）：可以以对方场上1张卡为对象；直到「GMX」怪兽或者恐龙族怪兽出现为止从自己卡组上面翻卡，自己失去翻开的卡的数量×400的基本分，那只「GMX」怪兽或者恐龙族怪兽加入手卡或特殊召唤，剩下的卡回到卡组，并且，再把作为对象的卡破坏。「GMX-似鸟人龙」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：设置融合召唤手续，注册每次对方怪兽召唤·特殊召唤自己回复生命值的效果，以及对方回合以对方场上1张卡为对象破坏并翻卡检索/特召的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材：需要以「GMX」怪兽＋恐龙族怪兽作为素材
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
-- 融合素材1过滤条件：属于「GMX」字段的卡
function s.matfilter1(c)
	return c:IsFusionSetCard(0x1dd)
end
-- 融合素材2过滤条件：恐龙族怪兽
function s.matfilter2(c)
	return c:IsRace(RACE_DINOSAUR)
end
-- 过滤条件：检查该怪兽的召唤/特殊召唤玩家是否为指定玩家
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 回复效果发动条件：对方把怪兽召唤·特殊召唤
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 回复效果的执行：展示卡片并回复自己200生命值
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示该效果卡片发动
	Duel.Hint(HINT_CARD,0,id)
	-- 回复自己200生命值
	Duel.Recover(tp,200,REASON_EFFECT)
end
-- 效果3发动条件：只在对方回合才能发动
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤条件：「GMX」怪兽或者恐龙族怪兽，且能加入手卡或特殊召唤
function s.thfilter(c,e,tp,chk)
	return (c:IsSetCard(0x1dd) and c:IsType(TYPE_MONSTER) or c:IsRace(RACE_DINOSAUR))
		-- 判断该卡是否能加入手卡，或者是否满足特殊召唤的条件及场上有空余位置
		and (not chk or c:IsAbleToHand() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果3的发动准备：以对方场上1张卡为对象，并确认自己卡组存在能被检索/特殊召唤的卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 判断对方场上是否存在可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
		-- 且自己卡组中存在至少1张符合翻卡加入手卡或特殊召唤条件的卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,true) end
	-- 给玩家提示选择要破坏的对象卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：包含破坏选择的目标卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果3的执行：直到「GMX」怪兽或者恐龙族怪兽出现为止从自己卡组上面翻卡，自己失去翻开的卡的数量×400的基本分，那只「GMX」怪兽或者恐龙族怪兽加入手卡或特殊召唤，剩下的卡回到卡组，并且再把作为对象的卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中作为对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 获取卡组中所有符合翻卡条件的「GMX」怪兽或者恐龙族怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,e,tp,false)
	-- 获取自己卡组的卡片总数
	local dct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local hc
	-- 遍历所有符合条件的怪兽，找出在卡组中最靠近顶端的一张
	for dc in aux.Next(g) do
		local sq=dc:GetSequence()
		if sq>seq then
			seq=sq
			hc=dc
		end
	end
	if seq>-1 then
		-- 确认并翻开自己卡组最上方直到符合条件怪兽位置的卡
		Duel.ConfirmDecktop(tp,dct-seq)
		if e:GetHandler():IsSetCard(0x1dd) then
			-- 触发特定自定义事件以配合其他相关效果处理
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
		end
		-- 在此次卡组操作中禁用系统自动洗牌检测
		Duel.DisableShuffleCheck()
		-- 失去翻开卡片数量×400的基本分
		Duel.SetLP(tp,Duel.GetLP(tp)-(dct-seq)*400)
		-- 检查是否满足将翻到的怪兽特殊召唤的条件和空位
		local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and hc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若能加入手卡且玩家选择加入手卡（或者无法特殊召唤）时
		if hc:IsAbleToHand() and (not spchk or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将翻到的怪兽加入手卡
			Duel.SendtoHand(hc,nil,REASON_EFFECT)
			-- 给对方玩家确认这张加入手卡的怪兽
			Duel.ConfirmCards(1-tp,hc)
		elseif spchk then
			-- 将翻到的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(hc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 根据规则将因无法加入手卡也无法特殊召唤的卡送去墓地
			Duel.SendtoGrave(hc,REASON_RULE)
		end
		-- 将剩下的卡回到卡组并洗牌
		Duel.ShuffleDeck(tp)
		if tc:IsRelateToChain() and tc:IsOnField() then
			-- 中断当前效果处理，使后续的破坏处理不与前面的动作视为同时处理
			Duel.BreakEffect()
			-- 把作为对象的卡破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	else
		-- 如果卡组没有符合条件的怪兽，则确认并翻开自己全部的卡组
		Duel.ConfirmDecktop(tp,dct)
	end
end

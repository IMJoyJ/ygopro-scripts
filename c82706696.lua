--GMX - VELOX
-- 效果：
-- 「GMX」怪兽＋恐龙族怪兽
-- 每次对方把怪兽召唤·特殊召唤，自己回复200基本分。
-- 对方回合（诱发即时效果）：可以以对方场上1张卡为对象；直到「GMX」怪兽或者恐龙族怪兽出现为止从自己卡组上面翻卡，自己失去翻开的卡的数量×400的基本分，那只「GMX」怪兽或者恐龙族怪兽加入手卡或特殊召唤，剩下的卡回到卡组，并且，再把作为对象的卡破坏。「GMX-似鸟人龙」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果，注册融合召唤手续、对方召唤·特殊召唤时自己回复基本分的效果，以及对方回合破坏对方场上卡片并翻卡检索或特召的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为1只「GMX」怪兽和1只恐龙族怪兽
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
-- 融合素材过滤条件1：属于「GMX」系列
function s.matfilter1(c)
	return c:IsFusionSetCard(0x1dd)
end
-- 融合素材过滤条件2：种族为恐龙族
function s.matfilter2(c)
	return c:IsRace(RACE_DINOSAUR)
end
-- 过滤条件：召唤·特殊召唤的玩家是对方
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 回复效果的发动条件：对方成功召唤·特殊召唤怪兽
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 回复效果的处理：自己回复200基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上展示该卡片以提示效果发动
	Duel.Hint(HINT_CARD,0,id)
	-- 使自己回复200基本分
	Duel.Recover(tp,200,REASON_EFFECT)
end
-- 破坏效果的发动条件：当前是对方回合
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤条件：卡组中的「GMX」怪兽或恐龙族怪兽，且能加入手卡或特殊召唤
function s.thfilter(c,e,tp,chk)
	return (c:IsSetCard(0x1dd) and c:IsType(TYPE_MONSTER) or c:IsRace(RACE_DINOSAUR))
		-- 判断卡片是否能加入手卡，或者在怪兽区域有空位时是否能特殊召唤
		and (not chk or c:IsAbleToHand() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 破坏效果的发动准备（选取对象与可行性检查）
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查卡组中是否存在满足条件的「GMX」怪兽或恐龙族怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,true) end
	-- 设置选择卡片时的提示信息为“选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：包含破坏对方场上卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的效果处理（翻卡、失去基本分、加入手卡或特殊召唤、破坏对象）
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的卡
	local tc=Duel.GetFirstTarget()
	-- 获取卡组中所有满足条件的「GMX」怪兽或恐龙族怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,e,tp,false)
	-- 获取当前卡组的卡片总数
	local dct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local hc
	-- 遍历卡组中满足条件的卡，找出最靠近卡组顶端（序号最大）的那一张
	for dc in aux.Next(g) do
		local sq=dc:GetSequence()
		if sq>seq then
			seq=sq
			hc=dc
		end
	end
	if seq>-1 then
		-- 从卡组最上方开始确认（翻开）卡片，直到出现满足条件的卡为止
		Duel.ConfirmDecktop(tp,dct-seq)
		-- 防止系统在后续操作中自动洗牌
		Duel.DisableShuffleCheck()
		-- 扣除自己相当于翻开卡片数量×400的基本分
		Duel.SetLP(tp,Duel.GetLP(tp)-(dct-seq)*400)
		-- 检查翻开的卡是否可以特殊召唤（需要场上有空位且满足召唤条件）
		local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and hc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若能加入手卡，且不能特召或玩家选择加入手卡时
		if hc:IsAbleToHand() and (not spchk or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将翻开的卡加入手卡
			Duel.SendtoHand(hc,nil,REASON_EFFECT)
			-- 向对方展示加入手卡的卡片
			Duel.ConfirmCards(1-tp,hc)
		elseif spchk then
			-- 将翻开的卡在自己场上特殊召唤
			Duel.SpecialSummon(hc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 若既不能加入手卡也不能特殊召唤，则因规则送去墓地
			Duel.SendtoGrave(hc,REASON_RULE)
		end
		-- 将卡组剩下的卡洗切
		Duel.ShuffleDeck(tp)
		if tc:IsRelateToChain() and tc:IsOnField() then
			-- 中断当前效果处理，使后续的破坏处理不与前面的处理同时进行
			Duel.BreakEffect()
			-- 破坏作为对象的卡
			Duel.Destroy(tc,REASON_EFFECT)
		end
	else
		-- 若卡组中没有满足条件的卡，则确认整个卡组
		Duel.ConfirmDecktop(tp,dct)
	end
end

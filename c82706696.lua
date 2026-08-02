--GMX－VELOX
-- 效果：
-- 「GMX」怪兽＋恐龙族怪兽
-- 每次对方把怪兽召唤·特殊召唤，自己回复200基本分。
-- 对方回合（诱发即时效果）：可以以对方场上1张卡为对象；直到「GMX」怪兽或者恐龙族怪兽出现为止从自己卡组上面翻卡，自己失去翻开的卡的数量×400的基本分，那只「GMX」怪兽或者恐龙族怪兽加入手卡或特殊召唤，剩下的卡回到卡组，并且，再把作为对象的卡破坏。「GMX-似鸟人龙」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化函数，设定卡片的融合手续和各个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加需要满足条件的2只怪兽作为融合素材的融合手续
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
-- 融合素材条件1：是「GMX」怪兽
function s.matfilter1(c)
	return c:IsFusionSetCard(0x1dd)
end
-- 融合素材条件2：是恐龙族怪兽
function s.matfilter2(c)
	return c:IsRace(RACE_DINOSAUR)
end
-- 过滤条件：由对方玩家进行召唤或特殊召唤
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 效果发动条件：确认有对方玩家召唤或特殊召唤的怪兽
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 效果处理：播放卡片发动的动画提示并让自己回复200基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 手动显示卡片发动的动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 让自己回复200基本分
	Duel.Recover(tp,200,REASON_EFFECT)
end
-- 效果发动条件：检查当前回合玩家是否为对方
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤条件：是「GMX」怪兽或恐龙族怪兽，并且能够加入手卡或特殊召唤
function s.thfilter(c,e,tp,chk)
	return (c:IsSetCard(0x1dd) and c:IsType(TYPE_MONSTER) or c:IsRace(RACE_DINOSAUR))
		-- 判断是否能够加入手卡，或者场上有空位且能够特殊召唤
		and (not chk or c:IsAbleToHand() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果目标设置：检查发动条件并选择对方场上1张卡作为对象，同时检查卡组中是否有满足条件的怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动条件检查：确认对方场上存在至少1张可以作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
		-- 发动条件检查：确认卡组中存在至少1只可以加入手卡或特殊召唤的「GMX」怪兽或恐龙族怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,true) end
	-- 向玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上的1张卡作为对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏操作的连锁信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：翻卡、失去基本分、处理翻到的怪兽、洗切卡组并破坏对象卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	-- 检索卡组中所有符合条件的「GMX」怪兽和恐龙族怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,e,tp,false)
	-- 获取自己卡组当前的卡片总数
	local dct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local hc
	-- 遍历卡组中符合条件的怪兽以确定需要翻几张卡（找到最上面的一只）
	for dc in aux.Next(g) do
		local sq=dc:GetSequence()
		if sq>seq then
			seq=sq
			hc=dc
		end
	end
	if seq>-1 then
		-- 向对方确认从卡组顶端翻开直到出现目标怪兽的所有卡
		Duel.ConfirmDecktop(tp,dct-seq)
		if e:GetHandler():IsSetCard(0x1dd) then
			-- 触发相关的事件时点
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
		end
		-- 使接下来的操作不触发自动的洗卡检测
		Duel.DisableShuffleCheck()
		-- 计算翻开的卡的数量，并让自己失去相应的基本分
		Duel.SetLP(tp,Duel.GetLP(tp)-(dct-seq)*400)
		-- 检查主要怪兽区域是否有空位且该怪兽能否被特殊召唤
		local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and hc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 如果该卡能加入手卡，并且不能特召或者玩家选择加入手卡
		if hc:IsAbleToHand() and (not spchk or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将目标怪兽加入手卡
			Duel.SendtoHand(hc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,hc)
		elseif spchk then
			-- 将目标怪兽特殊召唤到自己场上
			Duel.SpecialSummon(hc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 如果不满足加入手卡或特召条件则因规则送去墓地
			Duel.SendtoGrave(hc,REASON_RULE)
		end
		-- 洗切卡组
		Duel.ShuffleDeck(tp)
	end
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 中断效果处理，使后续破坏与前面的操作视为不同时处理
		Duel.BreakEffect()
		-- 破坏作为对象的卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

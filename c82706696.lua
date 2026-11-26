--GMX－VELOX
-- 效果：
-- 「GMX」怪兽＋恐龙族怪兽
-- 每次对方把怪兽召唤·特殊召唤，自己回复200基本分。
-- 对方回合（诱发即时效果）：可以以对方场上1张卡为对象；直到「GMX」怪兽或者恐龙族怪兽出现为止从自己卡组上面翻卡，自己失去翻开的卡的数量×400的基本分，那只「GMX」怪兽或者恐龙族怪兽加入手卡或特殊召唤，剩下的卡回到卡组，并且，再把作为对象的卡破坏。「GMX-似鸟人龙」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：设置苏生限制与融合素材条件，并注册①对方召唤·特召怪兽时回血200的永续效果和②对方回合翻卡找怪兽并破坏对象卡的二速效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：由满足matfilter1（「基因组混合」怪兽）与matfilter2（恐龙族怪兽）的怪兽各1只作为融合素材
	aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)
	-- ①：每次对方把怪兽召唤·特殊召唤，自己回复200基本分。
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
	-- 这个卡名的②的效果1回合只能使用1次。②：对方回合，以对方场上1张卡为对象才能发动。以下效果全部适用。●直到「基因组混合」怪兽或恐龙族怪兽出现为止从自己卡组上面翻卡，自己失去翻开数量×400基本分。那只怪兽加入手卡或特殊召唤。剩余回到卡组。●作为对象的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_DESTROY)
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
-- 融合素材1过滤函数：筛选融合字段为「基因组混合」（0x1dd）的怪兽
function s.matfilter1(c)
	return c:IsFusionSetCard(0x1dd)
end
-- 融合素材2过滤函数：筛选种族为恐龙族的怪兽
function s.matfilter2(c)
	return c:IsRace(RACE_DINOSAUR)
end
-- 过滤是否为指定玩家tp所召唤或特殊召唤的怪兽
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 检查①效果触发条件：本次召唤·特殊召唤事件中存在对方玩家召唤或特召的怪兽
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- ①效果处理：显示卡片提示并使己方回复200基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方显示此卡效果生效的提示动画
	Duel.Hint(HINT_CARD,0,id)
	-- 使己方玩家以效果回复200点基本分
	Duel.Recover(tp,200,REASON_EFFECT)
end
-- 检查②效果发动条件：当前是否为对方回合
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前的回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤「基因组混合」怪兽或恐龙族怪兽（在发动校验chk为true时还需检查其可加入手卡或可特召）
function s.thfilter(c,e,tp,chk)
	return (c:IsSetCard(0x1dd) and c:IsType(TYPE_MONSTER) or c:IsRace(RACE_DINOSAUR))
		-- 当chk为true时，确认该怪兽能加入手卡或在己方怪兽区有空位时可被特殊召唤
		and (not chk or c:IsAbleToHand() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ②效果取对象校验：确认对方场上有可选卡片且卡组存在满足thfilter的怪兽，选择1张对方场上卡片为对象并登记破坏信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动前确认对方场上是否存在至少1张可成为效果对象的卡片
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
		-- 并确认己方卡组存在满足条件且能回手或特召的「基因组混合」或恐龙族怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,true) end
	-- 向己方发送选择要破坏的对方场上卡片的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让己方以对方场上1张卡为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记破坏所选对象卡片的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：从卡组顶翻卡直至出现目标怪兽并失去对应数量×400基本分，将该怪兽加入手卡或特召、洗切剩余卡组，最后破坏对象卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁指定的破坏对象卡片
	local tc=Duel.GetFirstTarget()
	-- 获取己方卡组中所有「基因组混合」怪兽或恐龙族怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,e,tp,false)
	-- 获取己方卡组当前的卡片总数
	local dct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local hc
	-- 遍历符合条件的卡组怪兽，通过比较序号seq找出最靠近卡组顶端的一张hc
	for dc in aux.Next(g) do
		local sq=dc:GetSequence()
		if sq>seq then
			seq=sq
			hc=dc
		end
	end
	if seq>-1 then
		-- 从卡组最上方翻开并向双方确认dct-seq张卡（直至最顶端的目标怪兽）
		Duel.ConfirmDecktop(tp,dct-seq)
		if e:GetHandler():IsSetCard(0x1dd) then
			-- 若此卡属于「基因组混合」字段，触发自定义事件（配合相关协同卡检测翻卡效果）
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
		end
		-- 禁用下一次卡组操作的自动洗卡检测
		Duel.DisableShuffleCheck()
		-- 使己方失去翻开卡片数量（dct-seq）×400点基本分
		Duel.SetLP(tp,Duel.GetLP(tp)-(dct-seq)*400)
		-- 判定翻出的目标怪兽hc当前是否满足特殊召唤条件
		local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and hc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若目标怪兽能加入手卡，且无法特召或玩家选择加入手卡，则执行加入手卡分支
		if hc:IsAbleToHand() and (not spchk or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将翻出的目标怪兽以效果加入己方手卡
			Duel.SendtoHand(hc,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的目标怪兽
			Duel.ConfirmCards(1-tp,hc)
		elseif spchk then
			-- 将翻出的目标怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(hc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 若该怪兽既无法加入手卡也无法特殊召唤，按规则将其送去墓地
			Duel.SendtoGrave(hc,REASON_RULE)
		end
		-- 洗切己方卡组，将翻开的其余卡片回到卡组
		Duel.ShuffleDeck(tp)
	end
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 插入效果处理间断，使翻卡结算与后续破坏对象卡视为不同时处理
		Duel.BreakEffect()
		-- 将作为对象的对方场上卡片以效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

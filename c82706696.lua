--GMX－VELOX
-- 效果：
-- 「GMX」怪兽＋恐龙族怪兽
-- 每次对方把怪兽召唤·特殊召唤，自己回复200基本分。
-- 对方回合（诱发即时效果）：可以以对方场上1张卡为对象；直到「GMX」怪兽或者恐龙族怪兽出现为止从自己卡组上面翻卡，自己失去翻开的卡的数量×400的基本分，那只「GMX」怪兽或者恐龙族怪兽加入手卡或特殊召唤，剩下的卡回到卡组，并且，再把作为对象的卡破坏。「GMX-似鸟人龙」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册融合召唤手续、对方召·特召回复LP效果、对方回合翻卡加手/特召并破坏对方场上卡效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册2卡融合素材：1只「GMX」怪兽 + 1只恐龙族怪兽
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
	-- 对方回合：可以以对方场上1张卡为对象；直到「GMX」怪兽或者恐龙族怪兽出现为止从自己卡组上面翻卡，自己失去翻开的卡的数量×400的基本分，那只「GMX」怪兽或者恐龙族怪兽加入手卡或特殊召唤，剩下的卡回到卡组，并且，再把作为对象的卡破坏。
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
-- 融合素材1过滤：卡名带有「GMX」的怪兽
function s.matfilter1(c)
	return c:IsFusionSetCard(0x1dd)
end
-- 融合素材2过滤：恐龙族怪兽
function s.matfilter2(c)
	return c:IsRace(RACE_DINOSAUR)
end
-- 过滤条件：召唤·特殊召唤怪兽的玩家
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 回复LP效果发动条件：对方成功召唤或特殊召唤了怪兽
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 回复LP效果处理：显示发动动画并回复自己200基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片发动提示动画
	Duel.Hint(HINT_CARD,0,id)
	-- 回复发动玩家200基本分
	Duel.Recover(tp,200,REASON_EFFECT)
end
-- 破坏效果发动条件：当前为对方回合
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 翻卡目标过滤条件：卡组中的「GMX」怪兽或恐龙族怪兽（且可加手或可特召）
function s.thfilter(c,e,tp,chk)
	return (c:IsSetCard(0x1dd) and c:IsType(TYPE_MONSTER) or c:IsRace(RACE_DINOSAUR))
		-- 检查目标卡是否可加入手牌，或怪兽区域有空位且可特殊召唤
		and (not chk or c:IsAbleToHand() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 破坏效果发动准备：选择对方场上1张卡为对象，并设置破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动条件检查：对方场上存在可取对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
		-- 发动条件检查：自己卡组中存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,true) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为连锁对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：破坏选中的对象卡1张
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：从卡组顶部翻卡至目标怪兽，扣除LP，将目标卡加手或特召后洗牌，再破坏对象卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的破坏对象卡
	local tc=Duel.GetFirstTarget()
	-- 获取卡组中所有符合条件的「GMX」怪兽或恐龙族怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,e,tp,false)
	-- 获取自己卡组当前的卡片数量
	local dct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local hc
	-- 遍历寻找卡组中最靠顶部的目标怪兽
	for dc in aux.Next(g) do
		local sq=dc:GetSequence()
		if sq>seq then
			seq=sq
			hc=dc
		end
	end
	if seq>-1 then
		-- 从卡组上面翻开卡直到出现第一只目标怪兽
		Duel.ConfirmDecktop(tp,dct-seq)
		if e:GetHandler():IsSetCard(0x1dd) then
			-- 触发特定自定义事件通知
			Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
		end
		-- 禁用卡组自动洗牌检查
		Duel.DisableShuffleCheck()
		-- 扣除自己翻开卡数量×400的基本分
		Duel.SetLP(tp,Duel.GetLP(tp)-(dct-seq)*400)
		-- 检查目标怪兽是否可以特殊召唤到怪兽区域
		local spchk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and hc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断目标怪兽加入手牌或特殊召唤的处理分支
		if hc:IsAbleToHand() and (not spchk or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将翻出的目标怪兽加入手牌
			Duel.SendtoHand(hc,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的怪兽
			Duel.ConfirmCards(1-tp,hc)
		elseif spchk then
			-- 将翻出的目标怪兽表侧表示特殊召唤
			Duel.SpecialSummon(hc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 若无法加手也无法特召则根据规则送去墓地
			Duel.SendtoGrave(hc,REASON_RULE)
		end
		-- 将其余翻开的卡回到卡组并洗牌
		Duel.ShuffleDeck(tp)
	end
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 连接效果处理步骤
		Duel.BreakEffect()
		-- 破坏作为对象的卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

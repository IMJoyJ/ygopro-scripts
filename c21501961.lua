--恐依のペアルックマ！！
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果在决斗中只能使用1次。
-- ①：对方可以从自身的手卡·卡组把1张「恐依的情侣款凶熊！！」给人观看。给人观看的场合，双方回复2000基本分。没给人观看的场合，自己把对方场上1只怪兽破坏。
-- ②：这张卡从场上送去墓地的场合发动。这张卡加入对方手卡。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果
function s.initial_effect(c)
	-- ①：对方可以从自身的手卡·卡组把1张「恐依的情侣款凶熊！！」给人观看。给人观看的场合，双方回复2000基本分。没给人观看的场合，自己把对方场上1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合发动。这张卡加入对方手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 设置①效果的发动条件和处理函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的怪兽
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 判断对方手卡和卡组中是否有此卡
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND+LOCATION_DECK)==0 then
		-- 设置破坏效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 定义过滤函数，用于筛选未公开的此卡
function s.pfilter(c)
	return c:IsCode(id) and not c:IsPublic()
end
-- 处理①效果的发动，判断是否给对方观看并执行相应处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方手卡和卡组中是否存在未公开的此卡
	if Duel.IsExistingMatchingCard(s.pfilter,tp,0,LOCATION_HAND+LOCATION_DECK,1,nil)
		-- 询问对方是否给对方观看此卡
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then  --"是否给人观看？"
		-- 提示对方选择要确认的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 选择对方手卡或卡组中的一张未公开的此卡
		local g=Duel.SelectMatchingCard(1-tp,s.pfilter,1-tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(tp,g)
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 若所选卡在手卡中则洗切对方手卡
			Duel.ShuffleHand(1-tp)
		else
			-- 若所选卡在卡组中则洗切对方卡组
			Duel.ShuffleDeck(1-tp)
		end
		-- 自己回复2000基本分
		Duel.Recover(tp,2000,REASON_EFFECT,true)
		-- 对方回复2000基本分
		Duel.Recover(1-tp,2000,REASON_EFFECT,true)
		-- 完成回复LP的处理
		Duel.RDComplete()
		return
	end
	-- 提示选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1只怪兽
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 显示所选怪兽被破坏的动画
		Duel.HintSelection(g)
		-- 破坏所选怪兽
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 设置②效果的发动条件
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 设置②效果的处理函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置加入对方手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 处理②效果的发动，将此卡加入对方手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否与连锁相关且未受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡加入对方手卡
		Duel.SendtoHand(c,1-tp,REASON_EFFECT)
		-- 向对方确认此卡被加入手卡
		Duel.ConfirmCards(tp,c)
	end
end

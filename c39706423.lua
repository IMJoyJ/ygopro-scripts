--GMX鎮圧部隊アプト
-- 效果：
-- 这张卡在手卡存在，自己场上有「GMX」怪兽或者恐龙族怪兽存在的场合：可以把这张卡特殊召唤。
-- 可以以场上1只表侧表示怪兽为对象；直到恐龙族怪兽出现为止从自己卡组上面翻卡，那只恐龙族怪兽送去墓地，作为对象的怪兽直到回合结束时变成恐龙族，剩下的卡回到卡组。
-- 「GMX镇压小队」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 创建两个效果，第一个效果为手卡特殊召唤，第二个效果为翻卡并改变对象怪兽种族
function s.initial_effect(c)
	-- 这张卡在手卡存在，自己场上有「GMX」怪兽或者恐龙族怪兽存在的场合：可以把这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	-- 可以以场上1只表侧表示怪兽为对象；直到恐龙族怪兽出现为止从自己卡组上面翻卡，那只恐龙族怪兽送去墓地，作为对象的怪兽直到回合结束时变成恐龙族，剩下的卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"翻卡"
	e2:SetCategory(CATEGORY_DECKDES+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.exctg)
	e2:SetOperation(s.excop)
	c:RegisterEffect(e2)
end
-- 用于判断场上的怪兽是否满足「GMX」或恐龙族条件
function s.fieldfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR))
end
-- 检查场上是否存在满足fieldfilter条件的怪兽
function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足fieldfilter条件的怪兽
	return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置特殊召唤的发动条件和目标
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 用于筛选目标怪兽，必须是表侧表示且不在恐龙族中
function s.tgfilter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and not c:IsRace(RACE_DINOSAUR)
end
-- 用于筛选卡组中的恐龙族怪兽
function s.exctgfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设置翻卡效果的发动条件和目标
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	-- 检查场上是否存在满足tgfilter条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查卡组中是否存在满足exctgfilter条件的怪兽
		and Duel.IsExistingMatchingCard(s.exctgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上满足条件的目标怪兽
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置将卡组顶部怪兽送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置将卡组顶部怪兽送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_DECK)
end
-- 判断是否为恐龙族且为怪兽类型的卡片
function s.deckdino(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsType(TYPE_MONSTER)
end
-- 确认卡组顶部的卡片，根据数量决定使用ConfirmDecktop或ConfirmCards
function s.confirm_decktop_s(tp,count)
	local max_decktop=5
	if count>max_decktop then
		-- 获取卡组最上方count张卡
		local g=Duel.GetDecktopGroup(tp,count)
		-- 向对方玩家确认这些卡
		Duel.ConfirmCards(1-tp,g)
	else
		-- 向玩家确认卡组最上方count张卡
		Duel.ConfirmDecktop(tp,count)
	end
end
-- 执行翻卡效果的处理逻辑，包括寻找恐龙族怪兽、确认卡片、改变对象怪兽种族等
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足deckdino条件的怪兽
	local mg=Duel.GetMatchingGroup(s.deckdino,tp,LOCATION_DECK,0,nil)
	if mg:GetCount()==0 then return end
	-- 获取玩家卡组中的卡数
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local qc=nil
	-- 遍历所有符合条件的恐龙族怪兽
	for sc in aux.Next(mg) do
		if sc:GetSequence()>seq then
			seq=sc:GetSequence()
			qc=sc
		end
	end
	if not qc then return end
	s.confirm_decktop_s(tp,dcount-seq)
	if e:GetHandler():IsSetCard(0x1dd) then
		-- 触发自定义事件，用于标记该卡已发动效果
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
	end
	if qc:IsAbleToGrave() then
		-- 将找到的恐龙族怪兽送去墓地
		Duel.SendtoGrave(qc,REASON_EFFECT)
		-- 洗切玩家卡组
		Duel.ShuffleDeck(tp)
		-- 获取当前连锁的目标怪兽
		local tc=Duel.GetFirstTarget()
		if not tc or not tc:IsRelateToChain() or not tc:IsFaceup() or not tc:IsOnField() then return end
		-- 为对象怪兽添加种族变更效果，使其变为恐龙族
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(RACE_DINOSAUR)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

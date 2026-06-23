--GMX Suppression Squad
-- 效果：
-- 这张卡在手卡存在，自己场上有「GMX」怪兽或者恐龙族怪兽存在的场合：可以把这张卡特殊召唤。
-- 可以以场上1只表侧表示怪兽为对象；直到恐龙族怪兽出现为止从自己卡组上面翻卡，那只恐龙族怪兽送去墓地，作为对象的怪兽直到回合结束时变成恐龙族，剩下的卡回到卡组。
-- 「GMX镇压小队」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册卡片效果的函数
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
-- 过滤函数：自己场上表侧表示的「GMX」怪兽或恐龙族怪兽
function s.fieldfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR))
end
-- 特殊召唤效果的发动条件判定函数
function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「GMX」怪兽或恐龙族怪兽
	return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的发动准备与合法性检测函数
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：包含特殊召唤这张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的效果处理函数
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡正面表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：场上表侧表示且非恐龙族的怪兽
function s.tgfilter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and not c:IsRace(RACE_DINOSAUR)
end
-- 过滤函数：卡组中能送去墓地的恐龙族怪兽
function s.exctgfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 翻卡效果的发动准备与合法性检测函数
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	-- 检测场上是否存在可以作为对象的表侧表示且非恐龙族的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检测自己卡组是否存在可以送去墓地的恐龙族怪兽
		and Duel.IsExistingMatchingCard(s.exctgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 给玩家提示：选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示且非恐龙族的怪兽作为效果的对象
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：包含从卡组送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置连锁操作信息：包含从卡组回到卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数：卡组中的恐龙族怪兽
function s.deckdino(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsType(TYPE_MONSTER)
end
-- 确认自己卡组最上方指定数量卡片的辅助函数
function s.confirm_decktop_s(tp,count)
	local max_decktop=5
	if count>max_decktop then
		-- 获取自己卡组最上方指定数量的卡片组
		local g=Duel.GetDecktopGroup(tp,count)
		-- 给对方玩家确认翻开的卡片组
		Duel.ConfirmCards(1-tp,g)
	else
		-- 确认自己卡组最上方指定数量的卡片
		Duel.ConfirmDecktop(tp,count)
	end
end
-- 翻卡效果的效果处理函数
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有的恐龙族怪兽
	local mg=Duel.GetMatchingGroup(s.deckdino,tp,LOCATION_DECK,0,nil)
	if mg:GetCount()==0 then return end
	-- 获取自己卡组的卡片总数
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local qc=nil
	-- 遍历卡组中的恐龙族怪兽
	for sc in aux.Next(mg) do
		if sc:GetSequence()>seq then
			seq=sc:GetSequence()
			qc=sc
		end
	end
	if not qc then return end
	s.confirm_decktop_s(tp,dcount-seq)
	if e:GetHandler():IsSetCard(0x1dd) then
		-- 触发自定义事件
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
	end
	if qc:IsAbleToGrave() then
		-- 将翻出的恐龙族怪兽送去墓地
		Duel.SendtoGrave(qc,REASON_EFFECT)
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 获取效果的对象怪兽
		local tc=Duel.GetFirstTarget()
		if not tc or not tc:IsRelateToChain() or not tc:IsFaceup() or not tc:IsOnField() then return end
		-- 作为对象的怪兽直到回合结束时变成恐龙族
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(RACE_DINOSAUR)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

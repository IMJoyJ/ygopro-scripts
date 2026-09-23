--GMX鎮圧部隊アプト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，「基因组混合」怪兽或恐龙族怪兽在自己场上存在的场合才能发动。这张卡特殊召唤。
-- ②：以场上1只表侧表示怪兽为对象才能发动。直到恐龙族怪兽出现为止从自己卡组上面翻卡，那只恐龙族怪兽送去墓地，作为对象的怪兽的种族直到回合结束时变成恐龙族。剩下的翻开的卡回到卡组。
local s,id,o=GetID()
-- 初始化卡片效果：注册手卡起动特殊召唤效果及场上起动翻卡变种族效果
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在手卡存在，「基因组混合」怪兽或恐龙族怪兽在自己场上存在的场合才能发动。这张卡特殊召唤。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：以场上1只表侧表示怪兽为对象才能发动。直到恐龙族怪兽出现为止从自己卡组上面翻卡，那只恐龙族怪兽送去墓地，作为对象的怪兽的种族直到回合结束时变成恐龙族。剩下的翻开的卡回到卡组。
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
-- 过滤自己场上表侧表示的「基因组混合」怪兽或恐龙族怪兽
function s.fieldfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR))
end
-- 效果发动条件：自己场上有「基因组混合」怪兽或恐龙族怪兽存在
function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「基因组混合」怪兽或恐龙族怪兽
	return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动目标检查
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空闲的主要怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：特殊召唤自身
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自身表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤场上表侧表示、非恐龙族的怪兽
function s.tgfilter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and not c:IsRace(RACE_DINOSAUR)
end
-- 过滤卡组中可送去墓地的恐龙族怪兽
function s.exctgfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果发动取对象及合法性检查
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	-- 检查场上是否存在表侧表示的非恐龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查卡组中是否存在可送去墓地的恐龙族怪兽
		and Duel.IsExistingMatchingCard(s.exctgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示非恐龙族怪兽作为对象
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：从卡组把卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：翻开的卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_DECK)
end
-- 过滤卡组中的恐龙族怪兽
function s.deckdino(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsType(TYPE_MONSTER)
end
-- 根据翻卡数量确认卡组最上方的卡片
function s.confirm_decktop_s(tp,count)
	local max_decktop=5
	if count>max_decktop then
		-- 获取卡组最上方的卡片组
		local g=Duel.GetDecktopGroup(tp,count)
		-- 向对方展示卡组最上方的卡片
		Duel.ConfirmCards(1-tp,g)
	else
		-- 翻开并确认卡组最上方的卡片
		Duel.ConfirmDecktop(tp,count)
	end
end
-- 效果处理：从卡组上面翻卡至恐龙族怪兽送墓，对象怪兽变为恐龙族，其余卡回卡组洗牌
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有的恐龙族怪兽
	local mg=Duel.GetMatchingGroup(s.deckdino,tp,LOCATION_DECK,0,nil)
	if mg:GetCount()==0 then return end
	-- 获取卡组当前的卡片总数
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local qc=nil
	-- 遍历卡组中的恐龙族怪兽以定位最靠近卡组顶端的恐龙族
	for sc in aux.Next(mg) do
		if sc:GetSequence()>seq then
			seq=sc:GetSequence()
			qc=sc
		end
	end
	if not qc then return end
	s.confirm_decktop_s(tp,dcount-seq)
	if e:GetHandler():IsSetCard(0x1dd) then
		-- 触发「基因组混合」专属自定义事件
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
	end
	if qc:IsAbleToGrave() then
		-- 将翻出的恐龙族怪兽送去墓地
		Duel.SendtoGrave(qc,REASON_EFFECT)
		-- 洗切卡组（将其余翻开的卡返回卡组）
		Duel.ShuffleDeck(tp)
		-- 获取作为效果对象的怪兽
		local tc=Duel.GetFirstTarget()
		if not qc:IsLocation(LOCATION_GRAVE) or not tc or not tc:IsRelateToChain() or not tc:IsFaceup() or not tc:IsOnField() then return end
		-- 作为对象的怪兽的种族直到回合结束时变成恐龙族。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(RACE_DINOSAUR)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

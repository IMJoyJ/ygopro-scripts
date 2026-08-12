--GMX鎮圧部隊アプト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，「基因组混合」怪兽或恐龙族怪兽在自己场上存在的场合才能发动。这张卡特殊召唤。
-- ②：以场上1只表侧表示怪兽为对象才能发动。直到恐龙族怪兽出现为止从自己卡组上面翻卡，那只恐龙族怪兽送去墓地，作为对象的怪兽的种族直到回合结束时变成恐龙族。剩下的翻开的卡回到卡组。
local s,id,o=GetID()
-- 初始化并注册两个效果：e1为手卡发动的起动效果，含特殊召唤分类，1回合1次（id计数），负责①效果的从手卡特殊召唤；e2为场上发动的取对象起动效果，含卡组送墓分类，1回合1次（id+o计数），负责②效果的翻卡、送墓及变更种族处理
function s.initial_effect(c)
	-- ①：这张卡在手卡存在，「基因组混合」怪兽或恐龙族怪兽在自己场上存在的场合才能发动。这张卡特殊召唤。
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
	-- ②：以场上1只表侧表示怪兽为对象才能发动。直到恐龙族怪兽出现为止从自己卡组上面翻卡，那只恐龙族怪兽送去墓地，作为对象的怪兽的种族直到回合结束时变成恐龙族。剩下的翻开的卡回到卡组。
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
-- 过滤函数：表侧表示且为「基因组混合」怪兽或恐龙族怪兽的卡
function s.fieldfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR))
end
-- ①效果发动条件：自己场上存在表侧表示的「基因组混合」怪兽或恐龙族怪兽
function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区是否存在至少1只满足条件的「基因组混合」怪兽或恐龙族怪兽
	return Duel.IsExistingMatchingCard(s.fieldfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果目标函数：发动可行性检查——确认自己场上还有空余主要怪兽区格子，且这张卡可以被特殊召唤
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否还有空格子（用于确定能否特殊召唤）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本次效果处理将特殊召唤这张卡（1张），用于星尘龙等卡的发动检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与本连锁相关（未被无效或离场），则将其特殊召唤
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡从手卡特殊召唤到自己场上，表侧表示
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 对象过滤函数：场上主要怪兽区的表侧表示且种族不是恐龙族的怪兽
function s.tgfilter(c)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and not c:IsRace(RACE_DINOSAUR)
end
-- 卡组过滤函数：恐龙族怪兽且能送去墓地的卡
function s.exctgfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ②效果目标函数：检查对象是否为场上满足条件的表侧表示非恐龙族怪兽；发动可行性检查——场上存在可取为对象的满足条件怪兽，且自己卡组存在能送去墓地的恐龙族怪兽
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc) end
	-- 检查双方场上是否存在至少1只可取为对象的表侧表示非恐龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 并检查自己卡组中是否存在至少1只能够送去墓地的恐龙族怪兽
		and Duel.IsExistingMatchingCard(s.exctgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向发动玩家发送选择提示：请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择场上1只表侧表示的非恐龙族怪兽作为本效果的对象
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明处理时将把卡组的1张卡送去墓地（具体卡处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：声明处理时将把卡组的卡回到卡组（翻开后剩余的卡）
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数：恐龙族的怪兽卡（用于在卡组中寻找最上方的那只恐龙族怪兽）
function s.deckdino(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsType(TYPE_MONSTER)
end
-- 辅助函数：给双方确认卡组上方的count张卡；超过5张时改用整组确认的方式（避开ConfirmDecktop的张数限制），否则直接确认卡组上方
function s.confirm_decktop_s(tp,count)
	local max_decktop=5
	if count>max_decktop then
		-- 取得自己卡组最上方的count张卡
		local g=Duel.GetDecktopGroup(tp,count)
		-- 让对方玩家确认这组卡组上方的卡
		Duel.ConfirmCards(1-tp,g)
	else
		-- 确认自己卡组最上方的count张卡（双方可见）
		Duel.ConfirmDecktop(tp,count)
	end
end
-- ②效果处理：从自己卡组找出位置最靠上的恐龙族怪兽，翻开它及其上方的卡给双方确认；若自身为「基因组混合」卡则触发对应自定义时点；把那只恐龙族怪兽送去墓地并洗切卡组，然后给对象怪兽注册直到回合结束时种族变成恐龙族的永续效果
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己卡组中所有恐龙族怪兽，用于定位最上方的恐龙族怪兽
	local mg=Duel.GetMatchingGroup(s.deckdino,tp,LOCATION_DECK,0,nil)
	if mg:GetCount()==0 then return end
	-- 取得自己卡组的总张数，用于计算需要翻开的卡数
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local seq=-1
	local qc=nil
	-- 遍历卡组中的恐龙族怪兽，找出序列号最大（即位置最靠卡组上方）的那只
	for sc in aux.Next(mg) do
		if sc:GetSequence()>seq then
			seq=sc:GetSequence()
			qc=sc
		end
	end
	if not qc then return end
	s.confirm_decktop_s(tp,dcount-seq)
	if e:GetHandler():IsSetCard(0x1dd) then
		-- 若这张卡是「基因组混合」卡，则触发自定义事件时点，供「基因组混合」系列的联动效果检测翻卡行为
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
	end
	if qc:IsAbleToGrave() then
		-- 把找到的那只恐龙族怪兽因效果送去墓地
		Duel.SendtoGrave(qc,REASON_EFFECT)
		-- 洗切自己的卡组（对应剩下的翻开的卡回到卡组）
		Duel.ShuffleDeck(tp)
		-- 取得本连锁的对象怪兽（之前选择的表侧表示非恐龙族怪兽）
		local tc=Duel.GetFirstTarget()
		if not tc or not tc:IsRelateToChain() or not tc:IsFaceup() or not tc:IsOnField() then return end
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

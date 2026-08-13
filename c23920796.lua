--ミミグル・ケルベロス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。
-- ②：对方不能把自己场上的表侧表示的魔法卡作为效果的对象。
-- ③：这张卡在主要阶段反转的场合发动。以下效果各适用。
-- ●从自己卡组上面把3张卡除外。那之后，自己的除外状态的1只怪兽在对方场上守备表示特殊召唤。
-- ●这张卡的控制权移给对方。
local s,id,o=GetID()
-- 为这张卡注册了三个效果：e1对应③的翻转诱发效果，e2对应①的手牌起动效果，e3对应②的永续抗性效果；分别设置了效果描述、分类、类型、条件、目标与操作函数。
function s.initial_effect(c)
	-- ③：这张卡在主要阶段反转的场合发动。以下效果各适用。●从自己卡组上面把3张卡除外。那之后，自己的除外状态的1只怪兽在对方场上守备表示特殊召唤。●这张卡的控制权移给对方。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"反转效果"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_CONTROL+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	-- 设置③效果的发动条件：必须处于主要阶段，且满足「模仿食尸鬼」反转效果的通用条件。
	e1:SetCondition(aux.MimighoulFlipCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：对方不能把自己场上的表侧表示的魔法卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设置②效果的保护范围：自己场上的表侧表示魔法卡；配合e3的Value使对方的卡的效果不能选择这些魔法卡为对象。
	e3:SetTarget(aux.TargetBoolFunction(aux.AND(Card.IsType,Card.IsFaceup),TYPE_SPELL))
	-- 设置②效果的判定逻辑：当试图将本卡控制者场上的表侧魔法卡作为效果的对象的使用者不是本卡控制者时，该对象不能成为效果对象（即对方的效果不能以它们为对象）。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
-- ③效果的目标条件：发动时不做额外条件检查（必发效果），并向系统登记除外、特殊召唤和控制权转移三类操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记③效果中从自己卡组上面除外3张卡的操作信息（不取对象，卡组除外3张）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_DECK)
	-- 登记③效果中从自己的除外区特殊召唤1只怪兽的操作信息（不取对象，预计从除外区特殊召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
	-- 登记③效果中变更控制权的操作信息，对象为本卡，数量1，目标玩家/位置参数由效果处理时决定。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 定义可被③效果特殊召唤到对方场上的怪兽筛选条件：表侧表示，且可以表侧守备表示特殊召唤到对方怪兽区。
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- ③效果的前半段处理：先把卡组最上方3张卡以表侧表示除外；若除外成功且对方怪兽区有空位、自己的除外区有符合条件的怪兽，则提示并选择1只，以表侧守备表示特殊召唤到对方场上。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取出自己卡组最上方的3张卡作为待除外的对象。
	local tg=Duel.GetDecktopGroup(tp,3)
	if #tg==0 then return end
	-- 这次除外是从卡组顶端除外，不会导致卡组顺序变化，因此禁用系统自动洗切卡组的检查。
	Duel.DisableShuffleCheck()
	-- 先执行除外，并判断是否确实除外了卡（成功数>0），同时确认对方怪兽区有可用空格，以决定是否继续特殊召唤。
	if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 且还需确认自己的除外区中存在满足特殊召唤条件的怪兽，才能进行后续选择。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) then
		-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让操作玩家从自己的除外区选择1只满足特殊召唤条件的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			-- 中断当前效果，使后续特殊召唤作为独立的效果处理节点，防止错失时点。
			Duel.BreakEffect()
			-- 把选择的怪兽以表侧守备表示特殊召唤到对方场上。
			Duel.SpecialSummon(g:GetFirst(),0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 再次中断效果，使之后的控制权转移独立处理。
		Duel.BreakEffect()
		-- 将本卡（迷拟宝箱鬼·三头犬）的控制权转移给对方玩家。
		Duel.GetControl(c,1-tp)
	end
end
-- ①效果的发动条件与对象：检查本卡能否从手卡以里侧守备表示特殊召唤到对方场上，以及对方怪兽区是否有空位，并登记特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动判定：本卡可以以里侧守备表示特殊召唤到对方场上，且对方怪兽区有空位。
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 登记①效果中把本卡特殊召唤的操作信息，对象为本卡1张。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：若本卡仍与效果关联，则将其以里侧守备表示特殊召唤到对方场上；成功后让发动者确认那张卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤：将本卡以里侧守备表示特殊召唤到对方场上；若成功则对发动者tp确认该卡的信息。
		if Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)>0 then Duel.ConfirmCards(tp,c) end
	end
end

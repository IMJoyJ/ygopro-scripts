--死霊王 ドーハスーラ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：「死灵王 恶眼」以外的不死族怪兽的效果发动时才能发动（同一连锁上最多1次）。从以下效果让1个适用。这个回合，自己的「死灵王 恶眼」的效果不能有相同效果适用。
-- ●那个效果无效。
-- ●自己或对方的场上·墓地1只怪兽除外。
-- ②：场地区域有表侧表示卡存在的场合，自己·对方的准备阶段才能发动。这张卡从墓地守备表示特殊召唤。
function c39185163.initial_effect(c)
	-- ①：「死灵王 恶眼」以外的不死族怪兽的效果发动时才能发动（同一连锁上最多1次）。从以下效果让1个适用。这个回合，自己的「死灵王 恶眼」的效果不能有相同效果适用。●那个效果无效。●自己或对方的场上·墓地1只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39185163,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c39185163.disrmcon)
	e1:SetTarget(c39185163.disrmtg)
	e1:SetOperation(c39185163.disrmop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：场地区域有表侧表示卡存在的场合，自己·对方的准备阶段才能发动。这张卡从墓地守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39185163,3))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1,39185163)
	e2:SetCondition(c39185163.spcon)
	e2:SetTarget(c39185163.sptg)
	e2:SetOperation(c39185163.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：当前连锁中的效果是怪兽效果，且该怪兽的种族为不死族，并且发动效果的卡不是这张「死灵王 恶眼」自身。
function c39185163.disrmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中读取当前诱发效果的种族和卡号（code1、code2），用于判断是否为本卡以外的不死族怪兽效果。
	local race,code1,code2=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return re:IsActiveType(TYPE_MONSTER) and race&RACE_ZOMBIE>0 and code1~=39185163 and code2~=39185163
end
-- ①效果发动前的可用性检查：b1表示可以选择‘那个效果无效’（连锁可被无效且本回合未用过该选项），b2表示可以选择‘怪兽除外’（场上·墓地存在可除外的怪兽且本回合未用过该选项），只要二者任一成立即可发动。
function c39185163.disrmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查选项1是否可用：当前连锁的效果能够被无效，且本回合还没有适用过‘那个效果无效’选项（以39185163标志记录）。
	local b1=Duel.IsChainDisablable(ev) and Duel.GetFlagEffect(tp,39185163)==0
	-- 检查是否存在可被除外的卡：自己或对方的场上·墓地存在至少1张能被除外的卡（对应‘自己或对方的场上·墓地1只怪兽除外’）。
	local b2=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
		-- 且本回合尚未适用过‘怪兽除外’选项（以39185164标志记录），用来保证同一选项一回合最多适用一次。
		and Duel.GetFlagEffect(tp,39185164)==0
	if chk==0 then return b1 or b2 end
end
-- 选择除外对象的过滤器：目标必须是怪兽且可以被除外，用于后续从场上或墓地选择要除外的怪兽。
function c39185163.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- ①效果处理时的操作：重新确认两个选项的可用性后，让玩家从可用选项中选1个：若选‘那个效果无效’则无效该连锁并标记39185163；若选‘怪兽除外’则选1只怪兽除外并标记39185164，防止本回合重复适用相同选项。
function c39185163.disrmop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新确认选项1仍可用：当前连锁仍可被无效，且本回合尚未选择过‘无效’选项。
	local b1=Duel.IsChainDisablable(ev) and Duel.GetFlagEffect(tp,39185163)==0
	-- 在效果处理时重新确认选项2仍可用：己方或对方的场上·墓地存在至少1只满足过滤条件的可除外怪兽。
	local b2=Duel.IsExistingMatchingCard(c39185163.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil)
		-- 并且本回合尚未选择过‘怪兽除外’选项（39185164标志为0），防止重复适用同一选项。
		and Duel.GetFlagEffect(tp,39185164)==0
	local op=0
	-- 两个选项都可用时，弹出菜单让玩家选择：0对应‘那个效果无效’，1对应‘怪兽除外’。
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(39185163,1),aux.Stringid(39185163,2))  --"效果无效/怪兽除外"
	-- 只有‘那个效果无效’可选时，直接选择该选项（op=0）。
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(39185163,1))  --"效果无效"
	-- 只有‘怪兽除外’可选时，直接选择该选项；因单选项菜单返回0，加1后op=1。
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(39185163,2))+1  --"怪兽除外"
	else return end
	if op==0 then
		-- 适用‘那个效果无效’：将当前连锁的效果无效化。
		Duel.NegateEffect(ev)
		-- 给玩家登记39185163标记，记录本回合已经适用过‘那个效果无效’，让本回合不能再选择这个选项。
		Duel.RegisterFlagEffect(tp,39185163,RESET_PHASE+PHASE_END,0,1)
	else
		-- 向玩家显示‘请选择要除外的卡’的提示信息，供选择卡片时使用。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己或对方的场上·墓地选择1只满足filter的可除外怪兽，并优先从场上选择（符合优先从场上选择的设计）。
		local g=aux.SelectCardFromFieldFirst(tp,c39185163.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
		-- 将选中的卡以表侧表示除外，除外原因为效果处理。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		-- 给玩家登记39185164标记，记录本回合已经适用过‘怪兽除外’，让本回合不能再选择这个选项。
		Duel.RegisterFlagEffect(tp,39185164,RESET_PHASE+PHASE_END,0,1)
	end
end
-- ②效果的发动条件：场地区域存在表侧表示的卡（双方场地魔法区域合计至少有1张表侧表示卡）。
function c39185163.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场地区域是否存在表侧表示卡，若有则②效果可以发动。
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- ②效果发动时的判定：自己的主要怪兽区有空位，且这张卡能够以表侧守备表示从墓地特殊召唤。
function c39185163.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动判定阶段确认自己的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：声明本效果将进行特殊召唤，对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：如果这张卡仍在墓地且与效果保持关联，就将其从墓地以表侧守备表示特殊召唤到自己场上。
function c39185163.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 实际执行特殊召唤：将这张卡以表侧守备表示特殊召唤到控制者场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end

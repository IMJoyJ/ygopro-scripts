--剣闘獣ベストロウリィ
-- 效果：
-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功的场合，以场上1张魔法·陷阱卡为对象发动。那张卡破坏。
-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 枪斗」以外的1只「剑斗兽」怪兽特殊召唤。
function c41470137.initial_effect(c)
	-- ①：这张卡用「剑斗兽」怪兽的效果特殊召唤成功的场合，以场上1张魔法·陷阱卡为对象发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41470137,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 设置效果①的发动条件：仅当这张卡通过「剑斗兽」怪兽的效果成功特殊召唤时才满足（利用剑斗兽通用特殊召唤状态判定）。
	e1:SetCondition(aux.gbspcon)
	e1:SetTarget(c41470137.destg)
	e1:SetOperation(c41470137.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 枪斗」以外的1只「剑斗兽」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41470137,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c41470137.spcon)
	e2:SetCost(c41470137.spcost)
	e2:SetTarget(c41470137.sptg)
	e2:SetOperation(c41470137.spop)
	c:RegisterEffect(e2)
end
-- 定义效果①的取对象筛选条件：选择场上的魔法·陷阱卡（魔法卡或陷阱卡）。
function c41470137.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①发动时的取对象处理：确认本效果为以场上1张魔法·陷阱卡为对象的取对象效果，选择1张符合条件的卡作为对象，并设置破坏该卡的操作信息。
function c41470137.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c41470137.desfilter(chkc) end
	if chk==0 then return true end
	-- 弹出“请选择要破坏的卡”的提示消息，用于后续选择卡片的界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张魔法·陷阱卡作为效果对象，并自动将该卡与当前连锁的效果建立关联。
	local g=Duel.SelectTarget(tp,c41470137.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 向系统登记本次连锁将执行破坏效果，破坏对象为已选择的卡，数量为选择数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①处理时取出对象卡，若对象卡仍与效果关联，则将其破坏。
function c41470137.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出当前连锁的对象卡，即效果①选择的那张魔法·陷阱卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡在本回合进行过战斗（战斗过的怪兽数量大于0），因此可在战斗阶段结束时发动。
function c41470137.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 效果②的发动代价：检查这张卡是否可以作为代价送回卡组，并将这张卡返回持有者卡组并洗牌。
function c41470137.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 将这张卡送去持有者卡组并洗牌，作为发动效果②的代价。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 定义效果②特殊召唤的筛选条件：选择卡名不是「剑斗兽 枪斗」、属于「剑斗兽」系列且可以被当前效果特殊召唤的怪兽。
function c41470137.filter(c,e,tp)
	return not c:IsCode(41470137) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②发动时确认条件：检查自己场上是否有可用怪兽区以及卡组是否存在满足条件的「剑斗兽」怪兽，并登记特殊召唤操作信息。
function c41470137.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区空格（这里用>-1宽松判断，具体空位在效果处理时再确认）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「剑斗兽」怪兽。
		and Duel.IsExistingMatchingCard(c41470137.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本次连锁将进行特殊召唤，并从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②处理时，若仍有怪兽区空位，则从卡组选择符合条件的「剑斗兽」怪兽以表侧表示特殊召唤，并给该怪兽登记出场标记（防止同名效果再次使用）。
function c41470137.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用怪兽区，否则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出“请选择要特殊召唤的卡”的提示消息，用于后续选择卡片的界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张符合条件的「剑斗兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c41470137.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end

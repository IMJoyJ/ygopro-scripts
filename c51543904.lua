--No.99 希望皇龍ホープドラグーン
-- 效果：
-- 10星怪兽×3
-- 这张卡也能把手卡1张「升阶魔法」魔法卡丢弃，在自己场上的「希望皇 霍普」怪兽上面重叠来超量召唤。
-- ①：1回合1次，以自己墓地1只「No.」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：这张卡为对象的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
function c51543904.initial_effect(c)
	aux.AddXyzProcedure(c,nil,10,3,c51543904.ovfilter,aux.Stringid(51543904,0),3,c51543904.xyzop)  --"是否在「希望皇 霍普」怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- ①：1回合1次，以自己墓地1只「No.」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51543904,1))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c51543904.sptg)
	e1:SetOperation(c51543904.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡为对象的怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51543904,2))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c51543904.discon)
	e2:SetCost(c51543904.discost)
	e2:SetTarget(c51543904.distg)
	e2:SetOperation(c51543904.disop)
	c:RegisterEffect(e2)
end
-- 将该卡的XYZ编号设为99，用于“No.”相关卡片的特殊判定。
aux.xyz_number[51543904]=99
-- cfilter：判断手卡中的卡是否为「升阶魔法」魔法卡且能够被丢弃，作为额外超量召唤的代价条件。
function c51543904.cfilter(c)
	return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- ovfilter：判断场上的表侧表示怪兽是否为「希望皇」字段怪兽，以决定能否在其上重叠进行超量召唤。
function c51543904.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- xyzop：该卡的追加超量召唤手续：检查手卡是否存在可丢弃的「升阶魔法」，并丢弃1张作为召唤代价。
function c51543904.xyzop(e,tp,chk)
	-- 检查手卡中是否存在满足cfilter条件的“升阶魔法”卡，以决定能否以追加手续进行超量召唤。
	if chk==0 then return Duel.IsExistingMatchingCard(c51543904.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃手卡中1张满足条件的“升阶魔法”魔法卡，作为该超量召唤手续的代价。
	Duel.DiscardHand(tp,c51543904.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- filter：判断墓地怪兽是否为“No.”怪兽且能够以表侧守备表示被效果特殊召唤，并符合苏生限制。
function c51543904.filter(c,e,tp)
	return c:IsSetCard(0x48) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- sptg：效果发动前的目标选择与合法性判定：指定墓地的“No.”怪兽为对象，并确认有可用的主要怪兽区及合法对象。
function c51543904.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51543904.filter(chkc,e,tp) end
	-- 检查我方主要怪兽区域是否有空位，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足特殊召唤条件的“No.”怪兽可成为效果对象。
		and Duel.IsExistingTarget(c51543904.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片，显示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足特殊召唤条件的“No.”怪兽作为效果对象，并将其登记为连锁对象。
	local g=Duel.SelectTarget(tp,c51543904.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次操作信息：将对1只怪兽进行特殊召唤，预定的特殊召唤对象为已选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- spop：效果处理时，将对象“No.”怪兽表侧守备表示特殊召唤，并使其效果无效化，最后完成特殊召唤流程。
function c51543904.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得本次效果选择的墓地对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联且满足特殊召唤条件后，将其以表侧守备表示加入特殊召唤流程。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成分步特殊召唤流程，将之前待定的怪兽正式特殊召唤上场。
	Duel.SpecialSummonComplete()
end
-- discon：②效果的发动条件：当怪兽效果以这张卡为对象发动时，且该连锁能被无效，并且本卡未被战斗破坏，才能发动。
function c51543904.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not re:IsActiveType(TYPE_MONSTER) then return end
	-- 取得该连锁中被选为对象的目标卡组，用于判断是否包含这张卡。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 仅当对象组中包含本卡且该连锁可以被无效时，②效果才满足发动条件。
	return tg and tg:IsContains(c) and Duel.IsChainNegatable(ev)
end
-- discost：将这张卡1个超量素材取除作为发动代价；先确认有超量素材可移除，然后实际取除1个。
function c51543904.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- distg：②效果发动的目标设定：允许发动，并把要无效的对方效果来源卡设为操作对象；若来源卡可破坏且仍关联，则同时追加破坏操作信息。
function c51543904.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次处理将无效对方发动的那个效果（eg）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 追加设置操作信息：若对方效果来源怪兽仍可破坏且与效果关联，则本次处理还会将其破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- disop：实际处理：先将对方那个效果的发动无效化，成功后破坏该效果来源怪兽。
function c51543904.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对应连锁的发动无效，并确认被无效效果来源的怪兽仍与效果关联后才继续处理破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果破坏那个发动被无效的怪兽。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

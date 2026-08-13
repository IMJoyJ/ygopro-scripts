--礫岩の霊長－コングレード
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
-- ①：从对方的手卡·卡组有怪兽被送去墓地的场合才能发动。这张卡从手卡里侧守备表示特殊召唤。
-- ②：这张卡反转的场合，以场上最多2张卡为对象才能发动。那些卡破坏。
function c49729312.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c49729312.splimit)
	c:RegisterEffect(e1)
	-- ①：从对方的手卡·卡组有怪兽被送去墓地的场合才能发动。这张卡从手卡里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49729312,0))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c49729312.spcon)
	e2:SetTarget(c49729312.sptg)
	e2:SetOperation(c49729312.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡反转的场合，以场上最多2张卡为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49729312,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_FLIP)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(c49729312.destg)
	e3:SetOperation(c49729312.desop)
	c:RegisterEffect(e3)
end
-- 作为特殊召唤条件的Value判定函数：仅当进行特殊召唤的效果为“效果”（EFFECT_TYPE_ACTIONS）时允许特殊召唤，即此卡只能用卡的效果特殊召唤。
function c49729312.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 筛选条件：用于判断送入墓地的卡是否从对方的手卡或卡组送去且为怪兽，并确认其原控制者为对方。
function c49729312.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK+LOCATION_HAND) and c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp)
end
-- ①效果的发动条件：当本次送入墓地的怪兽中存在至少1只满足“从对方手卡·卡组送去墓地”的怪兽时，允许发动。
function c49729312.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c49729312.cfilter,1,nil,1-tp)
end
-- ①效果的发动目标检查：己方主要怪兽区有空位，且此卡能够以里侧守备表示特殊召唤。
function c49729312.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置操作信息：向系统声明此效果将特殊召唤这张卡（数量1），用于满足相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若此卡仍与该效果关联（未被无效或离场重置），将其以里侧守备表示特殊召唤，并让对手确认此卡。
function c49729312.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 实际执行：将这张卡从手牌以里侧守备表示特殊召唤到己方场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方玩家展示这张卡，以确认特殊召唤的怪兽。
		Duel.ConfirmCards(1-tp,c)
	end
end
-- ②效果的发动条件与目标选择：取对象时检查目标需在场；发动时选择场上1~2张卡为对象，并设置破坏的操作信息。
function c49729312.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动时确认场上存在至少1张可取对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示发动玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择双方场上的1~2张卡作为此效果的对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 设置操作信息：声明将破坏选中的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果处理：取得效果对象，筛掉已与效果失去关联的卡，然后将其破坏。
function c49729312.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取出效果对象，并过滤出仍然与效果相关的卡（对象离场等会失去关联）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 以效果原因破坏这些卡。
		Duel.Destroy(g,REASON_EFFECT)
	end
end

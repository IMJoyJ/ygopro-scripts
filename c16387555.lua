--キラーチューン・キュー
-- 效果：
-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤的场合才能发动。从自己的手卡·卡组·墓地把「杀手级调整曲·提示员」以外的1只调整特殊召唤。这个回合，自己不是调整不能特殊召唤。
-- ②：这张卡作为同调素材送去墓地的场合才能发动。从对方卡组上面把2张卡翻开，从那之中把1张除外，另1张回到卡组最上面或最下面。
local s,id,o=GetID()
-- 注册三个效果：①作为手卡同调素材的规则效果，②召唤时从手牌·卡组·墓地特殊召唤调整并附加自肃，③作为同调素材时翻开对方卡组并除外1张。
function s.initial_effect(c)
	-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCondition(s.syncon)
	e1:SetCode(EFFECT_HAND_SYNCHRO)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.tfilter)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤的场合才能发动。从自己的手卡·卡组·墓地把「杀手级调整曲·提示员」以外的1只调整特殊召唤。这个回合，自己不是调整不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡作为同调素材送去墓地的场合才能发动。从对方卡组上面把2张卡翻开，从那之中把1张除外，另1张回到卡组最上面或最下面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"除外效果"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	s.killer_tune_be_material_effect=e3
end
-- 该效果的条件函数：这张卡在主要怪兽区（场上）时，手卡调整才能作为同调素材。
function s.syncon(e)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
-- 手卡同调素材的筛选条件：只允许调整怪兽（具备调整类型的怪兽）作为同调素材。
function s.tfilter(e,c)
	return c:IsSynchroType(TYPE_TUNER)
end
-- 特殊召唤候选的筛选条件：不是「杀手级调整曲·提示员」本身、是调整怪兽、且能被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件：己方场上有可用的主要怪兽区空格，且手牌·卡组·墓地存在符合条件的调整怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌·卡组·墓地是否存在至少1只满足s.spfilter条件的调整怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将从手牌·卡组·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：从手牌·卡组·墓地选择1只调整特殊召唤；随后给自己附加“这个回合不能特殊召唤调整以外的怪兽”的自肃。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认己方场上是否有可用的主要怪兽区空格。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 弹出卡片选择提示，提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌·卡组·墓地选择1只满足条件且不受王家长眠之谷影响的调整怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的调整怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是调整不能特殊召唤。②：这张卡作为同调素材送去墓地的场合才能发动。从对方卡组上面把2张卡翻开，从那之中把1张除外，另1张回到卡组最上面或最下面。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能特殊召唤调整以外怪兽”的自肃效果注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判断条件：要特殊召唤的怪兽的原本种类不是调整时，禁止该特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetOriginalType()&TYPE_TUNER==0
end
-- ②效果的发动条件：这张卡作为同调素材被送去墓地，且送去墓地的原因是同调召唤。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- ②效果的发动时处理：获取对方卡组最上方2张卡，若存在可除外的卡则允许发动，并设置除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方卡组最上方的2张卡。
	local g=Duel.GetDecktopGroup(1-tp,2)
	if chk==0 then return #g>1 and g:IsExists(Card.IsAbleToRemove,1,nil) end
	-- 设置操作信息：本次效果将除外对方卡组的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
-- ②效果处理：翻开对方卡组最上方2张，由玩家选择1张除外，另1张由玩家选择回到卡组最上面或最下面。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果当前玩家不能执行除外，则直接结束效果处理。
	if not Duel.IsPlayerCanRemove(tp) then return end
	-- 获取对方卡组当前的卡牌数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	if ct>2 then ct=2 end
	if ct==0 then return end
	-- 向双方确认（翻开）对方卡组最上方的2张卡。
	Duel.ConfirmDecktop(1-tp,2)
	-- 获取对方卡组最上方2张卡作为可选集合。
	local g=Duel.GetDecktopGroup(1-tp,2)
	-- 弹出选择提示，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 开启从卡组选择卡片并展示给双方的界面。
	Duel.RevealSelectDeckSequence(true)
	local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
	-- 关闭从卡组选择卡片的展示界面。
	Duel.RevealSelectDeckSequence(false)
	if #sg>0 then
		-- 禁用下一次操作后的自动洗卡组检查，因为从卡组顶部除外/移动卡片不会导致卡组随机化。
		Duel.DisableShuffleCheck(true)
		-- 将玩家选择的卡片以表侧表示除外。
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		g:Sub(sg)
		-- 若剩下1张卡，则让玩家选择将其回到卡组最上面还是最下面；当选择“回到最下面”时执行移动语句。
		if #g>0 and Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==1 then  --"返回卡组最上面/返回卡组最下面"
			-- 将剩下的那张卡移动到卡组最下面。
			Duel.MoveSequence(g:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end

--キラーチューン・キュー
-- 效果：
-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤的场合才能发动。从自己的手卡·卡组·墓地把「杀手级调整曲·提示员」以外的1只调整特殊召唤。这个回合，自己不是调整不能特殊召唤。
-- ②：这张卡作为同调素材送去墓地的场合才能发动。从对方卡组上面把2张卡翻开，从那之中把1张除外，另1张回到卡组最上面或最下面。
local s,id,o=GetID()
-- 初始化卡片效果，创建3个效果：手牌同步、召唤后特殊召唤、作为素材时除外效果
function s.initial_effect(c)
	-- 场上的这张卡为素材作同调召唤的场合，手卡1只调整也能作为同调素材
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCondition(s.syncon)
	e1:SetCode(EFFECT_HAND_SYNCHRO)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.tfilter)
	c:RegisterEffect(e1)
	-- 这张卡召唤的场合才能发动。从自己的手卡·卡组·墓地把「杀手级调整曲·提示员」以外的1只调整特殊召唤。这个回合，自己不是调整不能特殊召唤
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
	-- 这张卡作为同调素材送去墓地的场合才能发动。从对方卡组上面把2张卡翻开，从那之中把1张除外，另1张回到卡组最上面或最下面
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
-- 判断此卡是否在场上
function s.syncon(e)
	return e:GetHandler():IsLocation(LOCATION_MZONE)
end
-- 过滤同步素材为调整类型
function s.tfilter(e,c)
	return c:IsSynchroType(TYPE_TUNER)
end
-- 过滤满足条件的调整卡：不是此卡本身、类型为调整、可以特殊召唤
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的条件：场上存在空位且存在满足条件的调整卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否存在满足条件的调整卡
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行特殊召唤操作：选择并特殊召唤调整卡，并设置本回合不能特殊召唤非调整卡的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的调整卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的调整卡特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 设置本回合不能特殊召唤非调整卡的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能特殊召唤的限制条件：非调整类型不能特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetOriginalType()&TYPE_TUNER==0
end
-- 判断此卡是否作为同步素材进入墓地
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 判断是否满足除外效果的条件：翻开对方卡组最上方2张卡，其中至少有1张可以除外
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方卡组最上方2张卡
	local g=Duel.GetDecktopGroup(1-tp,2)
	if chk==0 then return #g>1 and g:IsExists(Card.IsAbleToRemove,1,nil) end
	-- 设置除外操作的信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
-- 执行除外效果：翻开对方卡组最上方2张卡，选择1张除外，另1张放回卡组顶部或底部
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家是否可以除外卡
	if not Duel.IsPlayerCanRemove(tp) then return end
	-- 获取玩家卡组中卡的数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	if ct>2 then ct=2 end
	if ct==0 then return end
	-- 确认对方卡组最上方2张卡
	Duel.ConfirmDecktop(1-tp,2)
	-- 获取对方卡组最上方2张卡
	local g=Duel.GetDecktopGroup(1-tp,2)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 显示对方卡组最上方2张卡
	Duel.RevealSelectDeckSequence(true)
	local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
	-- 隐藏对方卡组最上方2张卡
	Duel.RevealSelectDeckSequence(false)
	if #sg>0 then
		-- 禁止洗切卡组检查
		Duel.DisableShuffleCheck(true)
		-- 将选中的卡除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		g:Sub(sg)
		-- 判断是否选择将剩余卡放回卡组顶部或底部
		if #g>0 and Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==1 then  --"返回卡组最上面/返回卡组最下面"
			-- 将卡放回卡组底部
			Duel.MoveSequence(g:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end

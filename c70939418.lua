--SR－OMKガム
-- 效果：
-- ①：自己·对方的战斗阶段自己因战斗·效果受到伤害的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的效果让这张卡特殊召唤成功的战斗阶段才能发动。只用包含这张卡的自己场上的风属性怪兽为同调素材作同调召唤。
-- ③：这张卡作为同调素材送去墓地的场合才能发动。自己卡组最上面的卡送去墓地，那张卡是「疾行机人」怪兽的场合，这张卡为同调素材的同调怪兽的攻击力上升1000。
function c70939418.initial_effect(c)
	-- ①：自己·对方的战斗阶段自己因战斗·效果受到伤害的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70939418,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c70939418.spcon)
	e1:SetTarget(c70939418.sptg)
	e1:SetOperation(c70939418.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果让这张卡特殊召唤成功的战斗阶段才能发动。只用包含这张卡的自己场上的风属性怪兽为同调素材作同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70939418,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_BATTLE_STEP_END+TIMING_BATTLE_END)
	e2:SetCondition(c70939418.sccon)
	e2:SetTarget(c70939418.sctg)
	e2:SetOperation(c70939418.scop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为同调素材送去墓地的场合才能发动。自己卡组最上面的卡送去墓地，那张卡是「疾行机人」怪兽的场合，这张卡为同调素材的同调怪兽的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70939418,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c70939418.ddcon)
	e3:SetTarget(c70939418.ddtg)
	e3:SetOperation(c70939418.ddop)
	c:RegisterEffect(e3)
	-- 为素材卡注册与效果③的关联关系
	aux.CreateMaterialReasonCardRelation(c,e3)
end
-- 效果①发动条件：战斗阶段自己因战斗或效果受到伤害
function c70939418.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于战斗阶段
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
		and ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 效果①发动条件及操作信息设置：自身特殊召唤
function c70939418.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有可用的怪兽区空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理：特殊召唤自身并注册标记
function c70939418.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身表侧表示特殊召唤并判断是否成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		c:RegisterFlagEffect(70939418,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 效果②发动条件：检查自身是否带有通过自身效果特殊召唤成功的标记
function c70939418.sccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(70939418)~=0
end
-- 过滤条件：表侧表示的风属性怪兽
function c70939418.mfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 效果②发动条件及操作信息设置：同调召唤
function c70939418.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取自己场上表侧表示的风属性怪兽
		local mg=Duel.GetMatchingGroup(c70939418.mfilter,tp,LOCATION_MZONE,0,nil)
		return not c:IsStatus(STATUS_CHAINING)
			-- 检查额外卡组是否存在可以以自身及场上风属性怪兽为素材同调召唤的怪兽
			and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c,mg)
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②处理：以场上的风属性怪兽为素材进行同调召唤
function c70939418.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取自己场上表侧表示的风属性怪兽作为同调素材候选
	local mg=Duel.GetMatchingGroup(c70939418.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取额外卡组中可进行同调召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 以自身及场上的风属性怪兽为素材进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),c,mg)
	end
end
-- 效果③发动条件：自身作为同调素材送去墓地
function c70939418.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 效果③目标选择及操作信息设置：卡组顶端送去墓地
function c70939418.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	-- 判断自己是否能将卡组最上面的卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		and rc:IsRelateToEffect(e) and rc:IsFaceup() end
	-- 将该同调怪兽设置为效果对象
	Duel.SetTargetCard(rc)
	-- 设置操作信息：将自己卡组最上面的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
-- 效果③处理：卡组顶端卡送去墓地，若为「疾行机人」怪兽则同调怪兽攻击力上升1000
function c70939418.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己卡组最上面的1张卡送去墓地，若未成功送墓则中断处理
	if Duel.DiscardDeck(tp,1,REASON_EFFECT)==0 then return end
	-- 获取刚被送去墓地的卡
	local tc=Duel.GetOperatedGroup():GetFirst()
	if tc and tc:IsSetCard(0x2016) and tc:IsType(TYPE_MONSTER) and tc:IsLocation(LOCATION_GRAVE) then
		-- 获取作为同调怪兽的对象卡
		local sync=Duel.GetFirstTarget()
		if not sync:IsRelateToChain() or sync:IsFacedown() then return end
		local c=e:GetHandler()
		-- 这张卡为同调素材的同调怪兽的攻击力上升1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sync:RegisterEffect(e1)
	end
end

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
	-- 建立作为素材的卡片与其对应的素材触发效果之间的关联，确保后续能正确获取同调召唤出的怪兽
	aux.CreateMaterialReasonCardRelation(c,e3)
end
-- 效果①的发动条件：当前处于战斗阶段，且自己因战斗或效果受到伤害
function c70939418.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为战斗阶段（从战斗阶段开始到战斗阶段结束）
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
		and ep==tp and bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 效果①的发动准备：检查怪兽区域是否有空位，以及这张卡是否可以特殊召唤，并设置特殊召唤的操作信息
function c70939418.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示将特殊召唤1张手牌中的本卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将这张卡特殊召唤，并给其注册一个在当前战斗阶段内有效的标记（Flag）
function c70939418.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡以表侧表示特殊召唤到自己场上，并判断是否特殊召唤成功
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		c:RegisterFlagEffect(70939418,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_BATTLE,0,1)
	end
end
-- 效果②的发动条件：这张卡具有因自身效果特殊召唤成功时注册的标记（即在特殊召唤成功的战斗阶段内）
function c70939418.sccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(70939418)~=0
end
-- 效果②的发动准备：检查是否可以以包含这张卡的自己场上的风属性怪兽为素材进行同调召唤，并设置特殊召唤的操作信息
function c70939418.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取自己场上所有的风属性怪兽作为同调素材的候选组
		local mg=Duel.GetMatchingGroup(Card.IsAttribute,tp,LOCATION_MZONE,0,nil,ATTRIBUTE_WIND)
		return not c:IsStatus(STATUS_CHAINING)
			-- 检查额外卡组中是否存在可以使用本卡以及上述风属性怪兽作为素材进行同调召唤的怪兽
			and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c,mg)
	end
	-- 设置特殊召唤的操作信息，表示将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的效果处理：在自己场上的风属性怪兽中选择素材，对额外卡组的同调怪兽进行同调召唤
function c70939418.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 重新获取自己场上所有的风属性怪兽作为同调素材
	local mg=Duel.GetMatchingGroup(Card.IsAttribute,tp,LOCATION_MZONE,0,nil,ATTRIBUTE_WIND)
	-- 过滤出当前可以使用本卡和上述风属性怪兽作为素材进行同调召唤的同调怪兽组
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c,mg)
	if g:GetCount()>0 then
		-- 向玩家发送提示信息，要求选择要特殊召唤（同调召唤）的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 让玩家使用本卡和指定的风属性怪兽作为素材，对选定的怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),c,mg)
	end
end
-- 效果③的发动条件：这张卡作为同调素材送去墓地的场合
function c70939418.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 效果③的发动准备：获取以此卡为素材召唤出的同调怪兽，检查自己是否能将卡组最上面的卡送去墓地，并将该同调怪兽设为效果处理的对象
function c70939418.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	-- 检查自己是否可以将卡组最上方的1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		and rc:IsRelateToEffect(e) and rc:IsFaceup() end
	-- 将本次同调召唤出的同调怪兽设为当前连锁的效果处理对象
	Duel.SetTargetCard(rc)
	-- 设置送去墓地的操作信息，表示将自己卡组最上方的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
-- 效果③的效果处理：将卡组最上面的卡送去墓地，若该卡是「疾行机人」怪兽，则使作为对象的同调怪兽攻击力上升1000
function c70939418.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己卡组最上方的1张卡因效果送去墓地，若送墓失败则结束处理
	if Duel.DiscardDeck(tp,1,REASON_EFFECT)==0 then return end
	-- 获取刚刚被送去墓地的那张卡
	local tc=Duel.GetOperatedGroup():GetFirst()
	if tc and tc:IsSetCard(0x2016) and tc:IsType(TYPE_MONSTER) and tc:IsLocation(LOCATION_GRAVE) then
		-- 获取之前设为对象的同调怪兽
		local sync=Duel.GetFirstTarget()
		if not sync:IsRelateToChain() or sync:IsFacedown() then return end
		local c=e:GetHandler()
		-- 那张卡是「疾行机人」怪兽的场合，这张卡为同调素材的同调怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sync:RegisterEffect(e1)
	end
end

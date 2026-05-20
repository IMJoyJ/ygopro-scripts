--水精鱗－アビストリーテ
-- 效果：
-- 3星怪兽×3
-- 自己场上的名字带有「水精鳞」的怪兽1只成为对方的魔法·陷阱卡的效果的对象时或者成为对方怪兽的攻击对象时，把这张卡1个超量素材取除才能发动。那个对象转移为自己场上的作为正确对象的这张卡。这张卡被破坏送去墓地时，可以从自己墓地选择「水精鳞-深渊特里忒」以外的1只名字带有「水精鳞」的怪兽特殊召唤。
function c59170782.initial_effect(c)
	-- 添加XYZ召唤手续：3星怪兽×3
	aux.AddXyzProcedure(c,nil,3,3)
	c:EnableReviveLimit()
	-- 自己场上的名字带有「水精鳞」的怪兽1只成为对方的魔法·陷阱卡的效果的对象时，把这张卡1个超量素材取除才能发动。那个对象转移为自己场上的作为正确对象的这张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59170782,0))  --"对象转移"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c59170782.tgcon1)
	e1:SetCost(c59170782.tgcost)
	e1:SetOperation(c59170782.tgop1)
	c:RegisterEffect(e1)
	-- 或者成为对方怪兽的攻击对象时，把这张卡1个超量素材取除才能发动。那个对象转移为自己场上的作为正确对象的这张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59170782,0))  --"对象转移"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c59170782.tgcon2)
	e2:SetCost(c59170782.tgcost)
	e2:SetOperation(c59170782.tgop2)
	c:RegisterEffect(e2)
	-- 这张卡被破坏送去墓地时，可以从自己墓地选择「水精鳞-深渊特里忒」以外的1只名字带有「水精鳞」的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(59170782,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c59170782.spcon)
	e3:SetTarget(c59170782.sptg)
	e3:SetOperation(c59170782.spop)
	c:RegisterEffect(e3)
end
-- 转移对象效果的Cost：把这张卡1个超量素材取除
function c59170782.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 转移魔法·陷阱卡效果对象效果的发动条件：对方发动以自己场上1只表侧表示的「水精鳞」怪兽为唯一对象的魔法·陷阱卡的效果，且这张卡是该效果的正确对象
function c59170782.tgcon1(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if tc==c or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsLocation(LOCATION_MZONE) or not tc:IsSetCard(0x74) then return false end
	-- 检查这张卡是否是该连锁效果的正确对象
	return Duel.CheckChainTarget(ev,c)
end
-- 转移魔法·陷阱卡效果对象效果的处理：若这张卡仍是正确对象，则将该效果的对象转移为这张卡
function c59170782.tgop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 检查这张卡在效果处理时是否仍能作为该效果的正确对象
		if Duel.CheckChainTarget(ev,c) then
			local g=Group.CreateGroup()
			g:AddCard(c)
			-- 将该连锁的效果对象变更为这张卡
			Duel.ChangeTargetCard(ev,g)
		end
	end
end
-- 转移攻击对象效果的发动条件：对方回合，自己场上表侧表示的「水精鳞」怪兽被选为攻击对象，且这张卡可以被选择为攻击对象
function c59170782.tgcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 必须在对方回合发动，且这张卡自身没有在同一连锁中发动效果
	if tp==Duel.GetTurnPlayer() or e:GetHandler():IsStatus(STATUS_CHAINING) then return false end
	-- 获取当前的攻击对象
	local at=Duel.GetAttackTarget()
	if at and at:IsFaceup() and at:IsSetCard(0x74) then
		local ag=eg:GetFirst():GetAttackableTarget()
		return ag:IsContains(e:GetHandler())
	end
	return false
end
-- 转移攻击对象效果的处理：若这张卡在场且攻击怪兽未免疫此效果，则将攻击对象转移为这张卡
function c59170782.tgop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍在场，且攻击怪兽是否不受此效果影响
	if c:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		-- 将攻击对象转移为这张卡
		Duel.ChangeAttackTarget(c)
	end
end
-- 特殊召唤效果的发动条件：这张卡被破坏
function c59170782.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 墓地「水精鳞」怪兽的过滤条件：除「水精鳞-深渊特里忒」以外的名字带有「水精鳞」的怪兽，且可以特殊召唤
function c59170782.spfilter(c,e,tp)
	return c:IsSetCard(0x74) and not c:IsCode(59170782) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的Target：检查怪兽区域空位，并选择墓地1只满足条件的「水精鳞」怪兽作为对象
function c59170782.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c59170782.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的、除「水精鳞-深渊特里忒」以外的「水精鳞」怪兽
		and Duel.IsExistingTarget(c59170782.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「水精鳞」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c59170782.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表明此效果包含特殊召唤该对象的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的处理：将选择的墓地怪兽特殊召唤
function c59170782.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

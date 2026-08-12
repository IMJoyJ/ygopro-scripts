--Uk－P.U.N.K.カープ・ライジング
-- 效果：
-- 「朋克」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把融合召唤的这张卡解放才能发动。从手卡·卡组把最多2只8星以外的「朋克」怪兽守备表示特殊召唤（同名卡最多1张）。
-- ②：这张卡为同调素材作同调召唤的场合，以自己场上1只「朋克」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
function c18313046.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用2个满足「朋克」属性的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x171),2,true)
	-- ①：把融合召唤的这张卡解放才能发动。从手卡·卡组把最多2只8星以外的「朋克」怪兽守备表示特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18313046,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,18313046)
	e1:SetCondition(c18313046.spcon)
	e1:SetCost(c18313046.spcost)
	e1:SetTarget(c18313046.sptg)
	e1:SetOperation(c18313046.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡为同调素材作同调召唤的场合，以自己场上1只「朋克」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18313046,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,18313047)
	e2:SetCondition(c18313046.atkcon)
	e2:SetTarget(c18313046.atktg)
	e2:SetOperation(c18313046.atkop)
	c:RegisterEffect(e2)
end
-- 效果适用条件：此卡必须为融合召唤 summoned
function c18313046.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 特殊召唤的过滤条件：不是8星且为「朋克」属性且可以特殊召唤到守备表示
function c18313046.spfilter(c,e,tp)
	return not c:IsLevel(8) and c:IsSetCard(0x171) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动费用：解放此卡且场上存在空怪兽区
function c18313046.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动费用检查：此卡可被解放且场上存在空怪兽区
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 执行发动费用：解放此卡
	Duel.Release(c,REASON_COST)
end
-- 效果目标设定：确认场上存在满足条件的「朋克」怪兽
function c18313046.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果目标检查：确认场上存在满足条件的「朋克」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c18313046.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：检索满足条件的怪兽并特殊召唤
function c18313046.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上可用怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local ct=math.min(ft,2)
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c18313046.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽组（卡名各不相同）
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
	if sg then
		-- 将选中的怪兽组特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果适用条件：此卡作为同调素材被使用且当前处于战斗阶段或可进入战斗阶段
function c18313046.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 效果适用条件判断：作为同调素材且当前阶段为战斗阶段或可进入战斗阶段
	return r==REASON_SYNCHRO and (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE or Duel.IsAbleToEnterBP())
end
-- 攻击次数增加效果的过滤条件：场上自己控制的「朋克」怪兽且未拥有额外攻击效果
function c18313046.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x171) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 效果目标设定：选择场上自己控制的「朋克」怪兽
function c18313046.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c18313046.atkfilter(chkc) end
	-- 效果目标检查：确认场上存在满足条件的「朋克」怪兽
	if chk==0 then return Duel.IsExistingTarget(c18313046.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上自己控制的「朋克」怪兽作为效果对象
	Duel.SelectTarget(tp,c18313046.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：为对象怪兽添加额外一次攻击效果
function c18313046.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为对象怪兽添加额外一次攻击效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end

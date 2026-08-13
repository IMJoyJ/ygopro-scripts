--Uk－P.U.N.K.カープ・ライジング
-- 效果：
-- 「朋克」怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把融合召唤的这张卡解放才能发动。从手卡·卡组把最多2只8星以外的「朋克」怪兽守备表示特殊召唤（同名卡最多1张）。
-- ②：这张卡为同调素材作同调召唤的场合，以自己场上1只「朋克」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
function c18313046.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，要求素材为2只“朋克”字段怪兽（符合Card.IsFusionSetCard，字段0x171），即实现“「朋克」怪兽×2”的融合素材。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x171),2,true)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把融合召唤的这张卡解放才能发动。从手卡·卡组把最多2只8星以外的「朋克」怪兽守备表示特殊召唤（同名卡最多1张）。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡为同调素材作同调召唤的场合，以自己场上1只「朋克」怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
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
-- 效果①的发动条件判定：只有通过融合召唤出场的这张卡才满足发动条件（对应“把融合召唤的这张卡解放才能发动”的前提）。
function c18313046.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 特殊召唤的候选卡过滤条件：不是8星、属于“朋克”字段、且可以被表侧守备表示特殊召唤。对应“8星以外的「朋克」怪兽”。
function c18313046.spfilter(c,e,tp)
	return not c:IsLevel(8) and c:IsSetCard(0x171) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动代价处理：将这张卡解放作为代价。先检查是否满足解放条件及解放后怪兽区空位，满足则实际执行解放。
function c18313046.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价检查：这张卡可以被解放，且解放后自己场上仍有可用的怪兽区空格。
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 以代价（REASON_COST）解放这张卡，完成“把融合召唤的这张卡解放才能发动”的代价。
	Duel.Release(c,REASON_COST)
end
-- 效果①的发动目标设定：检查手卡·卡组是否存在满足条件的“朋克”怪兽，并设置特殊召唤的操作信息。
function c18313046.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认：手卡·卡组中至少存在1只满足spfilter条件的“朋克”怪兽，才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c18313046.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次处理将进行特殊召唤，预计数量为1，来源为手卡·卡组，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①处理：计算可特殊召唤的数量，受可用怪兽区和【青眼精灵龙】效果限制，从手卡·卡组选择最多2只卡名不同的“朋克”怪兽表侧守备表示特殊召唤。
function c18313046.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区空格数，用于决定最多能特殊召唤几只。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local ct=math.min(ft,2)
	-- 获取手卡·卡组中所有满足spfilter条件的“朋克”怪兽，作为后续选择的候选组。
	local g=Duel.GetMatchingGroup(c18313046.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	-- 向玩家弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从候选组中选择1到ct张卡，且通过aux.dncheck保证所选卡名互不相同（对应同名卡最多1张）。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
	if sg then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己的场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的发动条件判定：这张卡作为同调素材送去墓地时，且当前处于战斗阶段开始到战斗阶段结束之间（或可以进行战斗阶段），才可发动。
function c18313046.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于后续条件判断。
	local ph=Duel.GetCurrentPhase()
	-- 返回是否满足：这张卡被用作同调召唤的素材（r==REASON_SYNCHRO），且当前处于战斗阶段相关时点，或可以进行战斗阶段。
	return r==REASON_SYNCHRO and (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE or Duel.IsAbleToEnterBP())
end
-- 效果②的选择对象过滤：自己场上的表侧表示“朋克”怪兽，且尚未受到额外攻击次数效果影响。
function c18313046.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x171) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 效果②的取对象处理：确认存在合法对象后，提示玩家选择自己场上1只符合条件的“朋克”怪兽。
function c18313046.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c18313046.atkfilter(chkc) end
	-- 发动时确认：自己场上存在至少1只满足atkfilter条件的“朋克”怪兽，才能选择对象。
	if chk==0 then return Duel.IsExistingTarget(c18313046.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出“请选择效果的对象”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只自己场上的“朋克”怪兽作为效果对象，并建立与当前连锁的关联。
	Duel.SelectTarget(tp,c18313046.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②处理：给对象怪兽附加1次额外攻击次数的效果，使其这个回合在同一次战斗阶段中可以攻击2次。
function c18313046.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果②选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end

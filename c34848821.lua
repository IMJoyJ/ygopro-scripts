--痕喰竜ブリガンド
-- 效果：
-- 「阿不思的落胤」＋8星以上的怪兽
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡不会被战斗破坏。
-- ②：只要融合召唤的这张卡在怪兽区域存在，对方不能把自己场上的其他怪兽作为怪兽的效果的对象。
-- ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「铁兽」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
function c34848821.initial_effect(c)
	c:EnableReviveLimit()
	-- 给这张卡注册融合召唤手续：素材为「阿不思的落胤」（68468459）1只＋8星以上的怪兽1只（通过FilterBoolFunction(Card.IsLevelAbove,8)筛选等级8以上）。
	aux.AddFusionProcCodeFun(c,68468459,aux.FilterBoolFunction(Card.IsLevelAbove,8),1,true,true)
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：只要融合召唤的这张卡在怪兽区域存在，对方不能把自己场上的其他怪兽作为怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c34848821.imcon)
	e2:SetTarget(c34848821.imval)
	e2:SetValue(c34848821.imfilter)
	c:RegisterEffect(e2)
	-- 这张卡被送去墓地的回合的结束阶段才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c34848821.regop)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「铁兽」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34848821,0))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,34848821)
	e4:SetCondition(c34848821.thcon)
	e4:SetTarget(c34848821.thtg)
	e4:SetOperation(c34848821.thop)
	c:RegisterEffect(e4)
end
-- 该函数用于检查一组融合素材sg是否满足本卡的融合素材条件，即同时包含「阿不思的落胤」和8星以上怪兽。
function c34848821.branded_fusion_check(tp,sg,fc)
	-- 调用aux.gffcheck检查sg中是否包含「阿不思的落胤」和8星以上怪兽各1只，顺序不限，作为融合召唤素材是否合法的判定。
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,Card.IsLevelAbove,8)
end
-- 效果②的适用条件：这张卡以融合召唤方式召唤（即场上存在的是融合召唤的这张卡）。
function c34848821.imcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果②的保护对象过滤：只有这张卡以外的我方场上怪兽（c≠e:GetHandler()）才会受到“不能成为效果对象”的保护。
function c34848821.imval(e,c)
	return c~=e:GetHandler()
end
-- 效果②的禁止对象判定：当有玩家要发动怪兽效果时，结合aux.tgoval判断是否为“不能成为对方效果对象”的场合，并限定试图取对象的效果必须为怪兽效果。
function c34848821.imfilter(e,re,rp)
	-- 判定结果：该尝试选择对象的效果必须是怪兽效果，且要满足不能成为对方效果对象的一般条件（aux.tgoval），此时本卡才能阻止其以我方其他怪兽为对象。
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_MONSTER)
end
-- 这张卡被送去墓地时，给自己打上34848821标记（该标记在结束阶段时重置），用于记录本回合曾被送去墓地。
function c34848821.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(34848821,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ③效果的发动条件：本回合这张卡被送去墓地过（即带有34848821标记）。
function c34848821.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(34848821)>0
end
-- ③效果可选的卡：卡组中「铁兽」怪兽（0x14d字段）或「阿不思的落胤」（68468459），且该卡能够加入手卡，或能够在我方怪兽区空格上特殊召唤。
function c34848821.thfilter(c,e,tp)
	if not (c:IsSetCard(0x14d) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) then return false end
	-- 获取我方怪兽区剩余可用空格数量，用于判断是否满足特殊召唤条件。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 效果发动时（chk==0）检查卡组中是否存在至少1张满足thfilter的卡以决定能否发动。
function c34848821.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若卡组中有符合条件的卡则允许发动（返回true），否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c34848821.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- ③效果处理：从卡组选择1张符合条件的卡，并根据情况将其加入手卡或特殊召唤。
function c34848821.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给当前玩家显示选择提示，请其选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组选择1张满足thfilter条件的卡（由玩家选择）。
	local g=Duel.SelectMatchingCard(tp,c34848821.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 再次获取我方怪兽区空格数，用于后续判断是加入手卡还是特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 若选中的卡能加入手卡，且（不能特殊召唤或没有空格或玩家选择加入手卡）时，执行加入手卡分支；否则执行特殊召唤分支。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 把选中的卡加入其持有者的手卡（处理加入手卡的分支）。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示这张加入手卡的卡，确认检索处理。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 把选中的卡以表侧表示特殊召唤到我方怪兽区。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

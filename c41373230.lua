--灰燼竜バスタード
-- 效果：
-- 「阿不思的落胤」＋攻击力2500以上的怪兽
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升作为这张卡的融合素材的怪兽的原本等级合计×100。
-- ②：这张卡融合召唤时适用。这个回合，这张卡不受从额外卡组特殊召唤的其他怪兽发动的效果影响。
-- ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「教导」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
function c41373230.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要「阿不思的落胤」和一只攻击力2500以上的怪兽作为融合素材。
	aux.AddFusionProcCodeFun(c,68468459,aux.FilterBoolFunction(Card.IsAttackAbove,2500),1,true,true)
	-- ①：这张卡的攻击力上升作为这张卡的融合素材的怪兽的原本等级合计×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c41373230.matcheck)
	c:RegisterEffect(e1)
	-- ②：这张卡融合召唤时适用。这个回合，这张卡不受从额外卡组特殊召唤的其他怪兽发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c41373230.imcon)
	e2:SetOperation(c41373230.imop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的回合的结束阶段才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c41373230.regop)
	c:RegisterEffect(e3)
	-- 从卡组选1只「教导」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41373230,0))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,41373230)
	e4:SetCondition(c41373230.thcon)
	e4:SetTarget(c41373230.thtg)
	e4:SetOperation(c41373230.thop)
	c:RegisterEffect(e4)
end
-- 定义融合素材检查函数，验证素材组是否包含「阿不思的落胤」和攻击力2500以上的怪兽。
function c41373230.branded_fusion_check(tp,sg,fc)
	-- 调用辅助函数检查素材组中是否有「阿不思的落胤」和攻击力2500以上的怪兽。
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,Card.IsAttackAbove,2500)
end
-- 定义过滤函数，筛选出是怪兽且原始等级大于0的卡片。
function c41373230.matfilter(c)
	return c:IsFusionType(TYPE_MONSTER) and c:GetOriginalLevel()>0
end
-- 计算融合素材怪兽的原本等级合计，并创建效果提升这张卡的攻击力。
function c41373230.matcheck(e,c)
	local g=c:GetMaterial():Filter(c41373230.matfilter,nil)
	local atk=g:GetSum(Card.GetOriginalLevel)
	-- ①：这张卡的攻击力上升作为这张卡的融合素材的怪兽的原本等级合计×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk*100)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 检查处理中的怪兽是否是通过融合召唤特殊召唤的。
function c41373230.imcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 在融合召唤成功时，创建效果赋予这张卡免疫从额外卡组特殊召唤的其他怪兽发动的效果影响。
function c41373230.imop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，这张卡不受从额外卡组特殊召唤的其他怪兽发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(c41373230.efilter)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 定义效果过滤函数，判断效果是否来自从额外卡组特殊召唤的其他怪兽在场上发动的怪兽效果。
function c41373230.efilter(e,te)
	local tc=te:GetOwner()
	return tc~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
		and te:GetActivateLocation()==LOCATION_MZONE and tc:IsSummonLocation(LOCATION_EXTRA)
end
-- 在怪兽被送去墓地时注册标志效果，用于标记该回合结束阶段可以发动效果。
function c41373230.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(41373230,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查标志效果是否存在，以确认怪兽是否在本回合被送去墓地，从而允许在结束阶段发动效果。
function c41373230.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(41373230)>0
end
-- 定义过滤函数，从卡组筛选可加入手卡或特殊召唤的「教导」怪兽或「阿不思的落胤」。
function c41373230.thfilter(c,e,tp)
	if not (c:IsSetCard(0x145) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) then return false end
	-- 获取玩家场上怪兽区域的可用空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 检查卡组中是否存在至少一张符合条件的「教导」怪兽或「阿不思的落胤」，以确定效果可以发动。
function c41373230.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在目标函数中验证卡组中是否有符合条件的卡片可供选择。
	if chk==0 then return Duel.IsExistingMatchingCard(c41373230.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 处理效果操作，从卡组选择一张「教导」怪兽或「阿不思的落胤」，根据条件加入手卡或特殊召唤。
function c41373230.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示消息，要求选择卡组中的一张卡片进行操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组选择一张符合条件的「教导」怪兽或「阿不思的落胤」。
	local g=Duel.SelectMatchingCard(tp,c41373230.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 检查玩家场上可用于特殊召唤的空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 根据玩家选择和条件（卡片可加入手卡、能否特殊召唤、空位情况）决定是否将卡片加入手卡。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选择的卡片加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对手展示加入手卡的卡片以确认。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选择的卡片特殊召唤到场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

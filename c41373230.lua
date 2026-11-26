--灰燼竜バスタード
-- 效果：
-- 「阿不思的落胤」＋攻击力2500以上的怪兽
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升作为这张卡的融合素材的怪兽的原本等级合计×100。
-- ②：这张卡融合召唤时适用。这个回合，这张卡不受从额外卡组特殊召唤的其他怪兽发动的效果影响。
-- ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「教导」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
function c41373230.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤手续，需要「阿不思的落胤」与攻击力2500以上的怪兽各1只作为融合素材
	aux.AddFusionProcCodeFun(c,68468459,aux.FilterBoolFunction(Card.IsAttackAbove,2500),1,true,true)
	-- 「阿不思的落胤」＋攻击力2500以上的怪兽 ①：这张卡的攻击力上升作为这张卡的融合素材的怪兽的原本等级合计×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c41373230.matcheck)
	c:RegisterEffect(e1)
	-- ②：这张卡融合召唤时适用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c41373230.imcon)
	e2:SetOperation(c41373230.imop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的回合的
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c41373230.regop)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次。 ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「教导」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41373230,0))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,41373230)
	e4:SetCondition(c41373230.thcon)
	e4:SetTarget(c41373230.thtg)
	e4:SetOperation(c41373230.thop)
	c:RegisterEffect(e4)
end
-- 融合素材组合校验辅助函数，供特定融合效果检查素材是否满足「阿不思的落胤」与攻击力2500以上怪兽的条件
function c41373230.branded_fusion_check(tp,sg,fc)
	-- 使用双卡组合过滤检查素材组是否包含「阿不思的落胤」和攻击力2500以上的怪兽
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,Card.IsAttackAbove,2500)
end
-- 过滤函数，检查融合素材是否为怪兽且具有大于0的原本等级
function c41373230.matfilter(c)
	return c:IsFusionType(TYPE_MONSTER) and c:GetOriginalLevel()>0
end
-- 融合素材检查回调，统计素材怪兽原本等级之和并注册提升攻击力的效果
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
-- 条件检查，确认这张卡是通过融合召唤出场的
function c41373230.imcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 适用处理，为融合召唤成功的这张卡注册持续至回合结束的效果抗性
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
-- 抗性过滤函数，免疫自身以外从额外卡组特殊召唤的怪兽在场上发动的效果
function c41373230.efilter(e,te)
	local tc=te:GetOwner()
	return tc~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
		and te:GetActivateLocation()==LOCATION_MZONE and tc:IsSummonLocation(LOCATION_EXTRA)
end
-- 送墓标记处理，为被送去墓地的这张卡注册持续至回合结束的标识
function c41373230.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(41373230,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 发动条件检查，确认这张卡是在本回合被送去墓地的
function c41373230.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(41373230)>0
end
-- 过滤函数，检查是否为卡组中的「教导」怪兽或「阿不思的落胤」，且能加入手卡或在有空位时可特殊召唤
function c41373230.thfilter(c,e,tp)
	if not (c:IsSetCard(0x145) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) then return false end
	-- 获取自己怪兽区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 发动条件检查，确认自己卡组存在至少1只符合条件的怪兽
function c41373230.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只满足条件的「教导」怪兽或「阿不思的落胤」
	if chk==0 then return Duel.IsExistingMatchingCard(c41373230.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 效果处理，从卡组选1只「教导」怪兽或「阿不思的落胤」加入手卡或表侧表示特殊召唤
function c41373230.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示控制者从卡组选择要加入手卡或特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组选择1只「教导」怪兽或「阿不思的落胤」
	local g=Duel.SelectMatchingCard(tp,c41373230.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取当前自己怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断选中的怪兽是否加入手卡（可加手且无法特召、无空位或玩家选择加手时执行）
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入自己手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的怪兽表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

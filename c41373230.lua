--灰燼竜バスタード
-- 效果：
-- 「阿不思的落胤」＋攻击力2500以上的怪兽
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升作为这张卡的融合素材的怪兽的原本等级合计×100。
-- ②：这张卡融合召唤时适用。这个回合，这张卡不受从额外卡组特殊召唤的其他怪兽发动的效果影响。
-- ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「教导」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
function c41373230.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为68468459的怪兽和至少1只攻击力不低于2500的怪兽作为融合素材
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
	-- ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「教导」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c41373230.regop)
	c:RegisterEffect(e3)
	-- 效果作用
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
-- 融合素材检查函数，确保融合素材中包含一张卡号为68468459的卡和至少一张攻击力不低于2500的怪兽
function c41373230.branded_fusion_check(tp,sg,fc)
	-- 检查融合素材是否满足条件：包含一张卡号为68468459的卡和至少一张攻击力不低于2500的怪兽
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,Card.IsAttackAbove,2500)
end
-- 过滤函数，用于筛选融合素材中的怪兽，必须是怪兽类型且原本等级大于0
function c41373230.matfilter(c)
	return c:IsFusionType(TYPE_MONSTER) and c:GetOriginalLevel()>0
end
-- 计算融合素材中所有怪兽的原本等级总和，并以此为依据提升自身攻击力
function c41373230.matcheck(e,c)
	local g=c:GetMaterial():Filter(c41373230.matfilter,nil)
	local atk=g:GetSum(Card.GetOriginalLevel)
	-- 将自身攻击力提升至融合素材中所有怪兽原本等级总和乘以100
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk*100)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 判断该卡是否为融合召唤成功
function c41373230.imcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 设置自身免疫从额外卡组特殊召唤的怪兽发动的效果
function c41373230.imop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 免疫从额外卡组特殊召唤的怪兽发动的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(c41373230.efilter)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 效果过滤函数，用于判断是否免疫某个效果
function c41373230.efilter(e,te)
	local tc=te:GetOwner()
	return tc~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
		and te:GetActivateLocation()==LOCATION_MZONE and tc:IsSummonLocation(LOCATION_EXTRA)
end
-- 为该卡注册一个标记，用于记录其被送去墓地的回合
function c41373230.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(41373230,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断该卡是否在被送去墓地的回合内
function c41373230.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(41373230)>0
end
-- 筛选函数，用于选择卡组中满足条件的「教导」怪兽或「阿不思的落胤」
function c41373230.thfilter(c,e,tp)
	if not (c:IsSetCard(0x145) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) then return false end
	-- 获取玩家在场上的可用怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 设置效果目标，检查卡组中是否存在满足条件的卡片
function c41373230.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c41373230.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 发动效果，选择一张卡并决定将其加入手卡或特殊召唤
function c41373230.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c41373230.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取玩家在场上的可用怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否将卡加入手卡或特殊召唤
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认该卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将卡特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

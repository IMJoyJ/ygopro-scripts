--痕喰竜ブリガンド
-- 效果：
-- 「阿不思的落胤」＋8星以上的怪兽
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡不会被战斗破坏。
-- ②：只要融合召唤的这张卡在怪兽区域存在，对方不能把自己场上的其他怪兽作为怪兽的效果的对象。
-- ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「铁兽」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
function c34848821.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为68468459的怪兽和1个8星以上的怪兽作为融合素材
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
	-- ③：这张卡被送去墓地的回合的结束阶段才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c34848821.regop)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组选1只「铁兽」怪兽或「阿不思的落胤」加入手卡或特殊召唤。
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
-- 融合召唤检查函数，确保融合素材包含一张「阿不思的落胤」和一张8星以上的怪兽
function c34848821.branded_fusion_check(tp,sg,fc)
	-- 检查融合素材是否恰好包含一张「阿不思的落胤」和一张8星以上的怪兽
	return aux.gffcheck(sg,Card.IsFusionCode,68468459,Card.IsLevelAbove,8)
end
-- 判断卡片是否为融合召唤 summoned
function c34848821.imcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 目标不能为自身
function c34848821.imval(e,c)
	return c~=e:GetHandler()
end
-- 过滤函数，判断效果是否对怪兽有效
function c34848821.imfilter(e,re,rp)
	-- 判断效果是否对怪兽有效
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_MONSTER)
end
-- 记录flag，标记该卡被送去墓地
function c34848821.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(34848821,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否为被送去墓地的回合
function c34848821.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(34848821)>0
end
-- 检索过滤函数，筛选「铁兽」怪兽或「阿不思的落胤」
function c34848821.thfilter(c,e,tp)
	if not (c:IsSetCard(0x14d) and c:IsType(TYPE_MONSTER) or c:IsCode(68468459)) then return false end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 设置效果目标，检查是否存在满足条件的卡
function c34848821.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c34848821.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 处理效果发动，选择卡并决定加入手卡或特殊召唤
function c34848821.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c34848821.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否选择加入手卡
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认对方查看该卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 特殊召唤该卡到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

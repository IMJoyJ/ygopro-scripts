--モーターシェル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡从场上送去墓地的场合才能发动。在自己场上把1只「马达衍生物」（机械族·地·1星·攻/守200）攻击表示特殊召唤。
function c78394032.initial_effect(c)
	-- 记录这张卡的效果中记述了卡名「马达暴力狂」（82556059）
	aux.AddCodeList(c,82556059)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡从场上送去墓地的场合才能发动。在自己场上把1只「马达衍生物」（机械族·地·1星·攻/守200）攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,78394032)
	e1:SetCondition(c78394032.tkcon)
	e1:SetTarget(c78394032.tktg)
	e1:SetOperation(c78394032.tkop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：这张卡必须是从场上送去墓地
function c78394032.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检查发动目标：确认自己场上有空位且可以特殊召唤该衍生物
function c78394032.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 检查玩家是否可以特殊召唤「马达衍生物」（机械族·地·1星·攻/守200）到场上
	and Duel.IsPlayerCanSpecialSummonMonster(tp,78394033,0,TYPES_TOKEN_MONSTER,200,200,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) end
	-- 设置操作信息：此效果包含产生衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：此效果包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：在自己场上将1只「马达衍生物」攻击表示特殊召唤
function c78394032.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的主要怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 再次检查是否可以特殊召唤该衍生物
	if Duel.IsPlayerCanSpecialSummonMonster(tp,78394033,0,TYPES_TOKEN_MONSTER,200,200,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK) then
		-- 创建「马达衍生物」的卡片数据
		local token=Duel.CreateToken(tp,78394033)
		-- 将创建的衍生物以表侧攻击表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end

--フィッシュボーグ－ランチャー
-- 效果：
-- 这个卡名的效果1回合只能使用1次，把这张卡作为同调素材的场合，不是水属性怪兽的同调召唤不能使用。
-- ①：这张卡在墓地存在，「电子鱼人-火箭炮手」以外的自己墓地的怪兽只有水属性怪兽的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c66853752.initial_effect(c)
	-- ①：这张卡在墓地存在，「电子鱼人-火箭炮手」以外的自己墓地的怪兽只有水属性怪兽的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个卡名的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66853752,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,66853752)
	e1:SetCondition(c66853752.condition)
	e1:SetTarget(c66853752.target)
	e1:SetOperation(c66853752.operation)
	c:RegisterEffect(e1)
	-- 把这张卡作为同调素材的场合，不是水属性怪兽的同调召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c66853752.synlimit)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中除「电子鱼人-火箭炮手」以外的怪兽卡
function c66853752.cfilter(c)
	return not c:IsCode(66853752) and c:IsType(TYPE_MONSTER)
end
-- 判断发动条件：自己墓地存在怪兽，且这些怪兽全部为水属性
function c66853752.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中除「电子鱼人-火箭炮手」以外的所有怪兽
	local g=Duel.GetMatchingGroup(c66853752.cfilter,tp,LOCATION_GRAVE,0,nil)
	return g:GetCount()>0 and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WATER)==g:GetCount()
end
-- 特殊召唤效果的发动准备：检查怪兽区域空位及自身是否能特殊召唤，并设置操作信息
function c66853752.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：在满足条件时将自身特殊召唤，并添加离场时除外的效果
function c66853752.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，且怪兽区域是否有空位
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取自己墓地中除「电子鱼人-火箭炮手」以外的所有怪兽，用于在效果处理时重新确认条件
		local g=Duel.GetMatchingGroup(c66853752.cfilter,tp,LOCATION_GRAVE,0,nil)
		if g:GetCount()>0 and g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WATER)==g:GetCount()
			-- 将自身以表侧表示特殊召唤，并判断是否特殊召唤成功
			and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。把这张卡作为同调素材的场合，不是水属性怪兽的同调召唤不能使用。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1,true)
		end
	end
end
-- 限制作为同调素材时，只能用于水属性怪兽的同调召唤
function c66853752.synlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
